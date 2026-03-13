# Email Claude Plugin

AI-powered email triage and drafting using GTD methodology. Categorizes Gmail inbox emails, applies labels, and drafts replies in your voice.

## Skills

### `/check-email`

AI-powered inbox triage using GTD methodology. Categorizes uncategorized emails,
scores priority, and applies Gmail labels.

### `/draft-email`

Drafts emails in your voice using an analyzed communication style (voice profile).
Supports tone selection, audience calibration, and thread replies. Creates Gmail
drafts via `gog gmail`.

## GTD Labels

| Label | Color | Purpose |
|-------|-------|---------|
| `GTD/Urgent` | Dark Red | Needs attention TODAY - deadlines, escalations, outages |
| `GTD/Action` | Orange | Must DO something - tasks, decisions, reviews |
| `GTD/Reply` | Yellow | Written response needed - questions, feedback requests |
| `GTD/Waiting` | Green | Tracking someone else - delegated, pending approval |
| `GTD/Review` | Purple | Read/digest only - FYI, status updates, newsletters |
| `GTD/Ignore` | Gray | Safe to skip - automated notifications, irrelevant |
| `GTD/Needs Review` | Red | AI confidence <60% - requires manual categorization |

## Installation

### 1. Install `gog` CLI

```bash
brew install gogcli
```

See [gogcli repository](https://github.com/steipete/gogcli) for more details.

### 2. Setup GTD Labels (One-Time)

```bash
gog gmail labels create "GTD/Urgent"
gog gmail labels create "GTD/Action"
gog gmail labels create "GTD/Reply"
gog gmail labels create "GTD/Waiting"
gog gmail labels create "GTD/Review"
gog gmail labels create "GTD/Ignore"
gog gmail labels create "GTD/Needs Review"
```

### 3. Clone Repository

```bash
cd ~/Projects
git clone https://github.com/jlaska/email-claude-plugins.git
```

### 4. Customize User Config (Optional)

```bash
# Config is automatically created at ~/.config/email-claude-plugins/config.yaml
vi ~/.config/email-claude-plugins/config.yaml
```

## Usage

```
/check-email
/draft-email
```

### `/check-email` Output

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

- `skills/check-email/config/defaults.yaml`
- `skills/draft-email/config/defaults.yaml`

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

# Jira project prefixes to track (e.g., RHEL, AAP, OCPBUGS)
jira_projects:
  - "RHEL"

# Contact importance overrides
# importance: "critical" (+40 pts), "high" (+20 pts), "medium"/"low" (context only)
contacts:
  - email: "boss@redhat.com"
    name: "Boss Name"
    importance: critical
    relationship: "direct manager"
    notes: "Weekly 1:1 on Tuesdays"
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

## Voice Profile

`/draft-email` requires a voice profile at `~/.config/email-claude-plugins/voice-profile.md`.
This file captures your communication style — greetings, tone, vocabulary, and structural habits.

To generate one, see `skills/draft-email/references/README.md`. The email archive
(`email-archive/fetch_sent.py`) is the data source used to build the profile.

## Priority Scoring

Emails are scored based on multiple factors:

| Factor | Points | How to Check |
|--------|--------|--------------|
| VIP sender | +50 | Match against `vip_senders` list |
| Priority domain | +30 | Match sender domain against `priority_domains` |
| Critical contact | +40 | Match in `contacts` with `importance: critical` |
| High contact | +20 | Match in `contacts` with `importance: high` |
| Priority keyword | +15 | Match subject against `priority_keywords` |
| Jira ticket (tracked) | +20 | Ticket prefix matches `jira_projects` list |
| Jira ticket (untracked) | +10 | Any other Jira ticket pattern in subject/body |
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
│   ├── check-email/
│   │   ├── SKILL.md                    # Main skill definition
│   │   ├── config/
│   │   │   ├── defaults.yaml           # Default configuration
│   │   │   └── config-schema.json      # Config schema validation
│   │   └── references/
│   │       ├── gtd-categories.md       # GTD category reference
│   │       └── scoring-rules.md        # Priority scoring rules
│   └── draft-email/
│       ├── SKILL.md                    # Main skill definition
│       ├── config/
│       │   └── defaults.yaml           # Default configuration
│       └── references/
│           └── README.md               # Voice profile generation guide
├── prompts/
│   ├── categorize.md                   # GTD categorization prompt
│   └── draft-email.md                  # Email drafting prompt
├── email-archive/
│   ├── fetch_sent.py                   # Script to fetch sent emails
│   ├── style_guide.md                  # Analyzed communication style
│   └── raw/                            # Raw sent email pages (500/page)
├── .claude-plugin/
│   └── marketplace.json
├── Makefile
├── .pre-commit-config.yaml
├── .claudelint.yaml
├── .claudelintrc.json
├── .markdownlint.json
├── README.md
└── LICENSE

~/.config/email-claude-plugins/         # User config (overrides defaults)
├── config.yaml                         # Labels, VIPs, contacts, domains
├── learning.yaml                       # Learned patterns (auto-updated)
└── voice-profile.md                    # Communication style for /draft-email
```

## Development

```bash
make setup       # Install pre-commit hooks
make lint        # Run all linters
make lint-fix    # Run linters with auto-fix where possible
```

Linters include: claudelint, markdownlint, gitleaks, and JSON schema validation.

## Verification

```bash
# Test gog access
gog gmail search "in:inbox" --json --max=3

# Verify labels
gog gmail labels list | grep GTD
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
