#!/bin/bash

# CodePush 自建服务器部署脚本
# 使用方法: ./scripts/codepush-deploy.sh [platform] [deployment] [description]
# 例如: ./scripts/codepush-deploy.sh android Staging "修复了一些bug"

PLATFORM=${1:-android}
DEPLOYMENT=${2:-Staging}
DESCRIPTION=${3:-"热更新"}
APP_NAME="RNSplitBundle"  # 应用名，可根据需要修改
SERVER_URL="http://localhost:3000"  # 自建服务器地址

echo "========================================="
echo "🚀 CodePush 自建服务器部署脚本"
echo "========================================="
echo "📱 平台: $PLATFORM"
echo "🎯 部署环境: $DEPLOYMENT"
echo "📝 更新描述: $DESCRIPTION"
echo "🌐 服务器: $SERVER_URL"
echo ""

# 检查 code-push-cli 是否安装
if ! command -v code-push &> /dev/null; then
    echo "❌ code-push-cli 未安装"
    echo ""
    echo "请先安装:"
    echo "npm install -g code-push-cli"
    echo ""
    echo "然后登录到自建服务器:"
    echo "code-push login $SERVER_URL"
    exit 1
fi

# 检查是否登录
echo "🔍 检查登录状态..."
code-push whoami > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ 请先登录到自建服务器:"
    echo "code-push login $SERVER_URL"
    echo ""
    echo "首次使用还需要创建应用:"
    echo "code-push app add $APP_NAME-Android android react-native"
    echo "code-push app add $APP_NAME-iOS ios react-native"
    exit 1
fi

# 根据平台选择不同的应用名
if [ "$PLATFORM" = "ios" ]; then
    FULL_APP_NAME="${APP_NAME}-iOS"
elif [ "$PLATFORM" = "android" ]; then
    FULL_APP_NAME="${APP_NAME}-Android"
else
    echo "❌ 错误: 不支持的平台 $PLATFORM"
    echo "请使用 'ios' 或 'android'"
    exit 1
fi

# 检查应用是否存在
echo "🔍 检查应用 $FULL_APP_NAME 是否存在..."
code-push app list | grep -q "$FULL_APP_NAME"
if [ $? -ne 0 ]; then
    echo "❌ 应用 $FULL_APP_NAME 不存在"
    echo ""
    echo "请先创建应用:"
    echo "code-push app add $FULL_APP_NAME $PLATFORM react-native"
    echo ""
    echo "创建后可以查看部署密钥:"
    echo "code-push deployment ls $FULL_APP_NAME -k"
    exit 1
fi

# 执行发布
echo ""
echo "🚀 开始发布到 $FULL_APP_NAME 的 $DEPLOYMENT 环境..."
echo ""

code-push release-react \
    "$FULL_APP_NAME" \
    "$PLATFORM" \
    -d "$DEPLOYMENT" \
    --description "$DESCRIPTION" \
    --mandatory false

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 发布成功!"
    echo ""
    echo "📊 查看发布历史:"
    echo "code-push deployment history $FULL_APP_NAME $DEPLOYMENT"
    echo ""
    echo "🔑 查看部署密钥:"
    echo "code-push deployment ls $FULL_APP_NAME -k"
    echo ""
    echo "🌐 管理界面: $SERVER_URL"
else
    echo ""
    echo "❌ 发布失败!"
    exit 1
fi