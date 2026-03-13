---
name: check-email
description: AI-powered inbox triage using GTD methodology - categorizes uncategorized emails and applies Gmail labels (GTD/*)
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
---

# Check Email

Triages uncategorized Gmail inbox emails using GTD methodology and applies labels.

## When to Use

Invoke `/check-email` to:
- Find emails without GTD labels in your inbox
- Score emails by priority (VIP senders, keywords, recency)
- Categorize using GTD methodology
- Apply GTD labels in Gmail
- Present actionable summary table

## GTD Labels

| Label | When to Apply |
|-------|---------------|
| **GTD/Urgent** | Needs attention TODAY - deadlines, escalations, critical issues |
| **GTD/Action** | Must DO something - tasks, decisions, document reviews |
| **GTD/Reply** | Needs written response only - questions, feedback requests |
| **GTD/Waiting** | Tracking someone else - delegated tasks, pending approvals |
| **GTD/Review** | Read/digest only - FYI, status updates, newsletters |
| **GTD/Ignore** | Safe to skip - automated notifications, irrelevant threads |
| **GTD/Needs Review** | AI confidence <60% - ambiguous signals, flag for manual review |

## Workflow

### 1. Load Configuration

Read configuration files (user config overrides defaults):

1. **Plugin defaults**: `skills/check-email/config/defaults.yaml`
2. **User config**: `~/.config/email-claude-plugins/config.yaml` (overrides)
3. **Learned patterns**: `~/.config/email-claude-plugins/learning.yaml`
4. **GTD guidelines**: `prompts/categorize.md`

The user config at `~/.config/email-claude-plugins/config.yaml` can override:
- Label names (e.g., change `GTD/Urgent` to `Priority/Now`)
- VIP senders
- Priority domains
- Contact importance levels

### 2. Fetch Uncategorized Emails

Find inbox emails without any GTD label:

```bash
gog gmail search "in:inbox -label:GTD-Urgent -label:GTD-Action -label:GTD-Reply -label:GTD-Waiting -label:GTD-Review -label:GTD-Ignore" --json --max=20
```

### 3. Calculate Priority Score

For each email, calculate score based on `config/defaults.yaml`:

| Factor | Points | How to Check |
|--------|--------|--------------|
| VIP sender | +50 | Match `from` against `vip_senders` list |
| Priority domain | +30 | Match sender domain against `priority_domains` |
| Critical contact | +40 | Match `from` in `contacts` with `importance: critical` |
| High contact | +20 | Match `from` in `contacts` with `importance: high` |
| Priority keyword | +15 | Match subject against `priority_keywords` |
| Jira ticket (tracked) | +20 | Regex `\b[A-Z]{2,10}-\d+\b` in subject/body, project in `jira_projects` |
| Jira ticket (untracked) | +10 | Regex `\b[A-Z]{2,10}-\d+\b` in subject/body, project not in `jira_projects` |
| Unread | +10 | Check `labelIds` contains `UNREAD` |
| Recent (<4h) | +10 | Compare `internalDate` to now |
| Direct recipient | +5 | Check if user email is in `to` (not just `cc`) |

**Priority Levels**:
- HIGH: score >= 50
- MEDIUM: score >= 25
- LOW: score < 25

### 4. Categorize Using GTD

Apply GTD methodology from `prompts/categorize.md`:

| Content Type | → Label |
|-------------|---------|
| Needs attention TODAY | `GTD/Urgent` |
| Must DO something (task, decision) | `GTD/Action` |
| Just needs a written response | `GTD/Reply` |
| Waiting on someone else | `GTD/Waiting` |
| FYI / informational | `GTD/Review` |
| Automated / irrelevant | `GTD/Ignore` |

**Decision Rules**:
1. Check `learning.yaml` for sender/subject patterns first
2. **Urgent wins** - if needs attention today, use Urgent (not Action)
3. One label only - pick the single best fit
4. Consider sender importance - critical contacts bias toward Urgent/Action

### 5. Apply Labels in Gmail

For each categorized email:

```bash
gog gmail labels modify <threadId> --add="GTD/Action"
```

### 6. Present Results

Output table sorted by priority (newest first within each priority):

| # | Priority | Subject | From | Date | Label | What To Do |
|---|----------|---------|------|------|-------|------------|
| 1 | HIGH | [Subject](https://mail.google.com/mail/u/0/#inbox/threadId) | sender | date | Urgent | 1-sentence action |

- **Subject**: Clickable link to `https://mail.google.com/mail/u/0/#inbox/<threadId>`
- **Priority**: HIGH/MEDIUM/LOW
- **Label**: The GTD label applied
- **What To Do**: Brief action summary (or "None" for Review/Ignore)

## gog Command Reference

| Operation | Command |
|-----------|---------|
| Search uncategorized | `gog gmail search "in:inbox -label:GTD" --json --max=20` |
| Read full email | `gog gmail get <messageId> --json` |
| Apply label | `gog gmail labels modify <threadId> --add="GTD/Action"` |
| Remove label | `gog gmail labels modify <threadId> --remove="GTD/Action"` |
| List labels | `gog gmail labels list --json` |
| Create label | `gog gmail labels create "GTD/Urgent"` |

## Recording Corrections

When you disagree with a categorization:
1. Note the original AI category and your correction
2. Update `~/.config/email-claude-plugins/learning.yaml` with the pattern
3. Future runs will consult learned patterns first
