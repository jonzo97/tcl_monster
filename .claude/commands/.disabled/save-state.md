# Save Project State (Pre-Compact)

**Purpose:** Save complete project state before compacting to prevent context loss.

## Your Task:

Execute the pre-compact checklist systematically:

### 1. Update Project State File (`.mcp.json`)

Update with current session information:
```json
{
  "last_updated": "[current date/time]",
  "current_phase": "[e.g., Phase 2.2.1: RISC-V Core Integration]",
  "recent_accomplishments": [
    "[List 3-5 key things completed this session]"
  ],
  "active_files": [
    "[List files created/modified with brief descriptions]"
  ],
  "architecture_decisions": [
    {
      "decision": "[What was decided]",
      "rationale": "[Why]",
      "alternatives_considered": "[What else was considered]"
    }
  ],
  "known_issues": [
    "[Any bugs, limitations, or TODOs discovered]"
  ],
  "next_steps": [
    "[Explicit list of what to do next session]"
  ]
}
```

### 2. Create Session Summary (`docs/sessions/session_YYYY-MM-DD.md`)

Document this session:
```markdown
# Session [Date]

## Goals
- [What we set out to do]

## Completed
- ✅ [Task 1]
- ✅ [Task 2]

## In Progress
- ⏳ [Task 3]

## Decisions Made
1. **[Decision title]**
   - Rationale: [why]
   - Impact: [what this affects]

## Files Created/Modified
- `path/to/file.ext` - [description]

## Next Session
- [ ] [Task 1]
- [ ] [Task 2]

## Notes
[Any important context or gotchas]
```

### 3. Update Architecture Documentation

If any significant patterns or learnings emerged:
- Add to `docs/lessons_learned/[topic].md`
- Update relevant sections of `.claude/CLAUDE.md`

### 4. Commit to Git

If substantial work was done:
```bash
git add .
git status
# Review changes
git commit -m "Session checkpoint: [brief description]"
```

### 5. Verification

Confirm all critical information is saved:
- [ ] `.mcp.json` updated
- [ ] Session summary created
- [ ] Git committed (if applicable)
- [ ] No loose ends or forgotten context

### 6. Output

Report what was saved:
```
## State Saved Successfully

**Files Updated:**
- `.mcp.json` - Project state current as of [time]
- `docs/sessions/session_[date].md` - Session summary
- [Any other files]

**Git Status:**
- [Committed / Not committed - with reason]

**Ready to Compact:**
✅ All critical context preserved
```

## When to Use This Command:
- Before running `/compact`
- At end of work session
- Before pivoting to major new feature
- When context usage reaches 85%+
