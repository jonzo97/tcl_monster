# Intelligent Compaction Check

**Purpose:** Proactively monitor context usage and recommend compaction at intelligent points.

## Your Task:

1. **Check Current Context Usage:**
   - Calculate current token usage percentage
   - Determine status: Safe (<75%), Plan (75-85%), Warn (85-90%), Urgent (90-95%), Critical (>95%)

2. **Analyze Current Work State:**
   - Are we in the middle of a task or at a natural breakpoint?
   - Have we completed 5-7 conversational turns since last check?
   - Are we about to pivot to a new feature/phase?

3. **Decision Logic:**

   **< 75% (Safe Zone):** ✅
   - Continue working
   - No action needed
   - Next check: After completing current task

   **75-85% (Planning Zone):** ⚠️
   - Start planning compaction
   - Identify what can be summarized
   - Prepare pre-compact checklist
   - Save state to external files
   - Recommend: "Compact after completing [current task]"

   **85-90% (Warning Zone):** 🟠
   - Compact soon (within 1-2 tasks)
   - MUST save state before continuing
   - Create summary files now
   - Recommend: "Complete current task, then compact immediately"

   **90-95% (Urgent Zone):** 🔴
   - COMPACT NOW (before starting new work)
   - Save everything to files
   - Don't start new research/exploration
   - Recommend: "Compacting now to preserve context quality"

   **> 95% (Critical Zone):** 🚨
   - EMERGENCY COMPACT
   - Auto-compact will trigger any moment
   - Immediately save state
   - Execute compact

4. **Pre-Compact Checklist (if recommending compaction):**

   Save to external files:
   - **Project state**: Update `.mcp.json` with current progress
   - **Architecture decisions**: Add to `docs/lessons_learned/`
   - **File locations**: Document what files exist and where
   - **Next steps**: Write explicit TODO list to `.claude/next_session.md`
   - **Open questions**: Any unresolved issues or blockers

5. **Output Format:**

   ```
   ## Context Status: [Status Level]
   - Current: [X]k / 200k tokens ([Y]%)
   - Turns since last check: [N]

   ## Current Work:
   - Task: [description]
   - Status: [in middle / at breakpoint]
   - Pivot pending: [yes/no]

   ## Recommendation:
   [Your specific recommendation with reasoning]

   ## Actions Taken:
   [List any files saved/updated]
   ```

6. **After Analysis:**
   - If compaction recommended, ask user: "Should I compact now or continue?"
   - If safe to continue, just report status and continue working
   - If critical, explain urgency clearly

## Important Notes:
- **Always check context BEFORE starting large research tasks**
- **Compact before pivoting to new features** (even if below 75%)
- **Prioritize quality over quantity** - compact early if work is getting scattered
- **Save everything** - compaction loses detail, external files preserve it
