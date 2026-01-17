# /handoff - AI 交接

> 生成交接文档并汇总进度，支持跨 AI 协作
> 包含角色配置和任务分配建议

---

## 触发条件

用户说：
- "交接给 gemini"
- "handoff to gemini"
- "/handoff gemini"
- "/handoff codex --tasks=FE-1.7,FE-1.9"
- "让 gemini 接手"

---

## 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `<target-ai>` | 目标 AI (必需) | `gemini`, `codex`, `claude` |
| `--tasks=<ids>` | 建议交接的任务 (可选) | `--tasks=FE-1.7,FE-1.9` |
| `--module=<mod>` | 限定模块 (可选) | `--module=frontend` |

---

## Claude Code 执行流程

### Step 1: 验证目标 AI

读取 `project/roles.yaml`，验证目标 AI 存在于 `roles` 列表中。

获取目标 AI 的能力:
```yaml
roles:
  gemini:
    capabilities: [review, research, audit, plan]
```

### Step 2: 收集当前状态

遍历 `project/tasks/*.yaml`，统计：

1. **进行中任务** (`status: in_progress`)
2. **待审计任务** (`status: completed` 且 `requires_audit: true`)
3. **下一步建议** (`status: pending` 且依赖已满足)
4. **整体进度** (各模块完成率)

### Step 3: 智能任务匹配

根据 `roles.yaml` 中目标 AI 的 `capabilities`，筛选适合的待办任务:

```
# 如果目标 AI 有 implement 能力
→ 建议 pending 的实现任务

# 如果目标 AI 有 audit 能力
→ 建议待审计的任务

# 如果目标 AI 有 plan 能力
→ 建议规划相关任务
```

### Step 4: 生成 session.md

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
**MBTI**: {mbti 列表}

---

## 2. 当前进度

| 模块 | 完成 | 总数 | 进度 |
|------|------|------|------|
| ... | ... | ... | ...% |

---

## 3. 为 {目标AI} 准备的任务

### 待审计
{audit_by 为目标 AI 的任务}

### 建议实现
{按能力匹配的任务}

---

## 4. 快速上手

```bash
cat project/roles.yaml
cat project/tasks/{module}.yaml
```

---

*Handoff by {当前AI} | {日期}*
```

### Step 5: 输出提示

```
## 交接完成

交接文档已生成: .context/session.md

### 目标 AI: {name}

**能力**: {capabilities}

### 为 {目标AI} 准备的任务

- 待审计: {n} 个任务
- 建议实现: {n} 个任务

请通知 {目标AI} 读取 .context/session.md 继续工作。
```

---

## SOP (Gemini / Codex / 其他 AI)

### Step 1: 读取配置

```bash
cat project/roles.yaml
cat project/tasks/*.yaml
```

### Step 2: 统计状态

手动统计各状态数量。

### Step 3: 确定目标 AI 任务

根据目标 AI 的能力匹配任务。

### Step 4: 写入 session.md

创建 `.context/session.md`，按格式填写。

---

## 接收交接 (作为目标 AI)

### Step 1: 读取交接文档

```bash
cat .context/session.md
cat project/roles.yaml
```

### Step 2: 确认接收

输出：
```
## 交接确认

已接收来自 {交接者} 的交接。

### 我的角色

**能力**: {capabilities}

### 当前状态

- 为我准备的任务: {n} 个

准备好后请告诉我要做什么。
```

---

## 示例

**输入**: `/handoff gemini`

**输出**:

```
## 交接完成

交接文档已生成: .context/session.md

### 目标 AI: Gemini Pro

**能力**: review, research, audit, plan

### 为 Gemini 准备的任务

- 待审计: 1 个任务
- 建议实现: 0 个 (无 implement 能力)

请通知 Gemini 读取 .context/session.md 继续工作。
```
