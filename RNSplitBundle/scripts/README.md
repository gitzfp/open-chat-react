# CodePush 自建服务器脚本使用说明

## 前提条件

1. 已经启动了自建的 code-push-server (端口：3000)
2. 安装了 code-push-cli：
   ```bash
   npm install -g code-push-cli
   ```
3. 已经登录到自建服务器：
   ```bash
   code-push login http://localhost:3000
   ```

## 脚本说明

### 1. codepush-deploy.sh - 快速部署脚本

**用途**: 快速发布更新到指定平台和环境

**使用方法**:
```bash
./scripts/codepush-deploy.sh [platform] [deployment] [description]
```

**参数**:
- `platform`: 平台 (android/ios，默认: android)
- `deployment`: 部署环境 (Staging/Production，默认: Staging) 
- `description`: 更新描述 (默认: "热更新")

**示例**:
```bash
# 发布到 Android Staging 环境
./scripts/codepush-deploy.sh android Staging "修复首页崩溃问题"

# 发布到 iOS Production 环境  
./scripts/codepush-deploy.sh ios Production "新增用户反馈功能"

# 使用默认参数 (Android Staging)
./scripts/codepush-deploy.sh
```

### 2. codepush-interactive.sh - 交互式管理工具

**用途**: 提供友好的交互界面管理 CodePush

**使用方法**:
```bash
./scripts/codepush-interactive.sh
```

**功能菜单**:

**📱 应用管理**
- 1) 查看应用列表
- 2) 创建新应用
- 3) 查看部署密钥

**🚀 发布管理**
- 4) 发布更新 (Android)
- 5) 发布更新 (iOS)
- 6) 查看发布历史
- 7) 回滚版本

**⚙️ 环境管理**
- 8) 管理部署环境
- 9) 清除发布历史

**🔧 工具**
- 10) 服务器状态
- 11) 登录信息

## 首次使用步骤

### 1. 登录到自建服务器
```bash
code-push login http://localhost:3000
```

### 2. 创建应用
使用交互式工具创建应用，或使用命令行：
```bash
# Android 应用
code-push app add RNSplitBundle-Android android react-native

# iOS 应用  
code-push app add RNSplitBundle-iOS ios react-native
```

### 3. 获取部署密钥
```bash
# 查看 Android 应用的密钥
code-push deployment ls RNSplitBundle-Android -k

# 查看 iOS 应用的密钥
code-push deployment ls RNSplitBundle-iOS -k
```

### 4. 更新客户端配置
将获取的部署密钥填入 `src/config/codepush.config.js`：
```javascript
const Config = {
  development: {
    deploymentKey: 'YOUR_STAGING_KEY_HERE',
    // ...
  },
  production: {
    deploymentKey: 'YOUR_PRODUCTION_KEY_HERE',
    // ...
  },
  // ...
};
```

### 5. 发布第一个更新
```bash
# 使用快速脚本
./scripts/codepush-deploy.sh android Staging "首次发布"

# 或使用交互式工具
./scripts/codepush-interactive.sh
```

## 常用命令参考

### 应用管理
```bash
# 查看所有应用
code-push app list

# 查看应用详情
code-push app info RNSplitBundle-Android

# 删除应用
code-push app remove RNSplitBundle-Android
```

### 发布管理
```bash
# 发布 React Native 更新
code-push release-react RNSplitBundle-Android android -d Staging --description "修复bug"

# 查看发布历史
code-push deployment history RNSplitBundle-Android Staging

# 回滚到上一版本
code-push rollback RNSplitBundle-Android Staging

# 清除发布历史
code-push deployment clear RNSplitBundle-Android Staging
```

### 部署环境管理
```bash
# 查看部署环境
code-push deployment ls RNSplitBundle-Android

# 创建新环境
code-push deployment add RNSplitBundle-Android Beta

# 删除环境
code-push deployment remove RNSplitBundle-Android Beta
```

## 故障排查

### 1. 登录问题
```bash
# 检查当前登录状态
code-push whoami

# 重新登录
code-push logout
code-push login http://localhost:3000
```

### 2. 应用不存在
确保已经创建了对应的应用：
```bash
code-push app list
```

### 3. 服务器连接问题
检查服务器是否正常运行：
```bash
curl http://localhost:3000/api/v1/health
```

### 4. 权限问题
确保脚本有执行权限：
```bash
chmod +x scripts/codepush-deploy.sh
chmod +x scripts/codepush-interactive.sh
```

## 配置说明

### 服务器配置
默认服务器地址：`http://localhost:3000`
如需修改，请同时更新：
- `scripts/codepush-deploy.sh` 中的 `SERVER_URL`
- `scripts/codepush-interactive.sh` 中的 `SERVER_URL`
- `src/config/codepush.config.js` 中的 `serverUrl`

### 应用名称配置
默认应用名：`RNSplitBundle`
如需修改，请同时更新：
- `scripts/codepush-deploy.sh` 中的 `APP_NAME`
- `scripts/codepush-interactive.sh` 中的 `APP_NAME`

## 安全提醒

1. 生产环境请使用 HTTPS 协议
2. 定期备份服务器数据
3. 不要在代码中硬编码部署密钥
4. 建议为不同环境使用不同的部署密钥