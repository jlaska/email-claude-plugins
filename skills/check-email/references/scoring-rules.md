# Email Priority Scoring Rules

## Scoring Factors

### High-Value Factors (30-50 points)

| Factor | Points | Rationale |
|--------|--------|-----------|
| VIP sender | +50 | Explicitly marked as VIP in user config |
| Critical contact | +40 | Known important contact (e.g., direct manager) |
| Priority domain | +30 | Email from important organization domain |
| High contact | +20 | Known contact marked as high importance |

### Medium-Value Factors (10-20 points)

| Factor | Points | Rationale |
|--------|--------|-----------|
| Priority keyword | +15 | Subject contains urgent/action keywords |
| Jira ticket (tracked) | +20 | References a project in `jira_projects` list |
| Jira ticket (untracked) | +10 | References any other Jira ticket pattern |
| Unread | +10 | User hasn't read it yet |
| Recent (<4h) | +10 | Fresh email, likely timely |

### Low-Value Factors (5 points)

| Factor | Points | Rationale |
|--------|--------|-----------|
| Direct recipient | +5 | In "to" field (not just cc) |

## Priority Levels

| Level | Score Range | Meaning |
|-------|-------------|---------|
| HIGH | >= 50 | Needs immediate attention |
| MEDIUM | 25-49 | Should review today |
| LOW | < 25 | Can wait or delegate |

## Examples

### High Priority (75 points)
- From: CEO (VIP +50)
- Subject: "Urgent: Board meeting prep" (keyword +15)
- Unread (+10)
- **Total: 75 points → HIGH**

### Medium Priority (35 points)
- From: colleague@redhat.com (priority domain +30)
- Direct recipient (+5)
- **Total: 35 points → MEDIUM**

### Low Priority (10 points)
- From: newsletter@example.com
- Unread (+10)
- **Total: 10 points → LOW**
