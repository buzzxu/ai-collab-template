---
name: handoff
description: |
  生成交接文档并汇总进度，支持跨 AI 协作。
  Use when: AI 交接、生成交接文档、切换 AI。
  Triggers: "/handoff", "交接", "handoff to"
---

# /handoff - AI 交接

> 生成交接文档并汇总进度，支持跨 AI 协作
> 包含角色配置和任务分配建议

---

## 触发条件

用户说：
- "交接给 gemini"
- "handoff to gemini"
- "/handoff gemini"
- "让 gemini 接手"

---

## 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `<target-ai>` | 目标 AI (必需) | `gemini`, `codex`, `claude` |
| `--tasks=<ids>` | 建议交接的任务 (可选) | `--tasks=FE-1.7,FE-1.9` |
| `--module=<mod>` | 限定模块 (可选) | `--module=frontend` |

---

## 执行流程

### Step 1: 强制读取任务状态 (关键)

> **重要**: 此步骤必须在生成 session.md 之前执行，禁止跳过！

**必须读取**:
```bash
cat project/tasks/frontend.yaml
cat project/tasks/backend.yaml
cat project/tasks/docs.yaml
```

### Step 2: 收集当前状态

遍历 `project/tasks/*.yaml`，统计：

1. **进行中任务** (`status: in_progress`)
2. **待审计任务** (`status: completed` 且 `requires_audit: true`)
3. **下一步建议** (`status: pending` 且依赖已满足)
4. **整体进度** - 统计各模块的完成率

### Step 3: 生成 session.md

写入 `.context/session.md`：

```markdown
# 会话交接 - {日期}

> **Trace ID**: HANDOFF-{日期}-{时间戳}
> **交接者**: {当前AI}
> **接收者**: {目标AI}

---

## 1. 目标 AI 简介

**角色**: {目标AI name}
**能力**: {capabilities 列表}

---

## 2. 当前进度

### 整体统计

| 模块 | 完成 | 总数 | 进度 |
|------|------|------|------|
| Frontend | {n} | {total} | {percent}% |
| Backend | {n} | {total} | {percent}% |
| Docs | {n} | {total} | {percent}% |

### 进行中任务

| 任务 | 名称 | 负责人 |
|------|------|--------|
{列出 in_progress 任务}

---

## 3. 为 {目标AI} 准备的任务

### 建议实现

| 任务 | 名称 | 优先级 |
|------|------|--------|
{按优先级排序的 pending 任务}

---

*Handoff by {当前AI} | {日期}*
```

### Step 4: 输出提示

```
## 交接完成

交接文档已生成: .context/session.md

### 目标 AI: {name}

**能力**: {capabilities}

### 摘要

| 模块 | 进度 |
|------|------|
| Frontend | {n}/{total} ({percent}%) |
| Backend | {n}/{total} ({percent}%) |

请通知 {目标AI} 读取 .context/session.md 继续工作。
```

---

## 接收交接 (作为目标 AI)

当你是被交接的 AI 时：

### Step 1: 读取交接文档

```bash
cat .context/session.md
cat MEMORY.md
```

### Step 2: 确认接收

输出：
```
## 交接确认

已接收来自 {交接者} 的交接。

### 当前状态

- 为我准备的任务: {n} 个
- 建议下一步: {任务ID}

准备好后请告诉我要做什么。
```
