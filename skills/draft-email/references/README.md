# Voice Profile — References

## What is a voice profile?

Your voice profile captures your authentic writing voice derived from years of email data — vocabulary,
greetings, structural habits, tone markers, and anti-patterns. It is not a generic style guide; it is
*your* voice, statistically grounded in how you actually write.

## Runtime location

```
~/.config/email-claude-plugins/voice-profile.md
```

The voice profile lives outside the repo because it contains personal communication data. The repo
provides only these instructions for generating it.

## How the skill uses it

The skill loads the voice profile at **Step 1** as the constant foundation. Tone (professional,
casual, friendly, etc.) is applied on top of it at **Step 4** (Select Tone). The voice profile
never changes — tone modifies how that voice is expressed for a given email.

---

## Generating a voice profile from scratch

### Step 1 — Fetch sent emails

Export your sent mail to a local archive using `gog gmail`:

- See `email-archive/fetch_sent.py` as reference for pagination and filtering
- Filter out calendar invites, automated messages, and OOO auto-replies
- Recommended: 1,000+ emails for reliable patterns; 5,000+ for strong statistical confidence

```bash
# Example: fetch sent mail (see fetch_sent.py for full implementation)
gog gmail list --folder=sent --results-only > email-archive/raw/page_001.json
```

### Step 2 — Analyze the corpus

Ask Claude to analyze the filtered emails for:

- Greeting patterns and frequency
- Closing/sign-off patterns
- Tone and formality markers (casual vs formal ratio)
- Signature phrases and vocabulary frequency
- Email type patterns (short reply, group broadcast, individual ask, etc.)
- Structural habits (TL;DR placement, list usage, question framing)
- Audience calibration (how tone shifts by recipient type)
- Distinctive voice markers
- Anti-patterns (what you never do)

### Step 3 — Output the voice profile

Ask Claude to produce a markdown file with the 9 required sections below and save it to
`~/.config/email-claude-plugins/voice-profile.md`.

---

## Required sections

The `draft-email` skill depends on these sections being present and named as follows:

| Section | Content |
|---------|---------|
| 1. Greetings | Patterns, frequency, decision rules |
| 2. Closings / Sign-offs | Default, variations, what's never used |
| 3. Tone & Formality | Casual-to-formal ratio, humor style, emoji policy |
| 4. Signature Phrases & Vocabulary | Frequently used phrases with frequency data |
| 5. Email Types & Format Patterns | Templates for each email type |
| 6. Structural Habits | TL;DR placement, inline CC, question framing, etc. |
| 7. Audience Calibration | Greeting/tone/length/sign-off by audience type |
| 8. Distinctive Voice Markers | Unique traits (candor, humor style, colloquialisms) |
| 9. Anti-patterns | What you never do (specific phrases and styles to avoid) |
