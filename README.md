# 随心约 iOS 第一版

SwiftUI iPhone 工程（iOS 16.4 及以上）。保留第一版界面、校区和场馆选择、本地历史记录和统计。游泳时段为 06:30–08:00、16:30–18:00、19:30–21:00。

## 生成 IPA

打开本仓库 **Actions → iOS cloud build → Run workflow**。

编译成功后，在运行页面的 **Artifacts** 下载 **SuixinYue-IPA-requires-local-signing**，解压得到 `SuixinYue-unsigned.ipa`。

IPA 需要通过 Windows 上的 AltServer / AltStore Classic 等工具使用自己的 Apple 账号签名安装；无需购买 Apple 开发者会员，不上架。免费签名通常需要每 7 天刷新一次。

详细步骤：[Windows 安装说明](ios/INSTALL_IPA.md)。

当前应用只在本地保存数据，没有连接学校预约服务；界面显示不代表已完成后台预约。
