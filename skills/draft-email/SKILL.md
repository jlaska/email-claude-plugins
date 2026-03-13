---
name: draft-email
description: Draft emails in James Laska's voice using his analyzed communication style - greetings, tone, vocabulary, and structural habits derived from 13,917 sent emails
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
---

# Draft Email

Composes emails in James's voice using his voice profile.

## When to Use

Invoke `/draft-email` to:
- Draft a new email in James's voice
- Draft a reply to an existing email thread
- Get a Gmail draft created (ready to review and send from Gmail UI)

## Workflow

### 1. Load Configuration and Voice Profile

Read configuration files (user config overrides defaults):

1. **Plugin defaults**: `skills/draft-email/config/defaults.yaml`
2. **User config**: `~/.config/email-claude-plugins/config.yaml` (overrides — name, email, role, organization)

The user config uses the same file as `check-email`. Pull `user.name`, `user.email`, `user.role`, and
`user.organization` from it if present; fall back to defaults otherwise.

Then load the voice profile. This file lives outside the repo (locally generated from your email
archive — not committed to source control):

```
~/.config/email-claude-plugins/voice-profile.md
```

If the voice profile doesn't exist, tell the user and point them to
`skills/draft-email/references/README.md` for generation instructions. Do not proceed without it.

### 2. Gather Context from User

Ask for the following if not provided:

| Field | Question |
|-------|----------|
| **Recipient(s)** | Who is this going to? (name, email, role) |
| **Subject / Topic** | What's this email about? |
| **Key points** | What are the main things to communicate? |
| **Reply or new?** | Is this a reply to an existing thread? If so, message ID or thread URL? |
| **Tone** | Any tone preference? (professional, casual, friendly, formal, concise, persuasive — or auto-infer) |
| **Audience type** | (auto-infer from recipient info, but confirm if ambiguous) |

If the user provides enough context upfront, skip directly to step 4.

### 3. Fetch Thread Context (Reply Only)

If replying to an existing thread, fetch it to understand conversation history:

```bash
gog gmail get <messageId> --json
```

Read the prior messages to understand:
- What was asked or said
- The thread tone and register already established
- What specifically needs a response

### 4. Select Tone

Infer the appropriate tone from thread context, recipient type, and subject matter if not specified.
Present the recommendation and let the user override before drafting.

```
Recommended tone: [tone] — [one-sentence rationale]
Override? (professional / casual / friendly / formal / concise / persuasive)
```

Apply the tone calibration table to understand how the voice profile is adjusted:

| Tone | Greeting | Length | Humor | Colloquial | Structure |
|------|----------|--------|-------|------------|-----------|
| professional | Greetings / Hey | Medium | Light if natural | Moderate | Clear sections |
| casual | Hey [Name], | Short | Yes, natural | Heavy (ya'll, dig) | Minimal |
| friendly | Greetings friends! / Hey! | Medium | Yes | Moderate | Conversational |
| formal | Greetings, | Medium-Long | Rare | Minimal | Structured, headers |
| concise | (skip or Hey) | Short | No | Minimal | Bare minimum |
| persuasive | Hey [Name], / Greetings | Medium | Strategic | Moderate | Problem → ask → benefit |

**Voice profile constants apply in ALL tones** — never "Dear", never emoji in prose, sign-off is
always `Thanks,\nJames`, never "Pursuant to" / "Kindly advise".

### 5. Calibrate Audience

Use the audience calibration table from the voice profile (Section 7):

| Audience | Greeting | Tone | Length |
|----------|----------|------|--------|
| Direct report (individual) | `Hey [Name],` | Casual, warm, direct | Short–Medium |
| Peer / colleague | `Hey [Name],` or `Greetings` | Collegial, candid, informal | Variable |
| Leadership (upward) | `Greetings [title]!` | Professional-warm, structured | Medium–Long |
| Group/team | `Greetings gang/friends!` | Warm, energetic, inclusive | Medium |
| External partner | `Greetings [Name]` | Professional, brief context | Short–Medium |
| Unknown/formal | `Greetings,` | Polite, clear ask | Short |

Default sign-off is always `Thanks,\nJames` regardless of audience.

### 6. Draft the Email

Apply James's voice markers from the voice profile (Section 8) as the constant foundation, then
adjust for the selected tone:

- **Candor**: say what you think without excessive hedging
- **Warmth**: collegial, personal when appropriate
- **Brevity discipline**: if the answer is simple, give just the answer
- **"That said" / "That aside"**: use as pivot phrases when needed
- **Regional colloquial**: ya'll, kinda, gotta, dig — use naturally, don't force
- **Dry wit**: only if it fits naturally; never forced
- **One focused ask**: end with a single clear question or action item if applicable
- **TL;DR up front**: for complex/long emails, lead with summary

Apply email type format (Section 5) based on context:
- **Short Reply (Type A)**: 1–3 sentences, no preamble
- **Individual Ask (Type C)**: Hey + context + direct ask + Thanks/James
- **Group Broadcast (Type D)**: Greetings + context + structure + next steps + Thanks/James
- **Forward with Context (Type E)**: one framing sentence only
- **Long Technical (Type H)**: TL;DR header + markdown sections + numbered steps

**Do NOT use:**
- "Dear," "To Whom It May Concern," "Pursuant to," "Kindly advise," "Best regards"
- Formal/legal hedging language
- Emoji in prose (only status emoji in structured reports)
- Long-winded preambles before the ask
- "Cheers" or "Sincerely"
- Passive voice in status reports

### 7. Present Draft for Review

Show the full email clearly formatted:

```
---
To: [recipient]
Subject: [subject]
Tone: [selected tone]
---

[email body]
```

Then ask:
> Does this look right, or would you like any changes? (tone, length, wording, anything)

### 8. Iterate if Needed

Accept feedback and re-draft. Common adjustments:
- Tone too formal → loosen up, use "Hey" instead of "Greetings"
- Too long → cut to the essential ask
- Missing context → add one sentence of background
- Wrong greeting → recalibrate to audience

Repeat until user approves.

### 9. Create Gmail Draft

On approval, write the body to a temp file and create a Gmail draft:

**New email:**
```bash
gog gmail drafts create \
  --to="recipient@example.com" \
  --subject="Subject line" \
  --body-file="/tmp/draft-email.txt"
```

**Reply (in existing thread):**
```bash
gog gmail drafts create \
  --reply-to-message-id="<messageId>" \
  --body-file="/tmp/draft-email.txt"
```

**With CC:**
```bash
gog gmail drafts create \
  --to="recipient@example.com" \
  --cc="cc@example.com" \
  --subject="Subject line" \
  --body-file="/tmp/draft-email.txt"
```

After draft creation, confirm to the user:
> Draft created in Gmail. Review and send from the Gmail UI when ready.

## gog Command Reference

| Operation | Command |
|-----------|---------|
| Create new draft | `gog gmail drafts create --to="..." --subject="..." --body-file="/tmp/draft.txt"` |
| Create reply draft | `gog gmail drafts create --reply-to-message-id="<id>" --body-file="/tmp/draft.txt"` |
| Read thread for context | `gog gmail get <messageId> --json` |
| List drafts | `gog gmail drafts list --json` |
