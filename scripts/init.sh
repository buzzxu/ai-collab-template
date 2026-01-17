#!/bin/bash
#
# AI Collab Template - 初始化脚本
# 用法: ./init.sh [项目名称] [选项]
#
# 选项:
#   --subtree    使用 git subtree 集成 (支持双向同步)
#   --copy       直接复制文件 (默认)
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认值
PROJECT_NAME=""
MODE="copy"
TEMPLATE_REPO="https://github.com/buzzxu/ai-collab-template.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"

# 帮助信息
show_help() {
    echo -e "${BLUE}AI Collab Template - 初始化脚本${NC}"
    echo ""
    echo "用法: $0 [项目名称] [选项]"
    echo ""
    echo "选项:"
    echo "  --subtree    使用 git subtree 集成 (支持双向同步)"
    echo "  --copy       直接复制文件 (默认)"
    echo "  --help       显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 my-project              # 复制模式"
    echo "  $0 my-project --subtree    # subtree 模式"
    echo ""
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --subtree)
            MODE="subtree"
            shift
            ;;
        --copy)
            MODE="copy"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            if [[ -z "$PROJECT_NAME" ]]; then
                PROJECT_NAME="$1"
            fi
            shift
            ;;
    esac
done

# 检查项目名称
if [[ -z "$PROJECT_NAME" ]]; then
    echo -e "${RED}错误: 请提供项目名称${NC}"
    show_help
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  AI Collab Template 初始化${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "项目名称: ${GREEN}$PROJECT_NAME${NC}"
echo -e "集成模式: ${GREEN}$MODE${NC}"
echo ""

# 创建目标目录
TARGET_DIR="$(pwd)/$PROJECT_NAME"

if [[ -d "$TARGET_DIR" ]]; then
    echo -e "${YELLOW}警告: 目录 $TARGET_DIR 已存在${NC}"
    read -p "是否覆盖? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消"
        exit 1
    fi
fi

mkdir -p "$TARGET_DIR"

# 复制模式
init_copy() {
    echo -e "${BLUE}[1/4] 复制模板文件...${NC}"

    # 复制 .claude 目录
    cp -r "$TEMPLATE_DIR/.claude" "$TARGET_DIR/"

    # 复制 project 目录
    cp -r "$TEMPLATE_DIR/project" "$TARGET_DIR/"

    # 创建 .context 目录
    mkdir -p "$TARGET_DIR/.context"
    touch "$TARGET_DIR/.context/.gitkeep"

    echo -e "${GREEN}✓ 模板文件复制完成${NC}"
}

# Subtree 模式
init_subtree() {
    echo -e "${BLUE}[1/4] 初始化 git subtree...${NC}"

    cd "$TARGET_DIR"

    # 初始化 git (如果需要)
    if [[ ! -d ".git" ]]; then
        git init
    fi

    # 添加远程仓库
    git remote add ai-collab-template "$TEMPLATE_REPO" 2>/dev/null || true

    # 添加 subtree
    git subtree add --prefix=.ai-collab ai-collab-template main --squash

    # 创建符号链接
    ln -sf .ai-collab/.claude .claude
    ln -sf .ai-collab/project project

    mkdir -p .context
    touch .context/.gitkeep

    echo -e "${GREEN}✓ Subtree 初始化完成${NC}"
    echo ""
    echo -e "${YELLOW}同步命令:${NC}"
    echo "  拉取更新: git subtree pull --prefix=.ai-collab ai-collab-template main --squash"
    echo "  推送更新: git subtree push --prefix=.ai-collab ai-collab-template main"
}

# 生成项目文件
generate_files() {
    echo -e "${BLUE}[2/4] 生成项目文件...${NC}"

    local DATE=$(date +%Y-%m-%d)

    # 生成 CLAUDE.md
    sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
        -e "s/{{PROJECT_DESCRIPTION}}/项目描述/g" \
        -e "s/{{FRONTEND_STACK}}/待定/g" \
        -e "s/{{BACKEND_STACK}}/待定/g" \
        -e "s/{{DATABASE_STACK}}/待定/g" \
        -e "s/{{DATE}}/$DATE/g" \
        -e "s/{{CODING_STANDARDS}}/待定/g" \
        "$TEMPLATE_DIR/templates/CLAUDE.md.template" > "$TARGET_DIR/CLAUDE.md"

    # 生成 MEMORY.md
    sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
        -e "s/{{PROJECT_DESCRIPTION}}/项目描述/g" \
        -e "s/{{REPO_URL}}/待定/g" \
        -e "s/{{FRONTEND_STACK}}/待定/g" \
        -e "s/{{BACKEND_STACK}}/待定/g" \
        -e "s/{{DATABASE_STACK}}/待定/g" \
        -e "s/{{CURRENT_PHASE}}/初始化/g" \
        -e "s/{{DATE}}/$DATE/g" \
        "$TEMPLATE_DIR/templates/MEMORY.md.template" > "$TARGET_DIR/MEMORY.md"

    # 生成 GEMINI.md
    sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
        -e "s/{{PROJECT_SPECIFIC_INFO}}/待补充/g" \
        -e "s/{{DATE}}/$DATE/g" \
        "$TEMPLATE_DIR/templates/GEMINI.md.template" > "$TARGET_DIR/GEMINI.md"

    echo -e "${GREEN}✓ 项目文件生成完成${NC}"
}

# 创建示例任务文件
create_sample_tasks() {
    echo -e "${BLUE}[3/4] 创建示例任务文件...${NC}"

    # 复制示例文件
    cp "$TARGET_DIR/project/tasks/_example.yaml" "$TARGET_DIR/project/tasks/main.yaml"

    # 更新 module_mapping
    sed -i 's/EX: example.yaml/MAIN: main.yaml/' "$TARGET_DIR/project/tasks/_schema.yaml" 2>/dev/null || \
    sed -i '' 's/EX: example.yaml/MAIN: main.yaml/' "$TARGET_DIR/project/tasks/_schema.yaml"

    echo -e "${GREEN}✓ 示例任务文件创建完成${NC}"
}

# 完成提示
show_complete() {
    echo -e "${BLUE}[4/4] 初始化完成!${NC}"
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  初始化成功!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "项目目录: ${BLUE}$TARGET_DIR${NC}"
    echo ""
    echo -e "${YELLOW}下一步:${NC}"
    echo "  1. cd $PROJECT_NAME"
    echo "  2. 编辑 CLAUDE.md, MEMORY.md, GEMINI.md 填入项目信息"
    echo "  3. 编辑 project/roles.yaml 调整角色配置"
    echo "  4. 编辑 project/tasks/*.yaml 添加任务"
    echo ""
    echo -e "${YELLOW}开始使用:${NC}"
    echo "  - 运行 /sync 查看进度"
    echo "  - 运行 /task-start <id> 开始任务"
    echo ""
}

# 主流程
case $MODE in
    copy)
        init_copy
        ;;
    subtree)
        init_subtree
        ;;
esac

generate_files
create_sample_tasks
show_complete
