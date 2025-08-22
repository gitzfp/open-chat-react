#!/bin/bash

# Code-Push-Server 本地部署脚本
# 用于快速搭建自托管的 CodePush 服务

echo "========================================="
echo "📦 Code-Push-Server 本地部署工具"
echo "========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker 未安装${NC}"
        echo "请先安装 Docker Desktop: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker 未运行${NC}"
        echo "请先启动 Docker Desktop"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker 已就绪${NC}"
}

# 创建项目目录
setup_directory() {
    echo -e "${BLUE}创建 CodePush 服务器目录...${NC}"
    
    CODEPUSH_DIR="$HOME/codepush-server"
    mkdir -p "$CODEPUSH_DIR"
    cd "$CODEPUSH_DIR"
    
    echo -e "${GREEN}✅ 目录创建完成: $CODEPUSH_DIR${NC}"
}

# 创建 Docker Compose 配置
create_docker_compose() {
    echo -e "${BLUE}创建 Docker Compose 配置...${NC}"
    
    cat > docker-compose.yml << 'EOF'
version: '3'

services:
  mysql:
    image: mysql:5.7
    container_name: codepush-mysql
    environment:
      MYSQL_ROOT_PASSWORD: root123456
      MYSQL_DATABASE: codepush
      MYSQL_USER: codepush
      MYSQL_PASSWORD: codepush123
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - codepush-network

  redis:
    image: redis:6-alpine
    container_name: codepush-redis
    ports:
      - "6379:6379"
    networks:
      - codepush-network

  codepush-server:
    image: lisong/code-push-server:latest
    container_name: codepush-server
    depends_on:
      - mysql
      - redis
    environment:
      NODE_ENV: production
      PORT: 3000
      DB_HOST: mysql
      DB_PORT: 3306
      DB_NAME: codepush
      DB_USERNAME: codepush
      DB_PASSWORD: codepush123
      REDIS_HOST: redis
      REDIS_PORT: 6379
      DOWNLOAD_URL: http://localhost:3000
      JWT_SECRET: your-secret-key-change-this
      ADMIN_USERNAME: admin
      ADMIN_PASSWORD: admin123
    ports:
      - "3000:3000"
    volumes:
      - storage_data:/data/storage
    networks:
      - codepush-network

volumes:
  mysql_data:
  storage_data:

networks:
  codepush-network:
    driver: bridge
EOF

    echo -e "${GREEN}✅ Docker Compose 配置创建完成${NC}"
}

# 创建环境配置文件
create_env_file() {
    echo -e "${BLUE}创建环境配置文件...${NC}"
    
    cat > .env << EOF
# CodePush Server 配置
SERVER_URL=http://localhost:3000
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_NAME=codepush
DB_USERNAME=codepush
DB_PASSWORD=codepush123

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379
EOF

    echo -e "${GREEN}✅ 环境配置文件创建完成${NC}"
}

# 创建管理脚本
create_management_scripts() {
    echo -e "${BLUE}创建管理脚本...${NC}"
    
    # 启动脚本
    cat > start.sh << 'EOF'
#!/bin/bash
echo "启动 CodePush Server..."
docker-compose up -d
echo "等待服务启动..."
sleep 10
echo ""
echo "✅ CodePush Server 已启动"
echo "🌐 管理界面: http://localhost:3000"
echo "👤 默认账号: admin"
echo "🔑 默认密码: admin123"
EOF
    chmod +x start.sh
    
    # 停止脚本
    cat > stop.sh << 'EOF'
#!/bin/bash
echo "停止 CodePush Server..."
docker-compose down
echo "✅ 服务已停止"
EOF
    chmod +x stop.sh
    
    # 查看日志脚本
    cat > logs.sh << 'EOF'
#!/bin/bash
docker-compose logs -f codepush-server
EOF
    chmod +x logs.sh
    
    # 重启脚本
    cat > restart.sh << 'EOF'
#!/bin/bash
./stop.sh
./start.sh
EOF
    chmod +x restart.sh
    
    echo -e "${GREEN}✅ 管理脚本创建完成${NC}"
}

# 创建客户端配置示例
create_client_config() {
    echo -e "${BLUE}创建客户端配置示例...${NC}"
    
    cat > client-config.js << 'EOF'
// React Native 客户端配置示例

import codePush from 'react-native-code-push';

// CodePush 配置选项
const codePushOptions = {
  // 部署密钥（从服务器获取）
  deploymentKey: 'YOUR_DEPLOYMENT_KEY',
  
  // 自托管服务器地址
  serverUrl: 'http://localhost:3000',
  
  // 检查更新频率
  checkFrequency: codePush.CheckFrequency.ON_APP_START,
  
  // 安装模式
  installMode: codePush.InstallMode.IMMEDIATE,
  
  // 更新对话框配置（可选）
  updateDialog: {
    title: '更新提示',
    mandatoryUpdateMessage: '发现新版本，需要更新后才能继续使用',
    mandatoryContinueButtonLabel: '立即更新',
    optionalUpdateMessage: '发现新版本，是否现在更新？',
    optionalInstallButtonLabel: '更新',
    optionalIgnoreButtonLabel: '稍后',
  },
};

// 包装你的根组件
export default codePush(codePushOptions)(App);
EOF

    echo -e "${GREEN}✅ 客户端配置示例创建完成${NC}"
}

# 创建使用说明
create_readme() {
    echo -e "${BLUE}创建使用说明...${NC}"
    
    cat > README.md << 'EOF'
# CodePush Server 本地部署

## 快速开始

### 1. 启动服务
```bash
./start.sh
```

### 2. 访问管理界面
- 地址: http://localhost:3000
- 账号: admin
- 密码: admin123

### 3. 停止服务
```bash
./stop.sh
```

## 管理命令

### 查看日志
```bash
./logs.sh
```

### 重启服务
```bash
./restart.sh
```

## 客户端集成

### 1. 安装 code-push-cli
```bash
npm install -g code-push-cli
```

### 2. 登录到自托管服务器
```bash
code-push login http://localhost:3000
```

### 3. 创建应用
```bash
# Android 应用
code-push app add MyApp-Android android react-native

# iOS 应用
code-push app add MyApp-iOS ios react-native
```

### 4. 查看部署密钥
```bash
code-push deployment ls MyApp-Android -k
code-push deployment ls MyApp-iOS -k
```

### 5. 发布更新
```bash
# 发布到 Staging 环境
code-push release-react MyApp-Android android -d Staging

# 发布到 Production 环境
code-push release-react MyApp-Android android -d Production
```

## 常用命令

### 查看发布历史
```bash
code-push deployment history MyApp-Android Staging
```

### 回滚版本
```bash
code-push rollback MyApp-Android Staging
```

### 清除发布历史
```bash
code-push deployment clear MyApp-Android Staging
```

## 配置说明

- 数据存储: MySQL 数据库
- 缓存: Redis
- 文件存储: 本地卷挂载
- 默认端口: 3000

## 故障排查

1. 如果无法访问，检查 Docker 是否正在运行
2. 如果数据库连接失败，等待几秒让 MySQL 完全启动
3. 查看日志: `./logs.sh`

## 生产环境部署建议

1. 修改默认密码
2. 使用 HTTPS
3. 配置备份策略
4. 使用外部数据库
5. 配置 CDN 加速下载
EOF

    echo -e "${GREEN}✅ 使用说明创建完成${NC}"
}

# 启动服务
start_server() {
    echo ""
    echo -e "${YELLOW}是否立即启动 CodePush Server？[Y/n]${NC}"
    read -r response
    
    if [[ "$response" != "n" && "$response" != "N" ]]; then
        echo -e "${BLUE}启动 CodePush Server...${NC}"
        docker-compose up -d
        
        echo ""
        echo -e "${GREEN}⏳ 等待服务启动（约 20 秒）...${NC}"
        sleep 20
        
        echo ""
        echo "========================================="
        echo -e "${GREEN}🎉 CodePush Server 部署成功！${NC}"
        echo "========================================="
        echo ""
        echo -e "${BLUE}访问信息：${NC}"
        echo "🌐 管理界面: http://localhost:3000"
        echo "👤 默认账号: admin"
        echo "🔑 默认密码: admin123"
        echo ""
        echo -e "${YELLOW}下一步：${NC}"
        echo "1. 访问管理界面并修改默认密码"
        echo "2. 安装 code-push-cli: npm install -g code-push-cli"
        echo "3. 登录服务器: code-push login http://localhost:3000"
        echo "4. 创建应用并获取部署密钥"
        echo ""
        echo -e "${GREEN}管理脚本位置: $CODEPUSH_DIR${NC}"
    else
        echo ""
        echo -e "${YELLOW}稍后启动服务，请运行：${NC}"
        echo "cd $CODEPUSH_DIR && ./start.sh"
    fi
}

# 主流程
main() {
    echo -e "${BLUE}开始部署 Code-Push-Server...${NC}"
    echo ""
    
    check_docker
    setup_directory
    create_docker_compose
    create_env_file
    create_management_scripts
    create_client_config
    create_readme
    start_server
}

# 运行主流程
main