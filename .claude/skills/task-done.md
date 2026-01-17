# /task-done - 完成任务

> 完成指定任务，验证验收条件并更新状态为 completed
> 支持灵活角色配置，自动确定审计者

---

## 触发条件

用户说：
- "完成 FE-1.5"
- "done FE-1.5"
- "/task-done FE-1.5"
- "/task-done FE-1.5 --skip-audit"
- "完成了" (自动识别当前 in_progress 的任务)

---

## 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `<task-id>` | 任务 ID (可选，默认当前任务) | `FE-1.5` |
| `--skip-audit` | 跳过审计要求 (需确认) | `--skip-audit` |
| `--audit-by=<ai>` | 覆盖审计者 | `--audit-by=claude` |

---

## Claude Code 执行流程

### Step 1: 确定任务

如果用户指定了任务 ID，使用该 ID。

如果用户只说"完成了"，读取任务文件找到 `status: in_progress` 且 `assignee: claude` 的任务。

### Step 2: 执行验收检查

遍历 `done_when` 列表，逐项检查：

| 类型 | 检查方法 |
|------|----------|
| `file_exists` | 使用 Glob 或 Read 检查文件是否存在 |
| `export_exists` | 使用 Grep 检查导出语句 |
| `content_match` | 使用 Grep 检查内容模式 |
| `shell_check` | 使用 Bash 执行命令，检查退出码 |
| `test_pass` | 使用 Bash 执行测试命令 |

### Step 3: 处理检查结果

**全部通过**：继续 Step 4

**有失败项**：
```
## 验收失败

任务: {id} - {name}

### 检查结果

- [x] file1 存在
- [ ] file2 存在 ← 失败
- [ ] 导出检查 ← 未检查

请修复后重新执行 /task-done {id}
```
中止操作，不更新状态。

### Step 4: 更新状态

修改任务字段：
```yaml
status: completed
completed_at: {当前日期 YYYY-MM-DD}
```

保存文件。

### Step 5: 确定审计者 (如需要)

如果 `requires_audit` 为 true (按优先级确定):

```
final_requires_audit =
  任务级 requires_audit ??
  模块级 defaults.requires_audit ??
  true

final_audit_by =
  命令行 --audit-by ||
  任务级 audit_by ||
  模块级 defaults.audit_by ||
  全局 roles.yaml workflows.modules.{module}.audit ||
  根据 audit_rules.matrix[assignee] 自动选择
```

**交叉审计验证**:
- 检查 `roles.yaml` 中 `audit_rules.cross_audit` 是否为 true
- 如为 true，确保 `final_audit_by != assignee`
- 如冲突，从 `audit_rules.matrix[assignee]` 选择第一个可用审计者

### Step 6: 触发审计 (如需要)

如果需要审计：

1. 创建 `.context/session.md`
2. 写入审计请求：

```markdown
# 审计请求 - {日期}

> **Trace ID**: AUDIT-{日期}-{任务ID}
> **任务**: {id} - {name}
> **实现者**: {assignee}
> **审计者**: {final_audit_by}

## 审计范围

{列出任务涉及的主要文件}

## 验收已通过

{列出 done_when 检查结果}

## 请审计

- 代码质量
- 安全性
- 架构合规性

## 审计指南

参考 `project/roles.yaml` 中的审计规则
```

3. 提示用户需要审计

### Step 7: 输出结果

```
## 任务完成: {id} - {name}

### 验收结果

- [x] 检查项 1
- [x] 检查项 2
- [x] 检查项 3

**实现者**: {assignee}
**状态**: completed
**完成时间**: {日期}

{如需审计}
---
### 审计要求

**审计者**: {final_audit_by} (来源: {配置来源})
审计请求已写入 .context/session.md
```

---

## SOP (Gemini / Codex / 其他 AI)

### Step 1: 定位任务

读取任务文件，找到对应任务。

### Step 2: 执行验收检查

根据 `done_when` 类型执行检查：

**file_exists**:
```bash
ls {path}
```

**export_exists**:
```bash
grep -E "export.*(function|const|class)?\s*{export}" {file}
```

**content_match**:
```bash
grep -E "{pattern}" {file}
```

**shell_check**:
```bash
{command}
echo "Exit code: $?"
```

### Step 3: 记录结果

如有失败项，输出失败详情并停止。

### Step 4: 更新状态

编辑任务文件：
- `status: completed`
- `completed_at: {当前日期}`

### Step 5: 确定审计者

按优先级读取配置：
1. 任务级 `audit_by`
2. 模块级 `defaults.audit_by`
3. 全局 `roles.yaml` 的 `workflows.modules.{module}.audit`
4. `audit_rules.matrix[assignee]` 的第一个值

### Step 6: 处理审计

如 `requires_audit: true`：
- 创建 `.context/session.md` 写入审计请求
- 确保审计者与实现者不同 (交叉审计)
- 提示需要指定 AI 审计

---

## 错误处理

| 错误 | 处理 |
|------|------|
| 任务不存在 | 提示检查 ID |
| 任务非 in_progress | 提示当前状态，询问是否强制完成 |
| 验收失败 | 列出失败项，不更新状态 |
| shell_check 超时 | 提示命令超时，建议手动检查 |
| 无可用审计者 | 警告交叉审计规则冲突，建议手动指定 |

---

## 示例

### 示例 1: 标准完成

**输入**: `完成 FE-1.5`

**输出**:

```
## 任务完成: FE-1.5 - Pinia 状态管理

### 验收结果

- [x] src/stores/index.ts 存在
- [x] src/stores/theme.ts 存在
- [x] theme.ts 导出 useThemeStore

**实现者**: codex
**状态**: completed
**完成时间**: 2026-01-17

---
### 审计要求

**审计者**: gemini (来源: 模块默认)
审计请求已写入 .context/session.md
```

### 示例 2: 跳过审计

**输入**: `/task-done DOC-1 --skip-audit`

**输出**:

```
## 任务完成: DOC-1 - 文档编写

...

**状态**: completed (审计已跳过)
```
