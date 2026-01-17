# AI Collab Template

> 多 AI 协作工作流模板 - 支持 Claude / Gemini / Codex 等 AI 协同工作

---

## 特性

- **灵活角色配置**: 三级配置优先级 (命令行 > 任务级 > 模块级 > 全局)
- **MBTI 人格框架**: ENTJ(规划) / ISTJ(实现) / ENTP(审计) 分工
- **交叉审计规则**: 自动确保实现者和审计者不同
- **通用调用协议**: 支持非 Claude 的 AI 通过 SOP 执行
- **双向同步**: 支持 git subtree 同步优化

---

## 快速开始

### 方式 1: 使用 GitHub Template (推荐)

1. 点击 "Use this template" 创建新仓库
2. 克隆新仓库到本地
3. 运行初始化脚本:

```bash
cd your-project
./scripts/init.sh your-project-name
```

### 方式 2: 复制文件

```bash
# 克隆模板
git clone https://github.com/buzzxu/ai-collab-template.git

# 初始化新项目
cd ai-collab-template
./scripts/init.sh /path/to/your-project
```

### 方式 3: Git Subtree (支持双向同步)

```bash
# 在现有项目中添加 subtree
cd your-project
./scripts/init.sh . --subtree

# 之后可以双向同步
./scripts/sync-upstream.sh   # 拉取模板更新
./scripts/push-upstream.sh   # 推送本地优化
```

---

## 目录结构

```
ai-collab-template/
├── .claude/
│   └── skills/
│       ├── task-start.md    # 开始任务
│       ├── task-done.md     # 完成任务
│       ├── handoff.md       # AI 交接
│       └── sync.md          # 进度同步
│
├── project/
│   ├── roles.yaml           # AI 角色配置
│   └── tasks/
│       ├── _schema.yaml     # 任务 Schema
│       └── _example.yaml    # 示例任务
│
├── templates/
│   ├── CLAUDE.md.template   # Claude 指南模板
│   ├── MEMORY.md.template   # 长期记忆模板
│   └── GEMINI.md.template   # Gemini 指南模板
│
├── scripts/
│   ├── init.sh              # 初始化脚本
│   ├── sync-upstream.sh     # 同步模板更新
│   └── push-upstream.sh     # 推送本地优化
│
└── README.md
```

---

## 核心概念

### 角色配置 (roles.yaml)

```yaml
roles:
  claude:
    capabilities: [implement, review, plan, document, audit]
    mbti: [ENTJ, ISTJ, ENTP]
  gemini:
    capabilities: [review, research, audit, plan]
    mbti: [ENTP, ENTJ]
  codex:
    capabilities: [implement, test, refactor]
    mbti: [ISTJ]

workflows:
  modules:
    frontend:
      implement: codex
      audit: gemini
    backend:
      implement: claude
      audit: gemini
```

### 任务文件 (tasks/*.yaml)

```yaml
version: "2.1"
module: frontend

defaults:
  implement_by: codex
  audit_by: gemini
  requires_audit: true

tasks:
  FE-1.1:
    name: "功能实现"
    status: pending
    priority: P0
    depends_on: []
    done_when:
      - type: file_exists
        path: "src/feature.ts"
```

### Skills 命令

| 命令 | 功能 | 参数 |
|------|------|------|
| `/task-start <id>` | 开始任务 | `--assignee`, `--audit-by` |
| `/task-done <id>` | 完成任务 | `--skip-audit`, `--audit-by` |
| `/handoff <ai>` | AI 交接 | `--module`, `--tasks` |
| `/sync` | 进度同步 | `--quick` |

---

## MBTI 协作框架

| MBTI | 角色 | 职责 | 推荐 AI |
|------|------|------|---------|
| **ENTJ** | 战略规划者 | 架构设计、技术选型 | Claude Opus, Gemini |
| **ISTJ** | 编码实现者 | 代码实现、测试编写 | Claude Sonnet, Codex |
| **ENTP** | 质询改进者 | 代码审查、风险识别 | Gemini, Claude |

### 协作流程

```
规划阶段: ENTJ 制定方案 → ENTP 质询 → ENTJ 定稿
实现阶段: ISTJ 实现 → ENTP 审查 → ISTJ 改进
交付阶段: ENTJ 评估 → ENTP 检查 → 确认交付
```

---

## 配置优先级

```
命令行参数 > 任务级配置 > 模块级 defaults > 全局 roles.yaml
```

示例:
```bash
# 使用模块默认 (codex 实现, gemini 审计)
/task-start FE-1.1

# 命令行覆盖
/task-start FE-1.1 --assignee=claude --audit-by=codex
```

---

## 非 Claude AI 使用指南 (SOP)

如果你是 Gemini / Codex / 其他 AI:

```bash
# 1. 读取配置
cat project/roles.yaml
cat project/tasks/{module}.yaml

# 2. 开始任务 (手动更新)
# 编辑 tasks/*.yaml:
#   status: in_progress
#   assignee: gemini

# 3. 执行任务

# 4. 完成任务 (手动更新)
# 编辑 tasks/*.yaml:
#   status: completed
#   completed_at: 2026-01-17

# 5. 交接 (创建 .context/session.md)
```

---

## 常见问题

### Q: 如何添加新的 AI 角色?

编辑 `project/roles.yaml`:
```yaml
roles:
  my_ai:
    name: "My AI"
    capabilities: [implement]
    mbti: [ISTJ]
    tools: [manual-sop]
```

### Q: 如何修改模块的默认分配?

编辑对应模块的任务文件:
```yaml
defaults:
  implement_by: my_ai
  audit_by: claude
```

### Q: 如何同步模板更新?

使用 subtree 模式:
```bash
./scripts/sync-upstream.sh
```

---

## License

MIT

---

## 贡献

欢迎提交 Issue 和 PR!

如果你在项目中优化了工作流，可以通过 subtree 推送回本仓库。
