#!/bin/bash

# CodePush 交互式管理工具
# 适配自建 code-push-server

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置
APP_NAME="RNSplitBundle"
SERVER_URL="http://localhost:3000"

# 显示标题
show_banner() {
    clear
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN}🚀 CodePush 交互式管理工具${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${BLUE}应用名称: ${APP_NAME}${NC}"
    echo -e "${BLUE}服务器: ${SERVER_URL}${NC}"
    echo ""
}

# 检查依赖
check_dependencies() {
    if ! command -v code-push &> /dev/null; then
        echo -e "${RED}❌ code-push-cli 未安装${NC}"
        echo ""
        echo -e "${YELLOW}请先安装:${NC}"
        echo "npm install -g code-push-cli"
        echo ""
        read -p "按回车键退出..."
        exit 1
    fi
    
    # 检查登录状态
    if ! code-push whoami &> /dev/null; then
        echo -e "${RED}❌ 未登录到 CodePush 服务器${NC}"
        echo ""
        echo -e "${YELLOW}请先登录:${NC}"
        echo "code-push login ${SERVER_URL}"
        echo ""
        read -p "按回车键退出..."
        exit 1
    fi
}

# 显示主菜单
show_menu() {
    echo -e "${PURPLE}请选择操作:${NC}"
    echo ""
    echo -e "${YELLOW}📱 应用管理${NC}"
    echo "  1) 查看应用列表"
    echo "  2) 创建新应用"
    echo "  3) 查看部署密钥"
    echo ""
    echo -e "${YELLOW}🚀 发布管理${NC}"
    echo "  4) 发布更新 (Android)"
    echo "  5) 发布更新 (iOS)"
    echo "  6) 查看发布历史"
    echo "  7) 回滚版本"
    echo ""
    echo -e "${YELLOW}⚙️  环境管理${NC}"
    echo "  8) 管理部署环境"
    echo "  9) 清除发布历史"
    echo ""
    echo -e "${YELLOW}🔧 工具${NC}"
    echo "  10) 服务器状态"
    echo "  11) 登录信息"
    echo ""
    echo -e "${YELLOW}其他${NC}"
    echo "  0) 退出"
    echo ""
    echo -n -e "${CYAN}请输入选项 [0-11]: ${NC}"
}

# 查看应用列表
list_apps() {
    echo -e "${BLUE}📱 应用列表:${NC}"
    echo ""
    code-push app list
    echo ""
    read -p "按回车键返回主菜单..."
}

# 创建新应用
create_app() {
    echo -e "${BLUE}🆕 创建新应用${NC}"
    echo ""
    
    echo -e "${YELLOW}选择平台:${NC}"
    echo "1) Android"
    echo "2) iOS"
    echo "3) 两个平台都创建"
    echo ""
    read -p "请选择 [1-3]: " platform_choice
    
    case $platform_choice in
        1)
            create_single_app "android"
            ;;
        2)
            create_single_app "ios"
            ;;
        3)
            create_single_app "android"
            create_single_app "ios"
            ;;
        *)
            echo -e "${RED}无效选择${NC}"
            ;;
    esac
    
    echo ""
    read -p "按回车键返回主菜单..."
}

# 创建单个应用
create_single_app() {
    local platform=$1
    local app_name="${APP_NAME}-${platform^}"
    
    echo ""
    echo -e "${BLUE}创建应用: ${app_name}${NC}"
    
    if code-push app add "$app_name" "$platform" react-native; then
        echo -e "${GREEN}✅ 应用创建成功!${NC}"
        echo ""
        echo -e "${YELLOW}部署密钥:${NC}"
        code-push deployment ls "$app_name" -k
    else
        echo -e "${RED}❌ 应用创建失败${NC}"
    fi
}

# 查看部署密钥
show_deployment_keys() {
    echo -e "${BLUE}🔑 查看部署密钥${NC}"
    echo ""
    
    local apps=($(code-push app list 2>/dev/null | grep "${APP_NAME}" | awk '{print $1}'))
    
    if [ ${#apps[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  没有找到相关应用${NC}"
        echo ""
        read -p "按回车键返回主菜单..."
        return
    fi
    
    for app in "${apps[@]}"; do
        echo -e "${CYAN}应用: ${app}${NC}"
        code-push deployment ls "$app" -k
        echo ""
    done
    
    read -p "按回车键返回主菜单..."
}

# 发布更新
release_update() {
    local platform=$1
    local app_name="${APP_NAME}-${platform^}"
    
    echo -e "${BLUE}🚀 发布 ${platform^} 更新${NC}"
    echo ""
    
    # 检查应用是否存在
    if ! code-push app list | grep -q "$app_name"; then
        echo -e "${RED}❌ 应用 ${app_name} 不存在${NC}"
        echo ""
        echo -e "${YELLOW}请先创建应用:${NC}"
        echo "code-push app add ${app_name} ${platform} react-native"
        echo ""
        read -p "按回车键返回主菜单..."
        return
    fi
    
    # 选择部署环境
    echo -e "${YELLOW}选择部署环境:${NC}"
    echo "1) Staging (测试环境)"
    echo "2) Production (生产环境)"
    echo ""
    read -p "请选择 [1-2]: " env_choice
    
    case $env_choice in
        1) deployment="Staging" ;;
        2) deployment="Production" ;;
        *) 
            echo -e "${RED}无效选择${NC}"
            read -p "按回车键返回主菜单..."
            return
            ;;
    esac
    
    # 输入更新描述
    echo ""
    read -p "输入更新描述 (默认: 热更新): " description
    description=${description:-"热更新"}
    
    # 是否强制更新
    echo ""
    echo -e "${YELLOW}是否强制更新?${NC}"
    echo "1) 否 (用户可选择)"
    echo "2) 是 (强制更新)"
    read -p "请选择 [1-2]: " mandatory_choice
    
    case $mandatory_choice in
        1) mandatory="false" ;;
        2) mandatory="true" ;;
        *) mandatory="false" ;;
    esac
    
    # 执行发布
    echo ""
    echo -e "${BLUE}开始发布...${NC}"
    echo ""
    
    if code-push release-react "$app_name" "$platform" -d "$deployment" --description "$description" --mandatory "$mandatory"; then
        echo ""
        echo -e "${GREEN}✅ 发布成功!${NC}"
        echo ""
        echo -e "${YELLOW}查看发布历史:${NC}"
        code-push deployment history "$app_name" "$deployment" --displayAuthor
    else
        echo ""
        echo -e "${RED}❌ 发布失败!${NC}"
    fi
    
    echo ""
    read -p "按回车键返回主菜单..."
}

# 查看发布历史
show_release_history() {
    echo -e "${BLUE}📊 查看发布历史${NC}"
    echo ""
    
    local apps=($(code-push app list 2>/dev/null | grep "${APP_NAME}" | awk '{print $1}'))
    
    if [ ${#apps[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  没有找到相关应用${NC}"
        echo ""
        read -p "按回车键返回主菜单..."
        return
    fi
    
    # 选择应用
    if [ ${#apps[@]} -eq 1 ]; then
        selected_app=${apps[0]}
    else
        echo -e "${YELLOW}选择应用:${NC}"
        for i in "${!apps[@]}"; do
            echo "$((i+1))) ${apps[i]}"
        done
        echo ""
        read -p "请选择 [1-${#apps[@]}]: " app_choice
        
        if [[ "$app_choice" -ge 1 && "$app_choice" -le ${#apps[@]} ]]; then
            selected_app=${apps[$((app_choice-1))]}
        else
            echo -e "${RED}无效选择${NC}"
            read -p "按回车键返回主菜单..."
            return
        fi
    fi
    
    # 选择环境
    echo ""
    echo -e "${YELLOW}选择环境:${NC}"
    echo "1) Staging"
    echo "2) Production"
    read -p "请选择 [1-2]: " env_choice
    
    case $env_choice in
        1) deployment="Staging" ;;
        2) deployment="Production" ;;
        *)
            echo -e "${RED}无效选择${NC}"
            read -p "按回车键返回主菜单..."
            return
            ;;
    esac
    
    echo ""
    echo -e "${CYAN}应用: ${selected_app}${NC}"
    echo -e "${CYAN}环境: ${deployment}${NC}"
    echo ""
    
    code-push deployment history "$selected_app" "$deployment" --displayAuthor
    
    echo ""
    read -p "按回车键返回主菜单..."
}

# 回滚版本
rollback_release() {
    echo -e "${BLUE}⏪ 回滚版本${NC}"
    echo ""
    
    local apps=($(code-push app list 2>/dev/null | grep "${APP_NAME}" | awk '{print $1}'))
    
    if [ ${#apps[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  没有找到相关应用${NC}"
        echo ""
        read -p "按回车键返回主菜单..."
        return
    fi
    
    # 选择应用
    echo -e "${YELLOW}选择应用:${NC}"
    for i in "${!apps[@]}"; do
        echo "$((i+1))) ${apps[i]}"
    done
    echo ""
    read -p "请选择 [1-${#apps[@]}]: " app_choice
    
    if [[ "$app_choice" -ge 1 && "$app_choice" -le ${#apps[@]} ]]; then
        selected_app=${apps[$((app_choice-1))]}
    else
        echo -e "${RED}无效选择${NC}"
        read -p "按回车键返回主菜单..."
        return
    fi
    
    # 选择环境
    echo ""
    echo -e "${YELLOW}选择环境:${NC}"
    echo "1) Staging"
    echo "2) Production"
    read -p "请选择 [1-2]: " env_choice
    
    case $env_choice in
        1) deployment="Staging" ;;
        2) deployment="Production" ;;
        *)
            echo -e "${RED}无效选择${NC}"
            read -p "按回车键返回主菜单..."
            return
            ;;
    esac
    
    # 确认回滚
    echo ""
    echo -e "${RED}⚠️  警告: 即将回滚 ${selected_app} 的 ${deployment} 环境到上一个版本${NC}"
    echo ""
    read -p "确定继续吗? [y/N]: " confirm
    
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo ""
        if code-push rollback "$selected_app" "$deployment"; then
            echo -e "${GREEN}✅ 回滚成功!${NC}"
        else
            echo -e "${RED}❌ 回滚失败!${NC}"
        fi
    else
        echo -e "${YELLOW}已取消回滚${NC}"
    fi
    
    echo ""
    read -p "按回车键返回主菜单..."
}

# 管理部署环境
manage_deployments() {
    echo -e "${BLUE}⚙️  管理部署环境${NC}"
    echo ""
    
    echo -e "${YELLOW}选择操作:${NC}"
    echo "1) 查看所有环境"
    echo "2) 创建新环境"
    echo "3) 删除环境"
    echo ""
    read -p "请选择 [1-3]: " action
    
    case $action in
        1) list_deployments ;;
        2) add_deployment ;;
        3) remove_deployment ;;
        *) echo -e "${RED}无效选择${NC}" ;;
    esac
    
    echo ""
    read -p "按回车键返回主菜单..."
}

# 查看所有环境
list_deployments() {
    local apps=($(code-push app list 2>/dev/null | grep "${APP_NAME}" | awk '{print $1}'))
    
    for app in "${apps[@]}"; do
        echo -e "${CYAN}应用: ${app}${NC}"
        code-push deployment ls "$app"
        echo ""
    done
}

# 服务器状态
check_server_status() {
    echo -e "${BLUE}🔧 服务器状态检查${NC}"
    echo ""
    
    echo -e "${YELLOW}服务器地址:${NC} ${SERVER_URL}"
    echo ""
    
    # 检查服务器连通性
    if curl -s "${SERVER_URL}/api/v1/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 服务器在线${NC}"
    else
        echo -e "${RED}❌ 服务器离线或无法访问${NC}"
    fi
    
    # 检查登录状态
    echo ""
    echo -e "${YELLOW}当前用户:${NC}"
    if code-push whoami 2>/dev/null; then
        echo -e "${GREEN}✅ 已登录${NC}"
    else
        echo -e "${RED}❌ 未登录${NC}"
    fi
    
    echo ""
    read -p "按回车键返回主菜单..."
}

# 登录信息
show_login_info() {
    echo -e "${BLUE}🔧 登录信息${NC}"
    echo ""
    
    echo -e "${YELLOW}当前用户:${NC}"
    code-push whoami
    
    echo ""
    echo -e "${YELLOW}服务器地址:${NC} ${SERVER_URL}"
    
    echo ""
    echo -e "${YELLOW}重新登录:${NC}"
    echo "code-push login ${SERVER_URL}"
    
    echo ""
    read -p "按回车键返回主菜单..."
}

# 主循环
main() {
    check_dependencies
    
    while true; do
        show_banner
        show_menu
        read -r choice
        
        case $choice in
            1) list_apps ;;
            2) create_app ;;
            3) show_deployment_keys ;;
            4) release_update "android" ;;
            5) release_update "ios" ;;
            6) show_release_history ;;
            7) rollback_release ;;
            8) manage_deployments ;;
            9) echo "功能开发中..." && read -p "按回车键返回主菜单..." ;;
            10) check_server_status ;;
            11) show_login_info ;;
            0) 
                echo -e "${GREEN}👋 再见!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择，请重新输入${NC}"
                sleep 1
                ;;
        esac
    done
}

# 运行主程序
main