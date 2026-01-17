# /task-start - 开始任务

> 开始指定任务，检查依赖并更新状态为 in_progress
> 支持灵活角色分配 (任务级 > 模块级 > 全局级)

---

## 触发条件

用户说：
- "开始 FE-1.5"
- "start FE-1.5"
- "/task-start FE-1.5"
- "/task-start FE-1.5 --assignee=codex"
- "/task-start FE-1.5 --assignee=codex --audit-by=claude"

---

## 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `<task-id>` | 任务 ID (必需) | `FE-1.5` |
| `--assignee=<ai>` | 指定实现者 (覆盖默认) | `--assignee=codex` |
| `--audit-by=<ai>` | 指定审计者 (覆盖默认) | `--audit-by=claude` |

---

## Claude Code 执行流程

### Step 1: 解析参数

从用户输入提取：
- 任务 ID (如 `FE-1.5`)
- 可选参数 `--assignee` 和 `--audit-by`

根据 ID 前缀确定任务文件 (参考 `_schema.yaml` 的 `module_mapping`)。

### Step 2: 读取配置 (三级配置)

**配置优先级**: 命令行参数 > 任务级 > 模块级 defaults > 全局 roles.yaml

1. **读取全局配置**:
   ```
   project/roles.yaml → workflows.modules.{module}
   ```

2. **读取模块默认**:
   ```yaml
   # {module}.yaml
   defaults:
     implement_by: codex
     audit_by: gemini
   ```

3. **读取任务级配置**:
   ```yaml
   TASK-1.5:
     assignee: claude  # 任务级覆盖
     audit_by: gemini
   ```

4. **应用命令行参数**:
   ```
   --assignee=codex  # 最高优先级
   ```

### Step 3: 确定最终分配

```
final_assignee =
  命令行 --assignee ||
  任务级 assignee ||
  模块级 defaults.implement_by ||
  全局 workflows.modules.{module}.implement ||
  当前 AI (claude)

final_audit_by =
  命令行 --audit-by ||
  任务级 audit_by ||
  模块级 defaults.audit_by ||
  全局 workflows.modules.{module}.audit ||
  null
```

### Step 4: 检查依赖

如果任务有 `depends_on` 字段：
1. 遍历依赖列表
2. 检查每个依赖任务的 `status` 是否为 `completed`
3. 如有未完成依赖，输出警告并询问是否继续

### Step 5: 检查交叉审计规则

如果 `requires_audit: true`，检查 `project/roles.yaml` 中的 `audit_rules.matrix`:
- 确保 `final_audit_by` 不等于 `final_assignee` (交叉审计)
- 如违反规则，警告用户并建议调整

### Step 6: 更新状态

修改任务字段：
```yaml
status: in_progress
assignee: {final_assignee}
audit_by: {final_audit_by}  # 如有变更
```

保存文件。

### Step 7: 输出任务信息

```
## 开始任务: {id} - {name}

**优先级**: {priority}
**实现者**: {final_assignee} (来源: {配置来源})
**审计者**: {final_audit_by} (来源: {配置来源})
**依赖**: {depends_on 或 "无"}

### 验收标准

{遍历 done_when，每项一行，用 - [ ] 格式}

### 备注

{notes 或 "无"}

---
任务已开始，状态更新为 in_progress
```

---

## SOP (Gemini / Codex / 其他 AI)

如果你不是 Claude Code，请按以下步骤手动执行：

### Step 1: 确定任务文件

根据任务 ID 前缀找到对应文件 (参考 `_schema.yaml`)。

### Step 2: 读取配置文件

```bash
# 全局角色配置
cat project/roles.yaml

# 任务文件 (含模块默认配置)
cat project/tasks/{module}.yaml
```

### Step 3: 确定角色分配

按优先级确定实现者和审计者：

1. 检查任务级 `assignee` 和 `audit_by`
2. 检查模块级 `defaults.implement_by` 和 `defaults.audit_by`
3. 检查全局 `roles.yaml` 中 `workflows.modules.{module}`

### Step 4: 检查依赖

查看 `depends_on` 字段，确认所有依赖任务状态为 `completed`。

### Step 5: 验证交叉审计

确保实现者和审计者不是同一个 AI (除非 `requires_audit: false`)。

### Step 6: 更新状态

编辑文件，将任务的：
- `status` 改为 `in_progress`
- `assignee` 改为确定的实现者

### Step 7: 输出信息

告知用户任务详情、角色分配和验收标准。

---

## 错误处理

| 错误 | 处理 |
|------|------|
| 任务 ID 不存在 | 提示用户检查 ID，列出可用任务 |
| 任务已是 in_progress | 提示已在进行中，询问是否重新分配 |
| 任务已 completed | 提示已完成，询问是否重新开启 |
| 依赖未满足 | 列出未完成的依赖，询问是否强制开始 |
| 违反交叉审计 | 警告并建议调整审计者 |
| AI 无相应能力 | 警告 (参考 roles.yaml 的 capabilities) |

---

## 示例

### 示例 1: 使用默认配置

**输入**: `开始 FE-1.7`

**输出**:

```
## 开始任务: FE-1.7 - HTTP 客户端封装

**优先级**: P0
**实现者**: codex (来源: 模块默认)
**审计者**: gemini (来源: 模块默认)
**依赖**: FE-1.1 (已完成 ✓)

### 验收标准

- [ ] src/api/client.ts 存在
- [ ] client.ts 导出 apiClient
- [ ] 使用 import.meta.env 配置 baseURL

---
任务已开始，状态更新为 in_progress
```

### 示例 2: 命令行覆盖

**输入**: `/task-start FE-1.7 --assignee=claude --audit-by=codex`

**输出**:

```
## 开始任务: FE-1.7 - HTTP 客户端封装

**优先级**: P0
**实现者**: claude (来源: 命令行参数)
**审计者**: codex (来源: 命令行参数)
**依赖**: FE-1.1 (已完成 ✓)

...
```
