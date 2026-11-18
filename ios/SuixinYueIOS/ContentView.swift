import SwiftUI

struct ContentView: View {
    @StateObject private var store = ReservationStore()
    @State private var showMenu = false
    @State private var showEditor = false

    var body: some View {
        VStack(spacing: 0) {
            header
            messageArea
            inputBar
        }
        .background(Color.chatBackground.ignoresSafeArea())
        .sheet(isPresented: $showEditor) {
            EditReservationView(store: store)
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                BackArrow()
                    .frame(width: 46, height: 50)
                Spacer()
                Button {
                    showMenu.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 46, height: 50)
                }
                .popover(isPresented: $showMenu) {
                    Button("新增预约/编辑信息") {
                        showMenu = false
                        showEditor = true
                    }
                    .font(.system(size: 15))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .presentationCompactAdaptation(.popover)
                }
            }

            Text("体育场馆预订系统")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.black)
        }
        .frame(height: 50)
        .background(Color.chatBackground)
    }

    private var messageArea: some View {
        ZStack {
            WatermarkBackground(text: "\(store.watermarkName)@中山大学")
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(store.records) { record in
                        Text(record.messageTimeText)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.grayText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 43)

                        ReservationCard(record: record)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color.clear)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            BottomIcon(kind: .keyboard)
                .frame(width: 42, height: 46)

            Text("按住 说话")
                .font(.system(size: 18))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))

            BottomIcon(kind: .smile)
                .frame(width: 42, height: 46)

            BottomIcon(kind: .plus)
                .frame(width: 40, height: 46)
        }
        .padding(.horizontal, 10)
        .padding(.top, 7)
        .padding(.bottom, 7)
        .background(Color.inputBackground)
    }
}

struct ReservationCard: View {
    let record: ReservationRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("您的预约已确认")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.black)
                .padding(.bottom, 2)

            Text(record.messageBody)
                .font(.system(size: 15))
                .foregroundStyle(.black)
                .lineSpacing(2)
                .padding(.bottom, 15)

            Rectangle()
                .fill(Color.divider)
                .frame(height: 1)

            HStack {
                Text("详情")
                    .font(.system(size: 15))
                    .foregroundStyle(.black)
                Spacer()
                Text("›")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.arrow)
            }
            .frame(height: 46)
        }
        .padding(.top, 12)
        .padding(.horizontal, 15)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

struct EditReservationView: View {
    @ObservedObject var store: ReservationStore
    @Environment(\.dismiss) private var dismiss
    @State private var watermarkName: String
    @State private var dateText: String
    @State private var campus: String
    @State private var facility: String
    @State private var timeSlot: String
    @State private var showStats = false

    init(store: ReservationStore) {
        self.store = store
        _watermarkName = State(initialValue: store.watermarkName)
        _dateText = State(initialValue: ReservationStore.todayText())
        _campus = State(initialValue: "深圳校区")
        _facility = State(initialValue: "健身房")
        _timeSlot = State(initialValue: "20:00-22:00")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button("统计页面") {
                        showStats = true
                    }
                }

                Section("背景文字") {
                    TextField("水印用户名", text: $watermarkName)
                }

                Section("预约日期") {
                    TextField("例如 2026-06-18", text: $dateText)
                        .keyboardType(.numbersAndPunctuation)
                }

                Section("校区") {
                    Picker("校区", selection: $campus) {
                        ForEach(ReservationStore.campuses, id: \.self) { value in
                            Text(value).tag(value)
                        }
                    }
                    .onChange(of: campus) { _ in
                        facility = ReservationStore.facilities.first ?? "健身房"
                    }
                }

                Section("场馆") {
                    Picker("场馆", selection: $facility) {
                        ForEach(ReservationStore.facilities, id: \.self) { value in
                            Text(value).tag(value)
                        }
                    }
                    .onChange(of: facility) { value in
                        let slots = ReservationStore.timeSlots(for: value)
                        if !slots.contains(timeSlot), let first = slots.first {
                            timeSlot = first
                        }
                    }
                }

                Section("预约时段") {
                    Picker("预约时段", selection: $timeSlot) {
                        ForEach(ReservationStore.timeSlots(for: facility), id: \.self) { value in
                            Text(value).tag(value)
                        }
                    }
                }
            }
            .navigationTitle("新增预约/编辑信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let name = watermarkName.trimmingCharacters(in: .whitespacesAndNewlines)
                        let startTime = timeSlot.components(separatedBy: "-").first ?? timeSlot
                        store.watermarkName = name.isEmpty ? ReservationStore.defaultWatermarkName : name
                        store.addRecord(
                            campus: campus,
                            facility: facility,
                            site: "场地1",
                            date: dateText,
                            startTime: startTime
                        )
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showStats) {
                StatsView(total: store.savedMoney)
            }
        }
        .presentationDetents([.large])
    }
}

struct StatsView: View {
    let total: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 18) {
            Text("统计页面")
                .font(.system(size: 20, weight: .bold))

            Text("一共省了 \(total) 元")
                .font(.system(size: 28, weight: .bold))

            Text("省钱不能省力哦~")
                .font(.custom("Snell Roundhand", size: 24))
                .foregroundStyle(Color.pink)

            Button("知道啦") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .padding(30)
        .presentationDetents([.height(260)])
    }
}

final class ReservationStore: ObservableObject {
    static let defaultWatermarkName = "浅望实验"
    static let campuses = ["南校园", "东校园", "北校园", "深圳校区", "珠海校区"]
    static let facilities = ["羽毛球场", "健身房", "游泳池"]
    static let timeSlots = [
        "08:00-10:00",
        "10:00-12:00",
        "12:00-14:00",
        "14:00-16:00",
        "16:00-18:00",
        "18:00-20:00",
        "20:00-22:00"
    ]
    static let swimmingTimeSlots = [
        "06:30-08:00",
        "16:30-18:00",
        "19:30-21:00"
    ]

    static func timeSlots(for facility: String) -> [String] {
        facility == "游泳池" ? swimmingTimeSlots : timeSlots
    }

    @Published var records: [ReservationRecord] {
        didSet { save() }
    }

    @Published var watermarkName: String {
        didSet { save() }
    }

    private let recordsKey = "ios_records_json"
    private let watermarkKey = "ios_watermark_name"

    init() {
        watermarkName = UserDefaults.standard.string(forKey: watermarkKey) ?? Self.defaultWatermarkName
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([ReservationRecord].self, from: data) {
            records = decoded
        } else {
            records = Self.sampleRecords()
        }
    }

    var savedMoney: Int {
        records.reduce(0) { sum, record in
            if record.facilityName.contains("羽毛球") {
                return sum + 30
            }
            if record.facilityName.contains("健身房") || record.facilityName.contains("游泳池") {
                return sum + 5
            }
            return sum
        }
    }

    func addRecord(campus: String, facility: String, site: String, date: String, startTime: String) {
        records.append(
            ReservationRecord(
                campusName: campus,
                facilityName: facility,
                siteName: site,
                dateText: date,
                startTimeText: startTime,
                messageTimeText: Self.currentMessageTimeText()
            )
        )
    }

    private func save() {
        UserDefaults.standard.set(watermarkName, forKey: watermarkKey)
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }

    static func todayText() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    static func currentMessageTimeText() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE  a h:mm"
        return formatter.string(from: Date())
    }

    private static func sampleRecords() -> [ReservationRecord] {
        [
            ReservationRecord(campusName: "深圳校区", facilityName: "健身房", siteName: "场地1", dateText: "2026-06-18", startTimeText: "20:00", messageTimeText: "星期四  下午 10:21"),
            ReservationRecord(campusName: "深圳校区", facilityName: "健身房", siteName: "场地1", dateText: "2026-06-21", startTimeText: "20:00", messageTimeText: "星期五  下午 10:05"),
            ReservationRecord(campusName: "深圳校区", facilityName: "健身房", siteName: "场地1", dateText: "2026-06-22", startTimeText: "20:00", messageTimeText: "下午 5:03"),
            ReservationRecord(campusName: "深圳校区", facilityName: "健身房", siteName: "场地1", dateText: "2026-06-25", startTimeText: "20:00", messageTimeText: "下午 5:03")
        ]
    }
}

struct ReservationRecord: Identifiable, Codable {
    var id = UUID()
    let campusName: String
    let facilityName: String
    let siteName: String
    let dateText: String
    let startTimeText: String
    let messageTimeText: String

    var venueDisplayName: String {
        "\(campusName)\(facilityName)-\(siteName)"
    }

    var messageBody: String {
        "您好！您已成功预定场地。 场地名称： \(venueDisplayName)，预定时间： \(dateText) \(startTimeText)"
    }
}

struct WatermarkBackground: View {
    let text: String

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.chatBackground
                ForEach(0..<10, id: \.self) { row in
                    ForEach(0..<4, id: \.self) { col in
                        Text(text)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.watermark)
                            .rotationEffect(.degrees(-18))
                            .position(
                                x: CGFloat(col) * 170 + CGFloat(row % 2) * 80,
                                y: CGFloat(row) * 120
                            )
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

struct BackArrow: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            let cx = size.width * 0.49
            let cy = size.height * 0.5
            let len = min(size.width, size.height) * 0.19
            let tail = min(size.width, size.height) * 0.31

            path.move(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: cx + tail, y: cy))
            path.move(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: cx + len, y: cy - len))
            path.move(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: cx + len, y: cy + len))

            context.stroke(path, with: .color(.black), lineWidth: 2.6)
        }
    }
}

enum BottomIconKind {
    case keyboard
    case smile
    case plus
}

struct BottomIcon: View {
    let kind: BottomIconKind

    var body: some View {
        Canvas { context, size in
            let r = min(size.width, size.height) * 0.34
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            var circle = Path()
            circle.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
            context.stroke(circle, with: .color(.black), lineWidth: 3)

            switch kind {
            case .keyboard:
                drawKeyboard(context: context, center: center, r: r)
            case .smile:
                drawSmile(context: context, center: center, r: r)
            case .plus:
                drawPlus(context: context, center: center, r: r)
            }
        }
    }

    private func drawKeyboard(context: GraphicsContext, center: CGPoint, r: CGFloat) {
        let dot = max(2, r * 0.13)
        let gap = r * 0.42
        for row in -1...1 {
            for col in -1...1 {
                let point = CGPoint(x: center.x + CGFloat(col) * gap, y: center.y + CGFloat(row) * gap * 0.85)
                context.fill(Path(ellipseIn: CGRect(x: point.x - dot, y: point.y - dot, width: dot * 2, height: dot * 2)), with: .color(.black))
            }
        }
        for x in [center.x - gap * 1.55, center.x + gap * 1.55] {
            context.fill(Path(ellipseIn: CGRect(x: x - dot, y: center.y - dot, width: dot * 2, height: dot * 2)), with: .color(.black))
        }
    }

    private func drawSmile(context: GraphicsContext, center: CGPoint, r: CGFloat) {
        let eye = max(2.5, r * 0.13)
        for x in [center.x - r * 0.38, center.x + r * 0.38] {
            context.fill(Path(ellipseIn: CGRect(x: x - eye, y: center.y - r * 0.22 - eye, width: eye * 2, height: eye * 2)), with: .color(.black))
        }

        var mouth = Path()
        mouth.addArc(
            center: CGPoint(x: center.x, y: center.y + r * 0.05),
            radius: r * 0.45,
            startAngle: .degrees(25),
            endAngle: .degrees(155),
            clockwise: false
        )
        context.stroke(mouth, with: .color(.black), lineWidth: 3)
    }

    private func drawPlus(context: GraphicsContext, center: CGPoint, r: CGFloat) {
        var path = Path()
        let len = r * 0.55
        path.move(to: CGPoint(x: center.x - len, y: center.y))
        path.addLine(to: CGPoint(x: center.x + len, y: center.y))
        path.move(to: CGPoint(x: center.x, y: center.y - len))
        path.addLine(to: CGPoint(x: center.x, y: center.y + len))
        context.stroke(path, with: .color(.black), lineWidth: 4)
    }
}

private extension Color {
    static let chatBackground = Color(red: 235 / 255, green: 236 / 255, blue: 240 / 255)
    static let inputBackground = Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255)
    static let grayText = Color(red: 164 / 255, green: 166 / 255, blue: 170 / 255)
    static let divider = Color(red: 238 / 255, green: 238 / 255, blue: 238 / 255)
    static let arrow = Color(red: 170 / 255, green: 170 / 255, blue: 170 / 255)
    static let watermark = Color(red: 150 / 255, green: 157 / 255, blue: 166 / 255).opacity(0.16)
}
