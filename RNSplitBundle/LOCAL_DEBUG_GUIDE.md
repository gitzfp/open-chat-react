# 本地调试热更新完整指南

## 🚀 快速开始

### 1. 获取你的Deployment Key

```bash
# 查看你的用户名
appcenter profile list

# 查看deployment keys（替换<username>）
appcenter codepush deployment list -a <username>/RNSplitBundle-Android -k
```

### 2. 配置Deployment Key

编辑以下两个文件：

**文件1**: `android/app/src/main/res/values/strings.xml`
```xml
<string name="CodePushDeploymentKey">你的Staging Key</string>
```

**文件2**: `src/config/codepush.config.js`
```javascript
development: {
  deploymentKey: '你的Staging Key',
  ...
}
```

### 3. 启动开发服务器

```bash
# 在一个终端窗口
yarn start

# 在另一个终端窗口运行Android
yarn android
```

## 📱 测试热更新的三种方法

### 方法1：使用调试面板（推荐）

应用启动后，在首页你会看到一个**CodePush调试面板**，包含：
- 当前版本信息
- 检查更新按钮
- 立即同步按钮
- 清除更新按钮
- 重启应用按钮

### 方法2：使用测试脚本

```bash
# 运行交互式测试脚本
./scripts/local-test-hotupdate.sh

# 选择操作：
# 1. 发布测试更新（自动修改首页标题）
# 2. 发布当前代码
# 3. 查看发布历史
# 4. 查看部署密钥
# 5. 回滚版本
```

### 方法3：手动发布测试

```bash
# 1. 修改代码（比如修改首页的标题）
# 编辑 src/screens/HomeScreen.tsx

# 2. 发布更新（替换<username>）
appcenter codepush release-react \
  -a <username>/RNSplitBundle-Android \
  -d Staging \
  --description "测试更新 $(date +%H:%M:%S)" \
  --development true

# 3. 在应用中点击"检查更新"按钮
```

## 🔧 重要配置说明

### 为什么能在Debug模式下测试？

我们做了以下特殊配置：

1. **App.tsx** - 启用了Debug模式下的CodePush：
```javascript
const codePushOptions = {
  checkFrequency: CodePush.CheckFrequency.MANUAL,
  deploymentKey: __DEV__ ? 'YOUR_STAGING_KEY' : undefined,
};
```

2. **调试面板** - 只在开发模式显示：
```javascript
{__DEV__ && <CodePushDebugPanel />}
```

3. **发布命令** - 添加了 `--development true` 参数：
```bash
appcenter codepush release-react ... --development true
```

## 📋 完整测试流程

### 步骤1：准备工作
```bash
# 确保登录AppCenter
appcenter login

# 获取你的信息
appcenter profile list
```

### 步骤2：配置Keys
1. 获取Staging Key
2. 配置到 `strings.xml` 和 `codepush.config.js`

### 步骤3：启动应用
```bash
# 启动Metro
yarn start

# 启动Android应用
yarn android
```

### 步骤4：修改代码测试
1. 修改 `src/screens/HomeScreen.tsx` 的标题
2. 保存文件（不要刷新应用）

### 步骤5：发布更新
```bash
# 使用脚本
./scripts/local-test-hotupdate.sh

# 或手动发布
appcenter codepush release-react \
  -a <username>/RNSplitBundle-Android \
  -d Staging \
  --description "修改了首页标题" \
  --development true
```

### 步骤6：测试更新
1. 在应用的调试面板点击"检查更新"
2. 确认下载更新
3. 应用会自动重启并显示新内容

## ⚠️ 常见问题

### Q: 更新没有检测到？
**A:** 检查以下几点：
- Deployment Key是否正确配置
- 发布时是否加了 `--development true`
- 等待几秒让服务器同步

### Q: 提示"已是最新版本"？
**A:** 可能原因：
- 代码没有实际改动
- 上次更新还在缓存中，点击"清除更新"后重试

### Q: 更新后应用崩溃？
**A:** 操作步骤：
1. 点击"清除更新"按钮
2. 重启应用
3. 检查代码错误并修复

### Q: 如何查看详细日志？
```bash
# Android日志
adb logcat | grep -i codepush

# React Native日志
npx react-native log-android
```

## 🎯 最佳实践

1. **测试环境使用Staging，生产环境使用Production**
2. **每次发布都写清楚描述**
3. **重大改动先在Staging测试**
4. **使用调试面板快速测试**
5. **记得在生产版本中移除调试代码**

## 📊 查看统计

```bash
# 查看部署状态
appcenter codepush deployment list -a <username>/RNSplitBundle-Android

# 查看发布历史
appcenter codepush deployment history -a <username>/RNSplitBundle-Android Staging

# 查看指标
appcenter codepush deployment metrics -a <username>/RNSplitBundle-Android Staging
```

## 🔄 版本管理

```bash
# 推广到生产环境
appcenter codepush promote \
  -a <username>/RNSplitBundle-Android \
  -s Staging \
  -d Production

# 回滚版本
appcenter codepush rollback \
  -a <username>/RNSplitBundle-Android \
  Staging

# 清除某个版本
appcenter codepush deployment clear \
  -a <username>/RNSplitBundle-Android \
  Staging
```

现在你已经可以在本地开发环境完整测试热更新功能了！