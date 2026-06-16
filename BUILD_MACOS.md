# OpenPup Flutter App

## Building macOS DMG (Intel)

### Option 1: GitHub Actions (recommended)

这个项目包含了 GitHub Actions 工作流，可以自动编译 Intel Mac DMG：

1. 将代码推送到 GitHub:
```bash
cd openpup_flutter
git remote add origin https://github.com/YOUR_USER/openpup.git
git push -u origin master
```

2. 在 GitHub 仓库页面，点击 **Actions** → **Build macOS (Intel)** → **Run workflow**
3. 等待构建完成（约 5-10 分钟）
4. 在 workflow 运行结果中下载 `.dmg` 文件

### Option 2: 本地 Mac 编译

在 Mac 上执行：
```bash
# 安装 Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PWD/flutter/bin:$PATH"
flutter config --enable-macos-desktop

# 编译
cd openpup_flutter
flutter create --platforms=macos .
flutter pub get
flutter build macos --release

# 打包 DMG
brew install create-dmg
create-dmg \
  --volname "OpenPup" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "openpup.app" 150 190 \
  --hide-extension "openpup.app" \
  --app-drop-link 450 190 \
  "openpup-macos-intel.dmg" \
  "build/macos/Build/Products/Release/openpup.app"
```

### Requirements

- Flutter 3.44.2+
- macOS 13+ (Ventura)
- Xcode 15+
- CocoaPods
