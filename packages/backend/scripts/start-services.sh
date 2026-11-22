#!/bin/bash

# 快速启动脚本
# 启动Docker服务及宿主机业务微服务

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "================================================"
echo "  启动所有服务"
echo "================================================"

# 启动Docker依赖服务
echo ""
echo ">>> 构建并启动Docker服务..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" up -d --build

echo ""
echo "================================================"
echo "  等待依赖服务启动..."
echo "================================================"

# 等待MySQL启动
echo "等待MySQL启动..."
sleep 10

# 等待Nacos启动
echo "等待Nacos启动..."
sleep 15

# 等待xxl-job启动
echo "等待xxl-job启动..."
sleep 10

echo ""
echo "================================================"
echo "  检查Docker服务状态"
echo "================================================"

docker compose -f "$PROJECT_ROOT/docker-compose.yml" ps

echo ""
echo "================================================"
echo "  启动后端微服务"
echo "================================================"

# Backend JARs run on the host, so use the host-published dependency ports.
export NACOS_IP=127.0.0.1
export NACOS_PORT=8848
export CARING_MYSQL_IP=127.0.0.1
export CARING_MYSQL_PORT=3307
export CARING_REDIS_IP=127.0.0.1
export CARING_REDIS_PORT=6379

# 检查是否已编译
echo ""
echo ">>> 检查编译状态..."
if [ ! -f "$PROJECT_ROOT/caring-gateway/caring-gateway-server/target/caring-gateway-server.jar" ]; then
    echo ">>> 未检测到编译产物，开始编译..."
    cd "$PROJECT_ROOT"
    mvn clean package -DskipTests
    echo ">>> 编译完成"
else
    echo ">>> 检测到编译产物，跳过编译"
fi

# 定义服务列表（按启动顺序）
SERVICES=(
    "caring-file/caring-file-server/target/caring-file-server.jar"
    "caring-ai/caring-ai-server/target/caring-ai-server.jar"
    "caring-cms/caring-cms-server/target/caring-cms-server.jar"
    "caring-msgs/caring-msgs-server/target/caring-msgs-server.jar"
    "caring-nursing/caring-nursing-server/target/caring-nursing-server.jar"
    "caring-wx/caring-wx-server/target/caring-wx-server.jar"
)

# 启动微服务
cd "$PROJECT_ROOT"
for service in "${SERVICES[@]}"; do
    if [ -f "$service" ]; then
        echo ""
        echo ">>> 启动服务: $service"
        nohup java -jar "$service" > "logs/$(basename "$service" .jar).log" 2>&1 &
        echo ">>> 服务已启动，PID: $!"
        sleep 5
    else
        echo ">>> 警告: 服务文件不存在: $service"
    fi
done

echo ""
echo "================================================"
echo "  服务访问地址"
echo "================================================"
echo "  MySQL:     localhost:3307"
echo "  Nacos:     http://localhost:8848/nacos (nacos/nacos)"
echo "  Redis:     localhost:6379"
echo "  XXL-Job:   http://localhost:8080/xxl-job-admin (admin/123456)"
echo "  Nginx:     http://localhost:8082"
echo "  网关API:   http://localhost:18760/api"
echo "  API文档:   http://localhost:18760/api/doc.html"
echo "================================================"

echo ""
echo ">>> 查看微服务日志: tail -f logs/*.log"
echo ">>> 停止所有服务: ./scripts/stop-services.sh"
echo "================================================"

echo ""
echo "如果xxl-job无法连接数据库，请运行以下命令手动创建数据库："
echo "  docker exec -i caring-mysql mysql -uroot -pchange-this-password < config/sql/xxl-job.sql"
echo "================================================"