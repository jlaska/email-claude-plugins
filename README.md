# Claude Email Plugin - GTD Inbox Triage

AI-powered email triage using GTD methodology. Automatically categorizes Gmail inbox emails and applies labels for better email management.

## Features

- **Smart Triage**: Uses GTD methodology to categorize emails into 6 categories
- **Priority Scoring**: Scores emails based on sender, keywords, and recency
- **Learning System**: Remembers your corrections to improve over time
- **Customizable**: Override labels, VIPs, and priority domains in user config
- **Gmail Integration**: Uses `gog gmail` CLI for all Gmail operations

## GTD Labels

| Label | Color | Purpose |
|-------|-------|---------|
| `GTD/Urgent` | Dark Red | Needs attention TODAY - deadlines, escalations, outages |
| `GTD/Action` | Orange | Must DO something - tasks, decisions, reviews |
| `GTD/Reply` | Yellow | Written response needed - questions, feedback requests |
| `GTD/Waiting` | Green | Tracking someone else - delegated, pending approval |
| `GTD/Review` | Purple | Read/digest only - FYI, status updates, newsletters |
| `GTD/Ignore` | Gray | Safe to skip - automated notifications, irrelevant |

## Installation

### 1. Prerequisites

Install `gog` CLI:
```bash
# Follow installation instructions at https://github.com/yakitrak/gog
```

### 2. Setup GTD Labels (One-Time)

Create the GTD labels:

```bash
# Create labels
gog gmail labels create "GTD/Urgent"
gog gmail labels create "GTD/Action"
gog gmail labels create "GTD/Reply"
gog gmail labels create "GTD/Waiting"
gog gmail labels create "GTD/Review"
gog gmail labels create "GTD/Ignore"
```

### 3. Clone Repository

```bash
cd ~/Projects
git clone https://github.com/jlaska/email-claude-plugins.git
```

### 4. Customize User Config (Optional)

```bash
# Config is automatically created at ~/.config/email-claude-plugins/config.yaml
# Edit to add VIPs, priority domains, custom label names, etc.
vi ~/.config/email-claude-plugins/config.yaml
```

### 5. Install Plugin (When Available)

```bash
# Add to Claude marketplace
claude plugin marketplace add jlaska/email-claude-plugins

# Install plugin
claude plugin install check-email@email-claude-plugins
```

## Usage

Simply invoke the skill in Claude Code:

```
/check-email
```

### Expected Output

```
Found 15 uncategorized emails. Processing...

| # | Priority | Subject | From | Date | Label | What To Do |
|---|----------|---------|------|------|-------|------------|
| 1 | HIGH | [Q1 Budget Review](link) | CFO | Mar 10 | Urgent | Review and approve by EOD |
| 2 | HIGH | [Production Alert](link) | oncall@ | Mar 10 | Urgent | Check monitoring dashboard |
| 3 | MEDIUM | [Project Status](link) | PM | Mar 10 | Action | Provide timeline update |
| 4 | MEDIUM | [Meeting Request](link) | Partner | Mar 10 | Reply | Confirm availability |
| 5 | LOW | [Weekly Newsletter](link) | news@ | Mar 10 | Review | None |

Applied 15 GTD labels. 2 HIGH priority items need attention today.
```

## Configuration

### Plugin Defaults

Default configuration is at `skills/check-email/config/defaults.yaml`.

### User Config

Override defaults by editing `~/.config/email-claude-plugins/config.yaml`:

```yaml
# Your info
user:
  name: "James Laska"
  email: "jlaska@redhat.com"
  role: "Your Role"
  organization: "Red Hat"

# VIP senders (always high priority)
vip_senders:
  - "ceo@redhat.com"

# Priority domains
priority_domains:
  - "redhat.com"

# Contact importance overrides
contacts:
  - email: "boss@redhat.com"
    name: "Boss Name"
    importance: critical
```

### Learning File

The plugin learns from your corrections at `~/.config/email-claude-plugins/learning.yaml`:

```yaml
sender_overrides:
  "newsletter@example.com": "GTD/Review"

subject_patterns:
  - pattern: "Weekly Status"
    category: "GTD/Review"
    confidence: high
```

## Priority Scoring

Emails are scored based on multiple factors:

| Factor | Points | How to Check |
|--------|--------|--------------|
| VIP sender | +50 | Match against `vip_senders` list |
| Priority domain | +30 | Match sender domain against `priority_domains` |
| Critical contact | +40 | Match in `contacts` with `importance: critical` |
| High contact | +20 | Match in `contacts` with `importance: high` |
| Priority keyword | +15 | Match subject against `priority_keywords` |
| Unread | +10 | Check `labelIds` contains `UNREAD` |
| Recent (<4h) | +10 | Compare `internalDate` to now |
| Direct recipient | +5 | Check if user email is in `to` field |

**Priority Levels**:
- **HIGH**: score >= 50 (needs immediate attention)
- **MEDIUM**: score >= 25 (should review today)
- **LOW**: score < 25 (can wait)

## GTD Categorization

The plugin categorizes emails using GTD methodology:

1. **Urgent** - Needs attention TODAY (production issues, deadlines)
2. **Action** - User must DO something (tasks, decisions, reviews)
3. **Reply** - Needs written response only (questions, feedback)
4. **Waiting** - Tracking someone else (delegated, pending approval)
5. **Review** - Read/digest only (FYI, status updates)
6. **Ignore** - Safe to skip (automated notifications)

## Architecture

```
~/Projects/email-claude-plugins/
├── skills/
│   └── check-email/
│       ├── SKILL.md                    # Main skill definition
│       ├── config/
│       │   └── defaults.yaml           # Default configuration
│       └── references/
│           ├── gtd-categories.md       # GTD category reference
│           └── scoring-rules.md        # Priority scoring rules
├── prompts/
│   └── categorize.md                   # GTD categorization prompt
├── README.md
└── LICENSE

~/.config/email-claude-plugins/         # User config (overrides defaults)
├── config.yaml                         # Labels, VIPs, contacts, domains
└── learning.yaml                       # Learned patterns (auto-updated)
```

## Verification

### Test gog Access
```bash
gog gmail search "in:inbox" --json --max=3
```

### Verify Labels
```bash
gog gmail labels list | grep GTD
```

### Test Skill
```
/check-email
```

## Recording Corrections

When the AI miscategorizes an email:

1. Note the original category and your correction
2. The plugin will update `~/.config/email-claude-plugins/learning.yaml`
3. Future runs will consult learned patterns first

## License

MIT License - See LICENSE file for details

## Contributing

Contributions welcome! Please open an issue or PR.

## Author

James Laska (jlaska@redhat.com)
