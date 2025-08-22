// CodePush配置文件
// 用于管理不同环境的deployment keys

const Config = {
  // 开发环境配置
  development: {
    // 这里填入你的Staging Key，用于本地测试
    deploymentKey: 'YOUR_STAGING_DEPLOYMENT_KEY',
    // 本地测试时使用更频繁的检查
    checkFrequency: 'MANUAL',
    // 显示下载进度
    showDownloadProgress: true,
  },
  
  // 生产环境配置
  production: {
    // 生产环境使用Production Key
    deploymentKey: 'YOUR_PRODUCTION_DEPLOYMENT_KEY',
    checkFrequency: 'ON_APP_START',
    showDownloadProgress: false,
  },
  
  // 自建服务器URL配置
  serverUrl: 'http://localhost:3000', // 自建CodePush服务器地址
  
  // 更新对话框配置
  updateDialog: {
    title: '发现新版本',
    mandatoryUpdateMessage: '发现重要更新，需要立即更新才能继续使用',
    mandatoryContinueButtonLabel: '立即更新',
    optionalUpdateMessage: '发现新版本，是否现在更新？',
    optionalInstallButtonLabel: '更新',
    optionalIgnoreButtonLabel: '稍后',
  },
};

// 根据环境返回配置
export const getCodePushConfig = () => {
  const baseConfig = __DEV__ ? Config.development : Config.production;
  
  return {
    ...baseConfig,
    serverUrl: Config.serverUrl,
    updateDialog: Config.updateDialog,
    // 安装模式配置
    installMode: __DEV__ ? 'IMMEDIATE' : 'ON_NEXT_RESTART',
    // 最小后台时间（毫秒）
    minimumBackgroundDuration: 10000,
  };
};

export default Config;