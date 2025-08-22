#!/bin/bash

# 本地热更新测试脚本
# 用于生成bundle文件并模拟热更新测试

echo "========================================="
echo "本地热更新Bundle生成脚本"
echo "========================================="
echo ""

# 创建bundle输出目录
BUNDLE_DIR="./android/app/src/main/assets"
mkdir -p $BUNDLE_DIR

# 生成bundle文件
echo "正在生成JavaScript Bundle..."
npx react-native bundle \
    --platform android \
    --dev false \
    --entry-file index.js \
    --bundle-output $BUNDLE_DIR/index.android.bundle \
    --assets-dest android/app/src/main/res

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Bundle生成成功!"
    echo "位置: $BUNDLE_DIR/index.android.bundle"
    echo ""
    echo "现在可以重新构建APK来测试更新:"
    echo "cd android && ./gradlew assembleRelease"
else
    echo ""
    echo "❌ Bundle生成失败!"
    exit 1
fi