---
name: task-done
description: |
  完成指定任务，验证验收条件并更新状态为 completed。
  Use when: 完成任务、验收检查、更新任务状态。
  Triggers: "/task-done", "完成任务", "done task"
---

# /task-done - 完成任务

> 完成指定任务，验证验收条件并更新状态为 completed
> 支持灵活角色配置，自动确定审计者

---

## 触发条件

用户说：
- "完成 FE-1.5"
- "done FE-1.5"
- "/task-done FE-1.5"
- "完成了" (自动识别当前 in_progress 的任务)

---

## 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `<task-id>` | 任务 ID (可选，默认当前任务) | `FE-1.5` |
| `--skip-audit` | 跳过审计要求 (需确认) | `--skip-audit` |
| `--audit-by=<ai>` | 覆盖审计者 | `--audit-by=claude` |

---

## 执行流程

### Step 1: 确定任务

如果用户指定了任务 ID，使用该 ID。

如果用户只说"完成了"，找到 `status: in_progress` 且 `assignee: claude` 的任务。

### Step 2: 执行验收检查

遍历 `done_when` 列表，逐项检查：

| 类型 | 检查方法 |
|------|----------|
| `file_exists` | 使用 Glob 或 Read 检查文件是否存在 |
| `export_exists` | 使用 Grep 检查导出语句 |
| `content_match` | 使用 Grep 检查内容模式 |
| `shell_check` | 使用 Bash 执行命令，检查退出码 |

### Step 3: 处理检查结果

**全部通过**：继续 Step 4

**有失败项**：
```
## 验收失败

任务: {id} - {name}

### 检查结果

- [x] src/stores/index.ts 存在
- [ ] src/stores/theme.ts 存在 ← 失败

请修复后重新执行 /task-done {id}
```
中止操作，不更新状态。

### Step 4: 更新状态

修改任务字段：
```yaml
status: completed
completed_at: {当前日期 YYYY-MM-DD}
```

### Step 5: 输出结果

```
## 任务完成: {id} - {name}

### 验收结果

- [x] src/stores/index.ts 存在
- [x] src/stores/theme.ts 存在
- [x] theme.ts 导出 useThemeStore
- [x] pnpm type-check 通过

**实现者**: {assignee}
**状态**: completed
**完成时间**: {日期}

{如需审计}
---
### 审计要求

**审计者**: {final_audit_by}
审计请求已写入 .context/session.md
```

---

## 错误处理

| 错误 | 处理 |
|------|------|
| 任务不存在 | 提示检查 ID |
| 任务非 in_progress | 提示当前状态，询问是否强制完成 |
| 验收失败 | 列出失败项，不更新状态 |
| shell_check 超时 | 提示命令超时，建议手动检查 |

---

## 示例

**输入**: `完成 FE-1.5`

**输出**:

```
## 任务完成: FE-1.5 - Pinia 状态管理

### 验收结果

- [x] src/stores/index.ts 存在
- [x] src/stores/theme.ts 存在
- [x] theme.ts 导出 useThemeStore
- [x] pnpm type-check 通过

**实现者**: codex
**状态**: completed
**完成时间**: 2026-01-17

---
### 审计要求

**审计者**: gemini (来源: 模块默认)
审计请求已写入 .context/session.md
```
