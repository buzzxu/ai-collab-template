#!/bin/bash
#
# 从模板仓库同步更新 (仅 subtree 模式)
#

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}从模板仓库同步更新...${NC}"

if [[ ! -d ".ai-collab" ]]; then
    echo -e "${RED}错误: 未找到 .ai-collab 目录${NC}"
    echo "此脚本仅适用于 subtree 模式"
    exit 1
fi

git subtree pull --prefix=.ai-collab ai-collab-template main --squash

echo -e "${GREEN}✓ 同步完成${NC}"
