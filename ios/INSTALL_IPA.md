# 不上架，使用 Windows 安装 iOS 第一版

此路线不使用 TestFlight，无需购买 Apple 开发者会员。GitHub 的 macOS 构建环境仍受其套餐和计费规则约束。

## 生成 IPA

1. 新建 GitHub 仓库。将工程包解压后上传，仓库根目录需要有 `.github` 和 `ios` 文件夹；不要只上传 ZIP。
2. 仓库 Actions → **iOS cloud build** → **Run workflow**，不需要配置 Apple 证书、Secrets 或开发者 Team。
3. 等待编译成功，下载 Artifacts 中的 **SuixinYue-IPA-requires-local-signing**。
4. 解压下载的产物，得到 **SuixinYue-unsigned.ipa**。这是 iPhone arm64 真机程序，需要在安装时使用自己的账号签名。

目前未在云端执行实际编译；工程包不是 IPA，不能直接安装。首次构建失败时，保留日志中的第一个 Xcode 错误用于修复。

## Windows 安装到 iPhone

使用 [AltStore Classic 官方 Windows 教程](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows)：

1. 按官方教程安装所需的 iTunes/iCloud、AltServer，并用数据线连接 iPhone，在手机上信任电脑。
2. 通过 AltServer 安装 AltStore Classic，在本机工具中登录自己的 Apple 账号。
3. 按提示信任开发者并开启 iPhone 的开发者模式。
4. 将 IPA 传到 iPhone，通过 AltStore Classic 的 My Apps 页面导入 IPA（加号或文件的共享菜单），完成签名和安装。安装时让 AltServer 运行并保持电脑与手机可连接。

使用免费账号的应用通常 7 天到期，需在到期前通过 AltStore 刷新签名；到期后重新签名才能继续打开。当前免费账号有同时安装应用数量限制，AltStore 自身也占一个名额。

给其他人使用时可以提供同一份 unsigned IPA，由每个人使用自己的账号签名安装。这个方式不支持把未签名 IPA 发到聊天里后，在任意 iPhone 上直接点击安装。

应用保留第一版界面和游泳的 06:30–08:00、16:30–18:00、19:30–21:00 三个时段。最低 iOS 16.4。

参考：[AltStore 入门与有效期](https://faq.altstore.io/altstore-classic/your-altstore)、[Apple 免费 Personal Team 限制](https://developer.apple.com/help/account/basics/about-your-developer-account/)。
