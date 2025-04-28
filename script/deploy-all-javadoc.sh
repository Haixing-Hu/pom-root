#!/bin/bash
#
# 脚本名称：deploy-all-javadoc.sh
# 功能描述：按照project-list.txt中列出的项目顺序依次生成并发布javadoc文档
# 作者：Claude
# 创建日期：2024-04-11
#

# 设置环境变量
USER=dev
HOST=dev.qubit.ltd
PORT=22222
URL_PREFIX=https://dev.qubit.ltd/javadoc
PROJECT_LIST_FILE=$(dirname "$0")/project-list.txt
JAVA_COMMON_DIR=$(cd $(dirname "$0")/../.. && pwd)

# 显示脚本使用信息
show_usage() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -h, --help        显示帮助信息"
    echo "  -n, --dry-run     仅显示要执行的操作，不实际执行"
    echo ""
    echo "功能: 按照 project-list.txt 中列出的项目顺序，依次生成并发布javadoc文档"
    echo "      文档将发布到 ${URL_PREFIX}/<项目名>/ 路径下"
}

# 解析命令行参数
DRY_RUN=false
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "未知选项: $1"
            show_usage
            exit 1
            ;;
    esac
done

# 检查项目列表文件是否存在
if [ ! -f "$PROJECT_LIST_FILE" ]; then
    echo "错误: 项目列表文件未找到: $PROJECT_LIST_FILE"
    exit 1
fi

# 读取项目列表
echo "正在读取项目列表: $PROJECT_LIST_FILE"
PROJECTS=$(cat "$PROJECT_LIST_FILE")

# 显示即将处理的项目
echo "将处理以下项目:"
echo "$PROJECTS"
echo ""

# 创建日志目录
LOG_DIR="$JAVA_COMMON_DIR/pom-root/javadoc-logs"
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/javadoc-deploy-$(date +%Y%m%d-%H%M%S).log"
    echo "日志文件: $LOG_FILE"
    echo "开始执行时间: $(date)" > "$LOG_FILE"
fi

# 处理每个项目
for PROJECT in $PROJECTS; do
    echo ""
    echo "========================================================"
    echo "处理项目: $PROJECT"
    echo "========================================================"
    
    # 检查项目目录是否存在
    PROJECT_DIR="$JAVA_COMMON_DIR/$PROJECT"
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "警告: 项目目录不存在: $PROJECT_DIR"
        echo "跳过此项目..."
        continue
    fi
    
    # 进入项目目录
    echo "进入项目目录: $PROJECT_DIR"
    if [ "$DRY_RUN" = false ]; then
        cd "$PROJECT_DIR" || { echo "无法进入项目目录: $PROJECT_DIR"; continue; }
    fi
    
    # 生成javadoc
    echo "生成javadoc文档..."
    if [ "$DRY_RUN" = false ]; then
        mvn clean generate-resources javadoc:javadoc >> "$LOG_FILE" 2>&1
        if [ $? -ne 0 ]; then
            echo "错误: 生成javadoc文档失败!"
            echo "查看日志文件: $LOG_FILE"
            continue
        fi
    fi
    
    # 准备目标目录
    TARGET_DIR="/var/www/html/javadoc/${PROJECT}"
    echo "准备目标目录: $TARGET_DIR"
    if [ "$DRY_RUN" = false ]; then
        ssh -p ${PORT} ${USER}@${HOST} "sudo rm -rf ${TARGET_DIR}" >> "$LOG_FILE" 2>&1
        ssh -p ${PORT} ${USER}@${HOST} "sudo mkdir -p ${TARGET_DIR}" >> "$LOG_FILE" 2>&1
        ssh -p ${PORT} ${USER}@${HOST} "sudo chown -R dev:developer ${TARGET_DIR}" >> "$LOG_FILE" 2>&1
    fi
    
    # 上传javadoc文件
    echo "上传javadoc文件..."
    if [ "$DRY_RUN" = false ]; then
        scp -P ${PORT} -r target/site/apidocs/* ${USER}@${HOST}:${TARGET_DIR}/ >> "$LOG_FILE" 2>&1
        if [ $? -ne 0 ]; then
            echo "错误: 上传javadoc文件失败!"
            echo "查看日志文件: $LOG_FILE"
            continue
        fi
    fi
    
    # 设置权限
    echo "设置权限..."
    if [ "$DRY_RUN" = false ]; then
        ssh -p ${PORT} ${USER}@${HOST} "chmod a+rx ${TARGET_DIR}" >> "$LOG_FILE" 2>&1
        ssh -p ${PORT} ${USER}@${HOST} "chmod -R a+r ${TARGET_DIR}" >> "$LOG_FILE" 2>&1
    fi
    
    # 输出URL
    echo "成功: javadoc已发布到 ${URL_PREFIX}/${PROJECT}/"
done

# 输出摘要
echo ""
echo "========================================================"
echo "所有项目处理完成!"
echo "========================================================"

if [ "$DRY_RUN" = false ]; then
    echo "结束执行时间: $(date)" >> "$LOG_FILE"
    echo "查看完整日志: $LOG_FILE"
else
    echo "这是一个模拟运行，未执行任何实际操作。"
fi

echo "javadoc文档已发布到: ${URL_PREFIX}/<项目名>/" 