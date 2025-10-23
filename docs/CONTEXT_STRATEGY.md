# Context Management Strategy

**Purpose:** Intelligent context window management for long-term project continuity

**Last Updated:** 2025-10-22

---

## Challenge

Claude Code has a **200k token context window**. For complex projects:
- Long sessions consume context quickly
- Context compaction can lose critical information
- Cross-session continuity requires careful planning
- Multi-device work (home/work) needs synchronization

**Goal:** Maintain project continuity across sessions, compactions, and devices without information loss

---

## Strategy Overview

### Three-Tier Context Management

1. **Active Context** (in conversation)
   - Current work in progress
   - Recent code changes
   - Immediate decisions and rationale

2. **Memory MCP** (persistent knowledge graph)
   - Architecture decisions
   - File locations and purposes
   - Design patterns and utilities
   - Known issues and workarounds

3. **Documentation** (searchable reference)
   - ROADMAP.md for long-term planning
   - CLAUDE.md for session startup
   - Specialized docs for deep dives

---

## Memory MCP Usage

### Knowledge Graph Structure

Memory MCP stores information as a graph:
- **Entities:** Projects, files, modules, decisions, patterns
- **Relations:** depends_on, implements, contains, part_of
- **Observations:** Facts, states, notes about entities

### What to Store in Memory MCP

#### 1. Project Architecture
```
Entity: tcl_monster_project
Relations:
  - contains: tcl_scripts, hdl, constraint, docs
Observations:
  - "FPGA automation toolkit for Libero SoC"
  - "Target: PolarFire MPF300 Eval Kit"
  - "WSL2 environment, Windows-side Libero"
```

#### 2. File Locations and Purposes
```
Entity: create_project.tcl
Relations:
  - part_of: tcl_monster_project
  - located_in: tcl_scripts/
  - implements: project_creation_automation
Observations:
  - "Creates Libero project for MPF300TS"
  - "Imports HDL and constraints"
  - "Sets design hierarchy and top module"
  - "Key commands: new_project, import_files, build_design_hierarchy"
```

#### 3. Design Decisions
```
Entity: decision_wsl_path_conversion
Relations:
  - part_of: tcl_monster_project
  - affects: run_libero.sh
Observations:
  - "Decision: Use wslpath to convert paths for Libero on Windows"
  - "Rationale: Libero.exe expects Windows-style paths"
  - "Alternatives considered: Run everything on Windows (rejected - prefer Unix tools)"
  - "Date: 2025-10-22"
```

#### 4. Known Issues and Workarounds
```
Entity: issue_tcl_bracket_syntax
Relations:
  - part_of: tcl_monster_project
  - affects: build_design.tcl
Observations:
  - "Issue: TCL interprets [1] as command, not list item"
  - "Workaround: Use (1) instead of [1] in puts statements"
  - "Fix applied: build_design.tcl line 92"
  - "Date: 2025-10-22"
```

#### 5. Reusable Patterns
```
Entity: pattern_libero_error_handling
Relations:
  - part_of: tcl_monster_project
  - used_in: create_project.tcl, build_design.tcl
Observations:
  - "Pattern: Use catch {} to handle Libero tool failures"
  - "Example: if {[catch {run_tool -name SYNTHESIZE}]} { ... }"
  - "Returns: 0 on success, 1 on failure"
```

### When to Update Memory MCP

**Update immediately when:**
- Creating new files or directories
- Making architecture decisions
- Discovering Libero limitations or workarounds
- Establishing patterns or utilities
- Completing major milestones

**Update before:**
- Context compaction (when approaching token limits)
- End of session (even if context remains)
- Switching work locations (home → work or vice versa)

---

## Session Start Protocol

### Mandatory First Steps in Every Session

1. **Query Memory MCP** for project context:
   ```
   "What entities exist for tcl_monster_project?"
   "What was the last work done on this project?"
   "What architecture decisions have been made?"
   ```

2. **Read CLAUDE.md** for project overview and key paths

3. **Read ROADMAP.md** for current phase and next tasks

4. **Verify understanding** with user:
   ```
   "I've restored context. Last session we completed Phase 0
   (basic project creation and synthesis). Current status shows
   counter design successfully built. Ready to continue with
   Phase 1 (timing constraints and reporting). Does this match
   your understanding?"
   ```

5. **Check for changes** since last session:
   ```
   "Have you made any manual changes to the project since last session?
   Any new files or discoveries I should know about?"
   ```

---

## Proactive Compaction Strategy

### Token Usage Monitoring

- **0-50k tokens:** Normal operation
- **50k-100k tokens:** Start considering compaction soon
- **100k-150k tokens:** Proactive compaction recommended
- **150k+ tokens:** Urgent compaction needed

### Pre-Compaction Checklist

**Before compacting, save to Memory MCP:**

1. **All Created Files**
   - File paths, purposes, key functions
   - Relations to other files

2. **Architecture Decisions**
   - What was decided and why
   - Alternatives considered
   - Trade-offs made

3. **Current Work State**
   - What phase we're in (reference ROADMAP.md)
   - What was just completed
   - What's next
   - Any blockers or issues

4. **Code Patterns and Utilities**
   - Reusable functions created
   - Important code snippets
   - Anti-patterns to avoid

5. **Dependencies and Integrations**
   - External tools used (Libero, ModelSim, etc.)
   - Configuration requirements
   - Known compatibility issues

### Post-Compaction Recovery

**After compacting:**

1. **Restore from Memory MCP**
   - Query all tcl_monster_project entities
   - Rebuild mental model from observations

2. **Verify File System**
   - Confirm critical files still exist
   - Check for any discrepancies

3. **Resume Work**
   - Pick up where we left off using ROADMAP.md
   - No user re-explanation needed (success indicator!)

---

## Cross-Device Synchronization

### Scenario: Working on Home and Work Computers

**Challenge:** Memory MCP data is stored locally in project (`.mcp.json`), needs Git sync

**Solution:**

1. **Before leaving device:**
   - Update Memory MCP with all recent work
   - Commit changes including `.mcp.json`:
     ```bash
     git add .mcp.json
     git commit -m "Update Memory MCP with recent work"
     git push
     ```

2. **On arriving device:**
   - Pull latest changes:
     ```bash
     git pull
     ```
   - Claude Code will automatically load `.mcp.json`
   - Query Memory MCP to restore context

3. **Global Settings Sync:**
   - User's global Claude settings in `~/.claude/`
   - Sync via separate Git repo:
     ```bash
     cd ~/.claude
     git pull  # Get latest global preferences
     ```

---

## Documentation-Driven Context

### Purpose of Each Doc File

| File | Purpose | When to Read | Update Frequency |
|------|---------|--------------|------------------|
| CLAUDE.md | Session startup, key paths | Every session start | After major changes |
| ROADMAP.md | Long-term plan, current phase | Session start, phase transitions | After phase completion |
| DESIGN_LIBRARY.md | Design catalog, resource usage | When selecting/creating designs | After new design |
| DEBUGGING_FRAMEWORK.md | Debug workflow reference | When debugging | After discoveries |
| SIMULATION_FRAMEWORK.md | Simulation workflow | When running tests | After sim setup |
| APP_NOTE_AUTOMATION.md | App note recreation | When recreating designs | After new app note |
| CONTEXT_STRATEGY.md | This doc - context management | As needed | Rarely |

### Documentation as Context Compression

**Key Insight:** Well-organized documentation compresses context 10-100x

- Raw conversation: ~1000 tokens per minute of work
- Compressed doc: ~100 tokens per minute of work
- Memory MCP entity: ~10 tokens per minute of work

**Strategy:** Continuously summarize work into docs and Memory MCP to keep active context small

---

## Agent-Based Context Management

### Background Context Manager Agent (Proposed)

**Purpose:** Autonomous agent that manages context in background

**Responsibilities:**
- Monitor token usage
- Auto-save to Memory MCP every N minutes
- Suggest compaction when nearing limits
- Pre-compact critical information
- Post-compact validation

**Implementation:** (Phase 6 of ROADMAP)

```python
# tools/agents/context_manager.py

class ContextManager:
    def __init__(self, token_limit=200000):
        self.token_limit = token_limit
        self.compact_threshold = 0.75  # Compact at 75% usage

    def monitor_usage(self):
        """Check token usage and recommend actions"""
        current_tokens = get_current_token_count()
        usage_pct = current_tokens / self.token_limit

        if usage_pct > self.compact_threshold:
            self.prepare_for_compaction()
            return "COMPACT_RECOMMENDED"
        elif usage_pct > 0.5:
            self.save_checkpoint()
            return "CHECKPOINT_SAVED"
        else:
            return "OK"

    def prepare_for_compaction(self):
        """Save all critical information before compact"""
        # Query recent work
        recent_files = get_files_created_in_session()
        recent_decisions = get_decisions_made_in_session()

        # Save to Memory MCP
        for file in recent_files:
            memory_mcp.create_entity(file)

        for decision in recent_decisions:
            memory_mcp.create_entity(decision)

    def save_checkpoint(self):
        """Periodic checkpoint saves"""
        memory_mcp.save_snapshot()
```

---

## Success Indicators

**Context management is working well when:**
- ✅ After compaction, work resumes immediately without user re-explaining
- ✅ Cross-device work (home → work) is seamless
- ✅ No duplicate utilities created in wrong locations
- ✅ Architecture stays consistent across sessions
- ✅ User rarely says "remember we put that in..."

**Context management needs improvement when:**
- ❌ After compaction, need to ask "where were we?"
- ❌ Recreating files that already exist
- ❌ Forgetting previous decisions
- ❌ Architecture drift across sessions
- ❌ User frequently needs to re-explain context

---

## Practical Tips

### For User:
1. **Start sessions with context:** "Last time we completed Phase 1, let's continue with Phase 2"
2. **Commit often:** Include `.mcp.json` in Git commits
3. **Document decisions:** When making choices, add to ROADMAP or CLAUDE.md
4. **Test cross-device:** Periodically verify sync works between home/work

### For Claude Code:
1. **Query Memory MCP first thing every session**
2. **Update Memory MCP frequently** (not just before compaction)
3. **Reference ROADMAP.md** for current phase and next steps
4. **Summarize work** into documentation continuously
5. **Never guess file locations** - query Memory MCP or read filesystem

---

## Anti-Patterns to Avoid

❌ **Don't:** Rely only on conversation history
✅ **Do:** Save to Memory MCP and docs

❌ **Don't:** Wait until compaction to save context
✅ **Do:** Update Memory MCP continuously

❌ **Don't:** Assume file locations
✅ **Do:** Query Memory MCP or check filesystem

❌ **Don't:** Skip session startup protocol
✅ **Do:** Query Memory MCP every session start

❌ **Don't:** Create files without checking if they exist
✅ **Do:** Search for existing files first

---

## Example Session Timeline

### Session Start (0 tokens)
1. Query Memory MCP: "tcl_monster_project status?"
2. Read CLAUDE.md and ROADMAP.md
3. Confirm with user: "Resuming Phase 1 work?"

### During Work (50k tokens)
- Create timing constraints file
- Update Memory MCP with file location and purpose
- Update ROADMAP.md to mark task complete

### Mid-Session Checkpoint (100k tokens)
- Save comprehensive checkpoint to Memory MCP
- Update CLAUDE.md if any key paths changed

### Approaching Limit (150k tokens)
- Pre-compaction checklist (save all recent work)
- Compact conversation
- Post-compaction: verify Memory MCP has all info

### Session End (175k tokens)
- Final Memory MCP update
- Update ROADMAP.md with progress
- User commits including `.mcp.json`

---

**Maintained by:** TCL Monster Project | **Last Updated:** 2025-10-22
