# CodePush 替代服务方案

## 1. 自托管 Code-Push-Server（开源方案）

### 简介
完全开源的 CodePush 服务器实现，可以自己部署和控制。

### 优势
- 完全免费，无限制
- 数据完全自主可控
- 可定制化程度高
- 支持私有化部署

### 部署方式

#### Docker 部署（推荐）
```bash
# 1. 克隆仓库
git clone https://github.com/lisong/code-push-server.git
cd code-push-server

# 2. 使用 Docker Compose 启动
docker-compose up -d

# 3. 访问管理界面
# http://localhost:3000
# 默认账号: admin 密码: 123456
```

#### 手动部署
```bash
# 1. 安装依赖
npm install -g code-push-server

# 2. 初始化数据库
code-push-server-db init

# 3. 启动服务
code-push-server
```

### 客户端配置
```javascript
// 在应用中配置自托管服务器地址
import codePush from 'react-native-code-push';

const codePushOptions = {
  deploymentKey: 'YOUR_DEPLOYMENT_KEY',
  serverUrl: 'http://your-server:3000' // 自托管服务器地址
};

export default codePush(codePushOptions)(App);
```

## 2. Electrode OTA Server（沃尔玛开源）

### 简介
由沃尔玛实验室开源的 OTA 更新服务，兼容 CodePush 协议。

### 安装部署
```bash
# 使用 npm 安装
npm install -g electrode-ota-server

# 启动服务器
electrode-ota-server

# 或使用 Docker
docker run -d -p 9001:9001 electrode/electrode-ota-server
```

### 特点
- 完全兼容 react-native-code-push 客户端
- 提供 Web 管理界面
- 支持多应用、多环境管理
- 内置统计分析功能

## 3. Expo Updates（Expo 生态）

### 简介
如果你的项目使用或可以迁移到 Expo，这是最简单的方案。

### 使用方式
```bash
# 安装 Expo Updates
expo install expo-updates

# 发布更新
expo publish

# 或使用 EAS Update（新版）
eas update --branch production --message "修复首页显示问题"
```

### 优势
- 与 Expo 生态深度集成
- 配置简单，开箱即用
- 免费额度充足（每月 1000 次更新）
- 支持 OTA 更新策略配置

## 4. Pushy（国内服务）

### 简介
专为国内用户优化的热更新服务，稳定性好。

### 集成方式
```bash
# 安装 SDK
npm install react-native-update

# iOS 配置
cd ios && pod install

# 初始化
pushy init
```

### 特点
- 国内访问速度快
- 中文文档支持好
- 提供免费额度
- 支持增量更新

## 5. 自建简单 CDN 方案

### 简介
使用 CDN + 版本管理实现简单的热更新。

### 实现示例
```javascript
// 服务端: 上传 bundle 到 CDN
// update-manifest.json
{
  "version": "1.0.1",
  "minContainerVersion": "1.0.0",
  "url": "https://cdn.example.com/bundles/1.0.1/main.jsbundle",
  "description": "修复首页崩溃问题"
}

// 客户端: 检查并下载更新
async function checkUpdate() {
  const manifest = await fetch('https://cdn.example.com/update-manifest.json');
  const update = await manifest.json();
  
  if (update.version > currentVersion) {
    // 下载并应用更新
    await downloadAndApplyUpdate(update.url);
  }
}
```

## 6. 使用 CI/CD + S3/OSS

### AWS S3 方案
```bash
# 1. 构建 bundle
react-native bundle --platform ios --dev false --entry-file index.js \
  --bundle-output ios-bundle.jsbundle --assets-dest ios-assets

# 2. 上传到 S3
aws s3 cp ios-bundle.jsbundle s3://my-app-updates/v1.0.1/

# 3. 客户端从 S3 下载更新
```

### 阿里云 OSS 方案
```javascript
// 使用 OSS SDK 上传更新
const OSS = require('ali-oss');
const client = new OSS({
  region: 'oss-cn-hangzhou',
  accessKeyId: 'YOUR_KEY',
  accessKeySecret: 'YOUR_SECRET',
  bucket: 'app-updates'
});

// 上传 bundle
await client.put('bundles/v1.0.1/main.jsbundle', './main.jsbundle');
```

## 推荐选择

### 小型项目/个人开发者
- **Expo Updates**：如果使用 Expo，这是最简单的选择
- **Pushy**：国内项目，有免费额度

### 中型项目/团队
- **Code-Push-Server**：开源自托管，完全可控
- **Electrode OTA**：功能完善，企业级支持

### 大型项目/企业
- **自建 CDN 方案**：完全定制化
- **CI/CD + 云存储**：与现有流程集成

## 快速对比表

| 方案 | 成本 | 部署难度 | 可控性 | 稳定性 | 适用场景 |
|------|------|----------|--------|--------|----------|
| AppCenter | 免费 | 简单 | 低 | 高 | 小型项目 |
| Code-Push-Server | 自托管成本 | 中等 | 高 | 中 | 中型项目 |
| Electrode OTA | 自托管成本 | 中等 | 高 | 高 | 企业项目 |
| Expo Updates | 免费/付费 | 简单 | 中 | 高 | Expo项目 |
| Pushy | 免费/付费 | 简单 | 低 | 高 | 国内项目 |
| 自建CDN | CDN成本 | 复杂 | 最高 | 自定 | 大型项目 |