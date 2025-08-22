#!/bin/bash

# 临时解决方案脚本 - 不依赖 AppCenter CodePush
# 用于在开发环境下测试热更新逻辑

echo "========================================="
echo "📱 本地热更新测试工具（临时方案）"
echo "========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}重要提示：${NC}"
echo "由于 AppCenter CodePush 配置问题，此脚本提供临时解决方案"
echo ""

echo -e "${GREEN}解决方案步骤：${NC}"
echo ""
echo "1. 访问 AppCenter 网页控制台"
echo "   https://appcenter.ms/users/2436871821-qq.com/apps"
echo ""
echo "2. 选择或创建一个 React Native 应用"
echo ""
echo "3. 在应用设置中启用 CodePush"
echo "   - 点击左侧菜单的 'Distribute' > 'CodePush'"
echo "   - 如果未启用，点击 'Get Started' 或 'Enable CodePush'"
echo ""
echo "4. 创建部署环境"
echo "   - 默认会创建 Staging 和 Production 两个环境"
echo "   - 记录下 Deployment Key"
echo ""
echo "5. 更新应用配置"
echo "   - Android: 在 android/app/src/main/res/values/strings.xml 中更新"
echo "     <string name=\"CodePushDeploymentKey\">YOUR_ANDROID_KEY</string>"
echo "   - iOS: 在 ios/RNSplitBundle/Info.plist 中更新"
echo "     <key>CodePushDeploymentKey</key>"
echo "     <string>YOUR_IOS_KEY</string>"
echo ""

echo -e "${YELLOW}临时测试方案：${NC}"
echo "1. 使用 Metro 开发服务器的热重载功能测试代码更新"
echo "2. 修改代码后，摇动设备打开开发者菜单"
echo "3. 选择 'Reload' 测试更新效果"
echo ""

echo -e "${GREEN}正确的 AppCenter CLI 命令示例：${NC}"
echo ""
echo "# 1. 登录 AppCenter"
echo "appcenter login"
echo ""
echo "# 2. 创建应用（如果还没有）"
echo "appcenter apps create -d MyApp-Android -o Android -p React-Native"
echo ""
echo "# 3. 在网页控制台启用 CodePush 后，使用以下命令"
echo "# 查看部署密钥"
echo "appcenter codepush deployment list -a owner/app-name -k"
echo ""
echo "# 发布更新"
echo "appcenter codepush release-react -a owner/app-name -d Staging"
echo ""

echo -e "${YELLOW}调试建议：${NC}"
echo "1. 确保已经登录: appcenter profile list"
echo "2. 检查应用列表: appcenter apps list"
echo "3. 使用完整的应用名格式: owner-name/app-name"
echo "4. 确保 CodePush 已在网页控制台启用"
echo ""

# 提供快速检查功能
echo -n "是否要检查当前 AppCenter 配置状态？[y/N]: "
read CHECK

if [ "$CHECK" = "y" ] || [ "$CHECK" = "Y" ]; then
    echo ""
    echo -e "${GREEN}检查登录状态...${NC}"
    appcenter profile list || echo -e "${RED}未登录，请先运行: appcenter login${NC}"
    
    echo ""
    echo -e "${GREEN}检查应用列表...${NC}"
    appcenter apps list || echo -e "${RED}无法获取应用列表${NC}"
    
    echo ""
    echo -e "${GREEN}提示：${NC}"
    echo "如果看到应用列表，请选择一个应用并在网页控制台启用 CodePush"
    echo "然后使用: appcenter codepush deployment list -a <app-name> -k"
fi