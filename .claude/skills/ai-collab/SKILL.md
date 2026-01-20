---
name: ai-collab
description: |
  多 AI 协作指南，合理搭配 Claude、Codex、Gemini，结合 MBTI 人格实现高效开发。
  Use when: 需要多 AI 协作、AI 切换策略、上下文传递指南。
  Triggers: "/ai-collab", "多AI协作", "AI协作流程"
---

# /ai-collab - 多 AI 协作工作流

> 合理搭配 Claude、Codex、Gemini，结合 MBTI 人格实现高效开发

## AI 能力矩阵

| AI 配置 | 擅长领域 | 弱项 | 最佳用途 |
|---------|----------|------|----------|
| **Claude Code + Opus** | 深度推理、架构设计、复杂逻辑 | 速度较慢、成本高 | 规划、决策、难题攻关 |
| **Claude Code + Sonnet** | 上下文理解、多文件编辑、重构 | - | 日常编码、调试、重构 |
| **Codex CLI** | **高效代码生成、批量实现、契约驱动** | 深度推理、跨模块理解 | **CRUD生成、测试补全、代码翻译** |
| **Gemini Pro** | 大上下文、多模态、**实时搜索集成** | 代码精确性 | **技术情报、安全审计、跨文档一致性审查** |

**模型切换**: 在 Claude Code 中使用 `/model opus` 或 `/model sonnet` 切换

## AI 协作金律 (The Golden Rules)

1. **更新即同步 (Sync on Update)**: 任何 AI 在完成任务后，**必须**更新 `MEMORY.md` 中的"当前进度"章节。
2. **情报先行 (Intel First)**: 涉及第三方集成时，优先由 **Gemini** 进行实时全网搜索，再由 Claude 进行架构决策。
3. **契约驱动 (Contract-Driven)**: 在调用 Codex CLI 进行大批量代码生成前，建议由 Claude 生成临时的 `spec.json` 作为输入。
4. **影子审计 (Shadow Audit)**: 对于 Codex CLI 生成的代码，由 **Gemini** 进行"守门员"式审计。

## MBTI + AI 融合模型

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         MBTI × AI 协作矩阵                               │
├────────────┬─────────────┬─────────────────────┬────────────────────────┤
│   阶段     │  MBTI 人格  │  主力 AI            │   辅助工具/角色        │
├────────────┼─────────────┼─────────────────────┼────────────────────────┤
│ 战略与情报 │    ENTP     │  Gemini Pro         │  Google Search (实时)  │
│ 架构与拆解 │    ENTJ     │  Claude Code + Opus │  MEMORY.md (同步)      │
│ 核心实现   │    ISTJ     │  Claude Code + Sonnet│  Codex CLI (高频实现)  │
│ 交叉审计   │    ENTP     │  Gemini Pro         │  Claude (安全深度分析) │
└────────────┴─────────────┴─────────────────────┴────────────────────────┘
```

## 实战切换指南

### 场景 1: 功能开发完整流程

```
需求 → [ENTJ + Opus] 设计方案
                ↓
     → [ISTJ + Sonnet] 核心实现
                ↓
     → [ISTJ + Codex] 补充测试/样板代码
                ↓
     → [ENTP + Gemini] 代码审查
                ↓
     → [ISTJ + Sonnet] 修复问题
                ↓
     → git commit & push
```

### 场景 2: Bug 修复流程

```
Bug 报告 → [Sonnet] 定位问题
                ↓
          问题复杂？
          ├─ 是 → [Opus] 深度分析根因
          └─ 否 → [Sonnet] 直接修复
                ↓
         [Gemini] 验证修复方案
                ↓
         [Sonnet] 实施修复
```

### 场景 3: 卡住时的 AI 切换

```
同一问题 Claude 回答 3 次仍未解决
                ↓
         切换到 Gemini，提供新视角
                ↓
         仍未解决？
                ↓
         切换 /model opus，深度推理
                ↓
         综合多个 AI 的建议形成方案
```

## 上下文传递技巧

### 上下文文件分层

```
project/
├── MEMORY.md              # 长期记忆 (所有AI共享，持久保留)
├── CLAUDE.md              # Claude 工作指南
├── GEMINI.md              # Gemini 专用上下文
└── .context/              # 临时会话上下文 (用完即删)
    └── session.md         # 当前会话交接信息
```

| 文件 | 生命周期 | 用途 |
|------|----------|------|
| `MEMORY.md` | 持久 | 项目身份、架构、进度、决策记录 |
| `.context/session.md` | 临时 | AI 切换时的交接信息 |

### AI 切换 Prompt 模板

```markdown
# 切换到新 AI

请先阅读 MEMORY.md 了解项目背景。

## 之前的工作
[粘贴上一个 AI 的关键输出]

## 当前问题
[描述需要新 AI 帮助的问题]

## 期望
[明确期望新 AI 提供什么帮助]
```

## 快捷命令

```bash
# 进入规划模式
/entj "设计 [功能] 的技术方案"

# 进入实现模式
/istj "实现 [功能]"

# 进入审查模式
/entp "审查 [代码/设计]"

# 切换 AI 提示
"请以新视角审查之前的方案，挑战其中的假设"
```
