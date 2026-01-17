#!/bin/bash
#
# 将本地修改推送回模板仓库 (仅 subtree 模式)
#

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}推送修改到模板仓库...${NC}"

if [[ ! -d ".ai-collab" ]]; then
    echo -e "${RED}错误: 未找到 .ai-collab 目录${NC}"
    echo "此脚本仅适用于 subtree 模式"
    exit 1
fi

echo -e "${YELLOW}警告: 这将把 .ai-collab 目录的修改推送到模板仓库${NC}"
read -p "确认继续? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 1
fi

git subtree push --prefix=.ai-collab ai-collab-template main

echo -e "${GREEN}✓ 推送完成${NC}"
