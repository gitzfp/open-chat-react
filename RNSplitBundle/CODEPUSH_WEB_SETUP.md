# CodePush Web配置指南

由于你的用户名包含特殊字符（邮箱格式），CLI命令可能会有问题。建议使用Web界面配置：

## 🌐 通过Web界面配置（推荐）

### 1. 访问AppCenter网站
打开浏览器访问：https://appcenter.ms

### 2. 登录你的账号
使用邮箱：2436871821@qq.com

### 3. 选择或创建应用
- 点击你已创建的应用：`RNSplitBundle-Android` 或 `MyRNApp`
- 或创建新应用：点击"Add new app" → 选择Android + React Native

### 4. 配置CodePush
1. 在应用页面，点击左侧菜单的 **"Distribute"** → **"CodePush"**
2. 如果没有部署环境，点击 **"Create standard deployments"**
3. 这会创建两个环境：
   - Staging（测试环境）
   - Production（生产环境）

### 5. 获取Deployment Keys
在CodePush页面，你会看到：
- **Staging Key**: 类似 `xxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
- **Production Key**: 类似 `yyyyyyyyyyyyyyyyyyyyyyyyyyyyy`

复制Staging Key用于测试。

## 📝 配置到项目

### 1. 配置Android
编辑 `android/app/src/main/res/values/strings.xml`：
```xml
<resources>
    <string name="app_name">RNSplitBundle</string>
    <string name="CodePushDeploymentKey">粘贴你的Staging Key</string>
</resources>
```

### 2. 配置JavaScript
编辑 `src/config/codepush.config.js`：
```javascript
const Config = {
  development: {
    deploymentKey: '粘贴你的Staging Key',
    checkFrequency: 'MANUAL',
    showDownloadProgress: true,
  },
  production: {
    deploymentKey: '粘贴你的Production Key',
    checkFrequency: 'ON_APP_START',
    showDownloadProgress: false,
  },
};
```

### 3. 配置App.tsx
编辑 `App.tsx`，更新deploymentKey：
```javascript
const codePushOptions = {
  checkFrequency: CodePush.CheckFrequency.MANUAL,
  deploymentKey: __DEV__ ? '你的Staging Key' : undefined,
};
```

## 🚀 使用简化的发布命令

由于用户名包含特殊字符，我建议使用以下方法之一：

### 方法1：使用App Secret（推荐）
```bash
# 使用app secret而不是owner/name格式
export APP_SECRET="你的App Secret"

# 发布更新（使用--app参数）
appcenter codepush release-react \
  --token <your-api-token> \
  --app <app-secret> \
  -d Staging \
  --description "测试更新"
```

### 方法2：创建API Token
1. 访问：https://appcenter.ms/settings/apitokens
2. 点击"New API token"
3. 给token命名（如：CodePush）
4. 选择"Full Access"
5. 生成并复制token

使用token发布：
```bash
# 设置token
export APPCENTER_ACCESS_TOKEN="你的token"

# 发布更新
appcenter codepush release-react \
  -a "2436871821-qq.com/MyRNApp" \
  -d Staging \
  --description "测试更新" \
  --development true
```

### 方法3：使用Web界面发布
1. 在AppCenter网站上进入你的应用
2. 点击 Distribute → CodePush
3. 点击 "Release" 按钮
4. 上传bundle文件或使用CLI生成

## 📱 测试热更新

1. **重新构建应用**（配置Key后）：
   ```bash
   cd android && ./gradlew assembleDebug
   ```

2. **启动应用**：
   ```bash
   yarn android
   ```

3. **修改代码**（如修改首页标题）

4. **生成bundle并发布**：
   ```bash
   # 生成bundle
   npx react-native bundle \
     --platform android \
     --dev false \
     --entry-file index.js \
     --bundle-output codepush.bundle \
     --assets-dest ./assets

   # 通过Web界面上传bundle
   # 或使用CLI（如果能工作）
   ```

5. **在应用中测试**：
   - 点击调试面板的"检查更新"
   - 确认下载并安装

## 🔧 故障排除

### 问题：CLI命令报错"app does not exist"
**原因**：用户名包含特殊字符（@和.）导致解析问题

**解决方案**：
1. 使用Web界面操作
2. 使用API Token方式
3. 考虑创建组织账号（没有特殊字符）

### 问题：更新没有检测到
**检查**：
1. Deployment Key是否正确
2. 是否使用了`--development true`参数（开发模式）
3. 等待几秒让服务器同步

## 📌 重要提醒

1. **你的用户名**：`2436871821-qq.com`
2. **你的应用**：
   - `RNSplitBundle-Android`
   - `RNSplitBundle-Android-1`
   - `MyRNApp`
3. **App Secret**（MyRNApp）：`1d568169-e322-41a2-b2b5-69ab1e885818`

建议使用Web界面完成CodePush配置，这样可以避免CLI的兼容性问题。