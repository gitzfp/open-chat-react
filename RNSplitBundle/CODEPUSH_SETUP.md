# CodePush 热更新配置说明

## 1. 初始设置

### 1.1 注册AppCenter账号
1. 访问 https://appcenter.ms 注册账号
2. 登录后创建两个应用：
   - `YourAppName-Android` (选择React Native + Android)
   - `YourAppName-iOS` (选择React Native + iOS)

### 1.2 获取Deployment Keys
在AppCenter中，为每个应用创建部署环境：
```bash
# 登录AppCenter
npm run codepush:login

# 创建应用（如果还没创建）
appcenter apps create -d YourAppName-Android -o Android -p React-Native
appcenter apps create -d YourAppName-iOS -o iOS -p React-Native

# 查看deployment keys
appcenter codepush deployment list -a YourUsername/YourAppName-Android -k
appcenter codepush deployment list -a YourUsername/YourAppName-iOS -k
```

### 1.3 配置Deployment Keys

#### Android配置
编辑 `android/app/build.gradle`，替换YOUR_ANDROID_DEPLOYMENT_KEY：
```gradle
buildConfigField "String", "CODEPUSH_KEY", '"你的Staging或Production Key"'
```

#### iOS配置（如需要）
在 `ios/RNSplitBundle/Info.plist` 中添加：
```xml
<key>CodePushDeploymentKey</key>
<string>你的iOS Deployment Key</string>
```

## 2. 使用命令行发布热更新

### 2.1 快速命令
```bash
# 生成本地bundle（测试用）
npm run bundle:android

# 发布到Android Staging环境
npm run codepush:android:staging

# 发布到Android Production环境
npm run codepush:android:production

# 自定义发布（带描述）
./scripts/codepush-deploy.sh android Staging "修复了首页显示问题"
```

### 2.2 完整发布流程

1. **修改代码**
   修改你的React Native代码（如修改首页文字）

2. **测试修改**
   ```bash
   # 在模拟器中测试
   npm run android
   ```

3. **发布更新**
   ```bash
   # 发布到Staging环境测试
   npm run codepush:android:staging
   
   # 或使用appcenter命令直接发布
   appcenter codepush release-react \
     -a YourUsername/YourAppName-Android \
     -d Staging \
     --description "更新内容描述"
   ```

4. **查看发布历史**
   ```bash
   appcenter codepush deployment history \
     -a YourUsername/YourAppName-Android \
     Staging
   ```

5. **推广到生产环境**
   ```bash
   # 测试通过后，将Staging版本推广到Production
   appcenter codepush promote \
     -a YourUsername/YourAppName-Android \
     -s Staging \
     -d Production
   ```

## 3. 验证热更新

### 3.1 在应用中查看版本
应用首页会显示：
- 应用版本 (versionName)
- 更新标签 (CodePush label)
- 更新描述

### 3.2 强制检查更新
在首页添加一个按钮来手动检查更新：
```javascript
CodePush.sync({
  updateDialog: true,
  installMode: CodePush.InstallMode.IMMEDIATE
});
```

### 3.3 查看日志
```bash
# Android日志
adb logcat | grep CodePush

# 查看React Native日志
npx react-native log-android
```

## 4. 常见问题

### Q: 更新没有生效？
A: 检查以下几点：
1. Deployment Key是否正确配置
2. 应用是否在Release模式下运行
3. 检查AppCenter控制台是否显示有活跃用户

### Q: 如何回滚更新？
A: 使用以下命令回滚：
```bash
appcenter codepush rollback \
  -a YourUsername/YourAppName-Android \
  Production
```

### Q: 如何设置强制更新？
A: 发布时添加 --mandatory 参数：
```bash
appcenter codepush release-react \
  -a YourUsername/YourAppName-Android \
  -d Production \
  --mandatory
```

## 5. 最佳实践

1. **使用Staging环境测试**：永远先发布到Staging环境测试
2. **版本管理**：重大更新通过应用商店，小更新用CodePush
3. **描述清晰**：每次更新都要有清晰的描述
4. **监控指标**：关注更新安装率和崩溃率
5. **渐进发布**：使用百分比发布功能逐步推送更新

## 6. 构建发布版APK

```bash
# 构建Release APK
npm run build:android:release

# APK位置
# android/app/build/outputs/apk/release/app-release.apk

# 构建AAB（用于Google Play）
npm run build:android:bundle

# AAB位置
# android/app/build/outputs/bundle/release/app-release.aab
```