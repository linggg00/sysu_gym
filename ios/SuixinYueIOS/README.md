# SuixinYueIOS

这是“体育场馆预订系统”的 iOS SwiftUI 版本源码。

## 当前状态

- 当前环境是 Windows，不能直接编译 iOS App 或生成 IPA。
- 已补充完整 `SuixinYueIOS.xcodeproj`、共享 Scheme 和应用图标，可直接在 Xcode 打开。最低 iOS 16.4，面向 iPhone。
- 已准备 GitHub 云端编译，输出供 Windows 本地签名安装的 unsigned IPA，参见 [INSTALL_IPA.md](../INSTALL_IPA.md)。不上架，无需付费 Apple 开发者会员。仓库根目录需包含 `.github/workflows/ios.yml`。
- 当前只完成 Windows 上的配置检查；尚未在 Xcode 编译、真机测试或生成可安装 IPA。
- 当前数据只保存在本地，没有连接学校预约服务；界面文案不代表后台已完成预约。

## 已实现功能

- 仿聊天消息首页。
- 固定斜向水印背景。
- 右上角菜单入口。
- 新增预约/编辑信息页面。
- 校区和场馆两级联动选择。
- 游泳池时段：06:30-08:00、16:30-18:00、19:30-21:00；切换场馆时同步更新可选时段。
- 水印用户名编辑。
- 历史记录本地保存。
- 统计页面：
  - 健身房每次 5 元。
  - 游泳池每次 5 元。
  - 羽毛球场每次 30 元。
  - 显示“省钱不能省力哦~”。

## 推荐 Xcode 使用方式

1. 在 Mac 上打开 Xcode。
2. 打开本目录的 `SuixinYueIOS.xcodeproj`。
3. 在 Target → Signing & Capabilities 选择自己的 Team。
4. 将 Bundle Identifier 改成自己注册的唯一值。
5. 若使用真机，先将 iPhone 连接到该 Mac 并完成配对和开发者模式设置。
6. 免费 Personal Team 的设备描述文件有效期为 7 天，不能用于 TestFlight 分发。
7. 选择真机或模拟器运行。

项目文件和图标已随源码提供，通常无需运行生成器。若需重新生成，安装 Pillow 后在仓库根目录运行 `python ios/prepare_project.py`。该命令会覆盖生成的项目文件和图标，默认 Bundle ID 为 `com.suixinyue.sports`。
