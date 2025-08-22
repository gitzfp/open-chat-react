# CodePush 快速开始指南

## 1. 登录AppCenter

首先登录你的AppCenter账号：

```bash
appcenter login
```

这会打开浏览器让你登录。如果没有账号，请先在 https://appcenter.ms 注册。

## 2. 创建应用

登录后，创建Android应用：

```bash
# 创建Android应用
# 格式: appcenter apps create -d <应用显示名> -o <操作系统> -p <平台>
appcenter apps create -d RNSplitBundle-Android -o Android -p React-Native

# 创建iOS应用（可选）
appcenter apps create -d RNSplitBundle-iOS -o iOS -p React-Native
```

## 3. 查看应用列表

确认应用创建成功：

```bash
appcenter apps list
```

## 4. 添加CodePush部署

为应用添加CodePush部署环境（如果默认的Staging和Production不存在）：

```bash
# 格式: appcenter codepush deployment add -a <owner>/<app-name> <deployment-name>
# owner是你的用户名，可以通过 appcenter profile list 查看

# 例如，如果你的用户名是 john
appcenter codepush deployment add -a john/RNSplitBundle-Android Beta
```

## 5. 获取Deployment Keys

```bash
# 查看部署密钥
# 格式: appcenter codepush deployment list -a <owner>/<app-name> -k
appcenter codepush deployment list -a <你的用户名>/RNSplitBundle-Android -k
```

你会看到类似这样的输出：
```
┌────────────┬───────────────────────────────────────┐
│ Name       │ Key                                   │
├────────────┼───────────────────────────────────────┤
│ Staging    │ xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx│
│ Production │ yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy  │
└────────────┴───────────────────────────────────────┘
```

## 6. 配置Android应用

将获取到的Staging或Production Key配置到Android应用中：

编辑文件：`android/app/src/main/res/values/strings.xml`

```xml
<resources>
    <string name="app_name">RNSplitBundle</string>
    <string name="CodePushDeploymentKey">这里粘贴你的Staging或Production Key</string>
</resources>
```

## 7. 重新构建应用

```bash
cd android && ./gradlew assembleDebug
```

## 8. 发布热更新

修改代码后，发布更新：

```bash
# 发布到Staging环境
appcenter codepush release-react \
  -a <你的用户名>/RNSplitBundle-Android \
  -d Staging \
  --description "首次热更新测试"

# 或使用npm脚本（需要先修改scripts/codepush-deploy.sh中的APP_NAME）
npm run codepush:android:staging
```

## 9. 查看发布历史

```bash
appcenter codepush deployment history \
  -a <你的用户名>/RNSplitBundle-Android \
  Staging
```

## 10. 在应用中测试

1. 安装应用到设备
2. 打开应用，查看首页的版本信息
3. 修改首页文字（如改变标题）
4. 发布更新
5. 在应用中点击"检查更新"按钮
6. 应该会提示有新版本可用

## 常见问题

### Q: 找不到命令appcenter？
A: 确保已全局安装：`npm install -g appcenter-cli`

### Q: 登录失败？
A: 尝试使用token登录：
```bash
# 在 https://appcenter.ms/settings/apitokens 创建token
appcenter login --token <your-api-token>
```

### Q: 更新没有生效？
A: 检查以下几点：
1. Deployment Key是否正确配置
2. 应用是否在Release模式运行（Debug模式下CodePush默认禁用）
3. 检查控制台日志是否有错误

## 完整示例流程

```bash
# 1. 登录
appcenter login

# 2. 查看用户名
appcenter profile list

# 3. 创建应用（假设用户名是john）
appcenter apps create -d RNSplitBundle-Android -o Android -p React-Native

# 4. 查看deployment keys
appcenter codepush deployment list -a john/RNSplitBundle-Android -k

# 5. 配置key到strings.xml

# 6. 重新构建
cd android && ./gradlew assembleDebug

# 7. 发布更新
appcenter codepush release-react \
  -a john/RNSplitBundle-Android \
  -d Staging \
  --description "测试热更新"
```