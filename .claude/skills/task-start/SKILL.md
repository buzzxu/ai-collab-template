---
name: task-start
description: |
  开始指定任务，检查依赖并更新状态为 in_progress。
  Use when: 开始执行任务、启动任务、更新任务状态。
  Triggers: "/task-start", "开始任务", "start task"
---

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

---

## 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `<task-id>` | 任务 ID (必需) | `FE-1.5` |
| `--assignee=<ai>` | 指定实现者 (覆盖默认) | `--assignee=codex` |
| `--audit-by=<ai>` | 指定审计者 (覆盖默认) | `--audit-by=claude` |

---

## 执行流程

### Step 1: 解析参数

根据 ID 前缀确定任务文件：
- `FE-*` → `project/tasks/frontend.yaml`
- `BE-*` → `project/tasks/backend.yaml`
- `DOC-*` → `project/tasks/docs.yaml`
- `INFRA-*` → `project/tasks/infra.yaml`

### Step 2: 检查依赖

如果任务有 `depends_on` 字段：
1. 遍历依赖列表
2. 检查每个依赖任务的 `status` 是否为 `completed`
3. 如有未完成依赖，输出警告并询问是否继续

### Step 3: 更新状态

修改任务字段：
```yaml
status: in_progress
assignee: {final_assignee}
```

### Step 4: 输出任务信息

```
## 开始任务: {id} - {name}

**优先级**: {priority}
**实现者**: {final_assignee}
**审计者**: {final_audit_by}
**依赖**: {depends_on 或 "无"}

### 验收标准

{遍历 done_when，每项一行，用 - [ ] 格式}

### 备注

{notes 或 "无"}

---
任务已开始，状态更新为 in_progress
```

---

## 错误处理

| 错误 | 处理 |
|------|------|
| 任务 ID 不存在 | 提示用户检查 ID，列出可用任务 |
| 任务已是 in_progress | 提示已在进行中，询问是否重新分配 |
| 任务已 completed | 提示已完成，询问是否重新开启 |
| 依赖未满足 | 列出未完成的依赖，询问是否强制开始 |

---

## 示例

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

### 备注

Axios 1.13.2 已安装，需封装

---
任务已开始，状态更新为 in_progress
```
