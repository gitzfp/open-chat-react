#!/bin/bash

# 本地测试热更新脚本
# 用于在开发环境下测试CodePush热更新

echo "========================================="
echo "📱 本地热更新测试工具"
echo "========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取用户信息
echo -e "${YELLOW}请先确保：${NC}"
echo "1. 已经登录 AppCenter (appcenter login)"
echo "2. 已经创建了应用"
echo "3. 已经配置了 Deployment Key"
echo ""

# 获取用户名
echo -n "请输入你的AppCenter用户名: "
read USERNAME

# 获取应用名
echo -n "请输入应用名 (默认: RNSplitBundle-Android): "
read APP_NAME
APP_NAME=${APP_NAME:-RNSplitBundle-Android}

# 获取部署环境
echo -n "请选择部署环境 [1]Staging [2]Production (默认: 1): "
read ENV_CHOICE
if [ "$ENV_CHOICE" = "2" ]; then
    DEPLOYMENT="Production"
else
    DEPLOYMENT="Staging"
fi

# 完整应用名
FULL_APP_NAME="${USERNAME}/${APP_NAME}"

echo ""
echo -e "${GREEN}配置信息：${NC}"
echo "应用: $FULL_APP_NAME"
echo "环境: $DEPLOYMENT"
echo ""

# 选择操作
echo -e "${YELLOW}请选择操作：${NC}"
echo "1. 发布测试更新（修改首页标题）"
echo "2. 发布自定义更新（当前代码）"
echo "3. 查看发布历史"
echo "4. 查看部署密钥"
echo "5. 回滚到上一版本"
echo -n "请选择 (1-5): "
read CHOICE

case $CHOICE in
    1)
        echo ""
        echo -e "${GREEN}正在创建测试更新...${NC}"
        
        # 备份原文件
        cp src/screens/HomeScreen.tsx src/screens/HomeScreen.tsx.backup
        
        # 修改首页标题为测试版本
        TIMESTAMP=$(date +"%H:%M:%S")
        sed -i '' "s/首页 - 热更新测试/首页 - 更新于 $TIMESTAMP/g" src/screens/HomeScreen.tsx
        
        # 发布更新
        echo -e "${GREEN}正在发布更新到 $DEPLOYMENT...${NC}"
        appcenter codepush release-react \
            -a "$FULL_APP_NAME" \
            -d "$DEPLOYMENT" \
            --description "测试更新 - $TIMESTAMP" \
            --mandatory false \
            --development true
        
        # 恢复原文件
        mv src/screens/HomeScreen.tsx.backup src/screens/HomeScreen.tsx
        
        echo ""
        echo -e "${GREEN}✅ 更新发布成功！${NC}"
        echo "现在在应用中点击调试面板的'检查更新'按钮即可测试"
        ;;
        
    2)
        echo ""
        echo -n "请输入更新描述: "
        read DESCRIPTION
        
        echo -e "${GREEN}正在发布当前代码到 $DEPLOYMENT...${NC}"
        appcenter codepush release-react \
            -a "$FULL_APP_NAME" \
            -d "$DEPLOYMENT" \
            --description "$DESCRIPTION" \
            --mandatory false \
            --development true
        
        echo ""
        echo -e "${GREEN}✅ 更新发布成功！${NC}"
        ;;
        
    3)
        echo ""
        echo -e "${GREEN}获取发布历史...${NC}"
        appcenter codepush deployment history \
            -a "$FULL_APP_NAME" \
            "$DEPLOYMENT"
        ;;
        
    4)
        echo ""
        echo -e "${GREEN}获取部署密钥...${NC}"
        appcenter codepush deployment list \
            -a "$FULL_APP_NAME" \
            -k
        ;;
        
    5)
        echo ""
        echo -e "${YELLOW}⚠️  确定要回滚到上一版本吗？${NC}"
        echo -n "输入 'yes' 确认: "
        read CONFIRM
        
        if [ "$CONFIRM" = "yes" ]; then
            appcenter codepush rollback \
                -a "$FULL_APP_NAME" \
                "$DEPLOYMENT"
            echo -e "${GREEN}✅ 回滚成功！${NC}"
        else
            echo "已取消回滚"
        fi
        ;;
        
    *)
        echo -e "${RED}无效的选择${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}提示：${NC}"
echo "1. 在开发模式下，应用会显示CodePush调试面板"
echo "2. 点击'检查更新'按钮测试热更新"
echo "3. 更新需要几秒钟才能在服务器上生效"
echo "4. 如果更新没有生效，检查Deployment Key是否正确配置"