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

2. **PROJECT_STATE.json** (persistent project knowledge)
   - Architecture decisions
   - File locations and purposes
   - Design patterns and utilities
   - Known issues and workarounds
   - Session summaries and learnings

3. **Documentation** (searchable reference)
   - ROADMAP.md for long-term planning
   - CLAUDE.md for session startup
   - Specialized docs for deep dives
   - PolarFire Atlas MCP for vendor documentation

---

## PolarFire Atlas MCP - Vendor Documentation RAG

### What It Is

PolarFire Atlas is a custom MCP server providing semantic search over PolarFire FPGA documentation:
- **ChromaDB vector database** with 1,233+ indexed doc chunks
- **Embeddings:** BAAI/bge-small-en-v1.5 (384-dim vectors)
- **Documents:** User guides, datasheets, app notes, design guides
- **Search quality:** 0.75-0.87 similarity scores

### When to Use PolarFire Atlas MCP

**Query for:**
- IP core parameter names and valid ranges
- Pin assignment conventions
- Timing constraint examples
- Electrical specifications (voltage, current)
- Clock frequency limits
- Resource usage estimates
- DDR4/PCIe/SERDES configuration details

**Example Queries:**
```
Query: "DDR4 memory controller configuration parameters"
Returns: Memory Controller Guide excerpts with PF_DDR4 parameter table

Query: "PolarFire clocking resources CCC PLL"
Returns: Clocking Guide sections about Clock Conditioning Circuit

Query: "PCIe transceiver lane configuration"
Returns: Transceiver Guide with PCIe lane setup examples
```

**Search Quality:**
- Excellent match: 0.85-0.95 similarity
- Good match: 0.75-0.84 similarity
- Results include: Document name, page number, relevant content

**Token Cost:** ~5k tokens per query (vs 50k+ reading full PDF)

---

## PROJECT_STATE.json - Session Persistence

### Purpose
Session-independent knowledge base that survives compaction and cross-device sync.

### What to Track

**1. Architecture Decisions**
```json
{
  "architecture_decisions": [
    {
      "decision": "Use separate PDC and SDC files",
      "rationale": "PDC parser doesn't understand SDC commands",
      "impact": "All future projects must follow this pattern",
      "alternatives_considered": "Combined file (rejected - syntax errors)"
    }
  ]
}
```

**2. Key Learnings**
```json
{
  "key_learnings": [
    "Libero check_tool is too strict - use catch {} for lenience",
    "BeagleV-Fire uses /sys/kernel/debug/fpga for programming",
    "Serial automation via file-based queue eliminates manual work"
  ]
}
```

**3. File Locations and Purposes**
```json
{
  "files_created_this_session": [
    {
      "path": "tcl_scripts/beaglev_fire/led_blink_standalone.tcl",
      "purpose": "Create BeagleV-Fire LED blink project",
      "key_features": ["Automated HDL import", "Constraint association", "Pin assignments"]
    }
  ]
}
```

### When to Update PROJECT_STATE.json

**Update immediately when:**
- Creating new files or directories
- Making architecture decisions
- Discovering tool limitations or workarounds
- Establishing patterns or utilities
- Completing major milestones

**Update before:**
- Context compaction (when approaching token limits)
- End of session (even if context remains)
- Switching work locations (home -> work or vice versa)
- Pushing to Git (keeps state synchronized)

---

## Session Start Protocol

### Mandatory First Steps in Every Session

1. **Read PROJECT_STATE.json** for complete project context:
   - Last session summary and achievements
   - Architecture decisions made
   - Key learnings and patterns discovered
   - Files created and their purposes
   - Current phase and next steps

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

**Before compacting, update PROJECT_STATE.json:**

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

1. **Restore from PROJECT_STATE.json**
   - Read complete session history
   - Review architecture decisions
   - Check key learnings
   - Identify next steps

2. **Verify File System**
   - Confirm critical files still exist
   - Check for any discrepancies

3. **Resume Work**
   - Pick up where we left off using ROADMAP.md
   - No user re-explanation needed (success indicator!)

---

## Cross-Device Synchronization

### Scenario: Working on Home and Work Computers

**Challenge:** Project state needs to sync across devices

**Solution:**

1. **Before leaving device:**
   - Update PROJECT_STATE.json with all recent work
   - Commit changes:
     ```bash
     git add PROJECT_STATE.json
     git commit -m "Update project state with session summary"
     git push
     ```

2. **On arriving device:**
   - Pull latest changes:
     ```bash
     git pull
     ```
   - Read PROJECT_STATE.json to restore context
   - Review session summaries and architecture decisions

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
- PROJECT_STATE.json entry: ~10 tokens per minute of work

**Strategy:** Continuously summarize work into docs and PROJECT_STATE.json to keep active context small

---

## Agent-Based Context Management

### Background Context Manager Agent (Proposed)

**Purpose:** Autonomous agent that manages context in background

**Responsibilities:**
- Monitor token usage
- Auto-save to PROJECT_STATE.json every N minutes
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

        # Save to PROJECT_STATE.json
        project_state = read_project_state()
        project_state["files_created_this_session"].extend(recent_files)
        project_state["architecture_decisions"].extend(recent_decisions)
        write_project_state(project_state)

    def save_checkpoint(self):
        """Periodic checkpoint saves"""
        update_project_state_json()
```

---

## Success Indicators

**Context management is working well when:**
- ✅ After compaction, work resumes immediately without user re-explaining
- ✅ Cross-device work (home -> work) is seamless
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
2. **Commit often:** Include PROJECT_STATE.json in Git commits
3. **Document decisions:** When making choices, add to ROADMAP or CLAUDE.md
4. **Test cross-device:** Periodically verify sync works between home/work

### For Claude Code:
1. **Read PROJECT_STATE.json first thing every session**
2. **Update PROJECT_STATE.json frequently** (not just before compaction)
3. **Reference ROADMAP.md** for current phase and next steps
4. **Summarize work** into documentation continuously
5. **Never guess file locations** - check PROJECT_STATE.json or read filesystem

---

## Anti-Patterns to Avoid

❌ **Don't:** Rely only on conversation history
✅ **Do:** Save to PROJECT_STATE.json and docs

❌ **Don't:** Wait until compaction to save context
✅ **Do:** Update PROJECT_STATE.json continuously

❌ **Don't:** Assume file locations
✅ **Do:** Check PROJECT_STATE.json or read filesystem

❌ **Don't:** Skip session startup protocol
✅ **Do:** Read PROJECT_STATE.json every session start

❌ **Don't:** Create files without checking if they exist
✅ **Do:** Search for existing files first

---

## Example Session Timeline

### Session Start (0 tokens)
1. Read PROJECT_STATE.json: review last session and current phase
2. Read CLAUDE.md and ROADMAP.md
3. Confirm with user: "Resuming Phase 1 work?"

### During Work (50k tokens)
- Create timing constraints file
- Update PROJECT_STATE.json with file location and purpose
- Update ROADMAP.md to mark task complete

### Mid-Session Checkpoint (100k tokens)
- Save comprehensive checkpoint to PROJECT_STATE.json
- Update CLAUDE.md if any key paths changed

### Approaching Limit (150k tokens)
- Pre-compaction checklist (save all recent work)
- Compact conversation
- Post-compaction: verify PROJECT_STATE.json has all info

### Session End (175k tokens)
- Final PROJECT_STATE.json update
- Update ROADMAP.md with progress
- User commits including PROJECT_STATE.json

---

**Maintained by:** TCL Monster Project | **Last Updated:** 2025-10-22

---

## Real-World Implementation: TCL Monster Project

**Updated:** 2025-11-14
**Status:** Production-validated patterns from active development

This section documents actual context management practices used during TCL Monster development, including innovative approaches to documentation ingestion and RAG systems.

### The FPGA Documentation Challenge

**Problem:** PolarFire SoC documentation is massive:
- User guides: 200-400 pages each
- Datasheets: 300+ pages
- Application notes: 50-100 pages each  
- Total: 2000+ pages of technical documentation
- Context cost: Reading full PDFs = 50k-100k tokens each

**Impact:** Reading docs directly consumes entire context window before writing any code.

### Solution 1: FPGA MCP RAG System

**Location:** `~/fpga_mcp` (separate repository)

**Architecture:**
```
+-------------------------┐
| Claude Code Session     |
|                         |
|  "How do I configure    |------┐
|   DDR4 memory?"         |      |
+-------------------------┘      |
                                 | MCP Query
+-------------------------┐      |
| fpga_mcp MCP Server     |◀-----┘
| +-- ChromaDB            |
| |   +-- Embeddings      |
| |   +-- 1,233 chunks    |
| +-- BAAI/bge-small-en   |
|     (384-dim)           |
+-------------------------┘
          |
          | Semantic Search
          ▼
+-------------------------┐
| Indexed Documentation   |
| +-- User IO Guide       |
| +-- Clocking Guide      |
| +-- Memory Controller   |
| +-- Datasheet          |
| +-- 7 core documents    |
+-------------------------┘
```

**Implementation:**
1. **Document Preprocessing** - Semantic chunking with overlap
2. **Vector Embeddings** - BAAI/bge-small-en-v1.5 model
3. **Storage** - ChromaDB vector database
4. **Retrieval** - Cosine similarity search (0.75-0.87 scores)
5. **MCP Interface** - Exposed via Model Context Protocol server

**Query Examples:**
```python
# In fpga_mcp/scripts/test_indexing.py
queries = [
    "DDR4 memory controller configuration",
    "PolarFire clocking resources CCC",  
    "PCIe transceiver lanes",
    "FPGA power supply requirements"
]
```

**Search Quality:**
- Average similarity: 0.75-0.87
- Retrieval time: <100ms
- Context cost: ~5k tokens per query (vs 50k+ for full PDF)

**Indexed Documents (1,233 chunks):**
- User IO Guide: 199 chunks
- Clocking Guide: 111 chunks
- Board Design Guide: 55 chunks
- Datasheet: 227 chunks
- Transceiver Guide: 221 chunks
- Fabric Guide: 170 chunks
- Memory Controller: 250 chunks

**Usage Pattern:**
```
Session Start
    |
Query fpga_mcp: "DDR4 memory controller parameters"
    |
Receive: Relevant excerpts (5k tokens)
    |
Generate TCL configuration
    |
Save to PROJECT_STATE.json
```

**Benefit:** 90% reduction in documentation context cost

### Solution 2: PROJECT_STATE.json Pattern

**Location:** `/mnt/c/tcl_monster/PROJECT_STATE.json`

**Purpose:** Session-independent knowledge base

**Structure:**
```json
{
  "project_metadata": {
    "name": "TCL Monster",
    "phase": "Phase 1 - IP Generators Complete",
    "last_updated": "2025-11-14",
    "context_window_used": "87k/200k"
  },
  "session_summary": {
    "2025-11-13": {
      "goals": ["Complete BeagleV-Fire LED blink", "Automate .spi generation"],
      "achievements": ["48 LUT design", "Automated build flow"],
      "time_invested": "4 hours",
      "blockers_resolved": ["PDC/SDC separation", "Lenient error checking"]
    }
  },
  "architecture_decisions": [
    {
      "decision": "Use separate PDC and SDC files",
      "rationale": "PDC parser doesn't understand SDC commands",
      "impact": "All future projects must follow this pattern",
      "alternatives_considered": "Combined file (rejected - syntax errors)"
    }
  ],
  "key_learnings": [
    "Libero check_tool is too strict - use catch {} for lenience",
    "BeagleV-Fire uses /sys/kernel/debug/fpga for programming",
    "Serial automation via file-based queue eliminates manual work"
  ]
}
```

**Usage:**
1. **Session Start** - Read PROJECT_STATE.json to restore context
2. **During Work** - Add decisions and learnings
3. **Before Compact** - Comprehensive update
4. **Post-Compact** - Read to restore full state

**Benefit:** Complete session continuity even after compaction

### Solution 3: Documentation Structure Strategy

**Principle:** "Query-optimized documentation hierarchy"

**Structure:**
```
docs/
+-- ROADMAP.md              # Strategic overview (read at session start)
+-- CLAUDE.md               # Session startup checklist
+-- DESIGN_LIBRARY.md       # Design catalog (reference)
|
+-- Topic-Specific/         # Deep dives (read on-demand)
|   +-- beaglev_fire_guide.md
|   +-- libero_softconsole_cli_guide.md
|   +-- cli_capabilities_and_workarounds.md
|
+-- sessions/               # Session logs (for recovery)
|   +-- session_2025-11-13.md
|
+-- lessons_learned/        # Extracted patterns
    +-- constraint_association.md
    +-- error_handling_patterns.md
```

**Reading Strategy:**
1. **Always Read:** ROADMAP.md (2k tokens) + CLAUDE.md (3k tokens)
2. **Query-Based:** Topic docs only when needed
3. **Never Read:** session logs (unless recovering from compact)

**Benefit:** 5k token startup cost vs 50k+ reading everything

### Solution 4: Selective MCP Server Usage

**Philosophy:** "MCP servers are powerful but have token overhead"

**Cost Analysis:**
- Memory MCP: ~7k tokens baseline overhead
- FPGA MCP: ~2k tokens per query (pay-per-use)
- Web Search MCP: ~1k tokens per search

**Usage Policy:**
```
Use fpga_mcp:
  ✅ When querying PolarFire-specific documentation
  ✅ For IP core parameter lookups
  ✅ When troubleshooting hardware issues

  ❌ For general TCL syntax (use web search)
  ❌ For already-known information
  ❌ After information already retrieved this session

Use Memory MCP:
  ✅ For cross-project knowledge (mchp-mcp-core, fpga_mcp, tcl_monster relationships)
  ✅ For meta-work organization

  ❌ For single-project work (use PROJECT_STATE.json instead)
  ❌ When context budget is tight
```

**Configuration Pattern:**
```json
// .mcp.json (project-local, not global)
{
  "mcpServers": {
    "fpga-docs": {
      "command": "python",
      "args": ["-m", "fpga_mcp.server"],
      "env": {
        "CHROMA_DB_PATH": "/home/user/fpga_mcp/chroma_db"
      }
    }
  }
}
```

**Benefit:** Opt-in MCP usage prevents unnecessary token overhead

### Real Session Example: BeagleV-Fire Development

**Session Goal:** Complete LED blink design for BeagleV-Fire

**Context Management Flow:**

**Tokens: 0k -> 15k (Startup)**
```
1. Read PROJECT_STATE.json (2k tokens)
   +- "Last session: Built counter demo, ready for BeagleV"
   
2. Read CLAUDE.md (3k tokens)
   +- Device: MPFS025T, Libero path, BeagleV reference location
   
3. Query fpga_mcp: "BeagleV-Fire pin assignments" (5k tokens)
   +- Returns: Cape connector pinout, LED on V22
   
4. Read beaglev_fire_guide.md header (5k tokens)
   +- Reference design locations, FIC clock info
```

**Tokens: 15k -> 50k (Development)**
```
5. Create TCL scripts (working code, no docs needed)
6. Test build, encounter PDC error
7. Query fpga_mcp: "PDC vs SDC file usage" (5k tokens)
   +- Returns: Separate files, parser limitations
8. Fix and rebuild
```

**Tokens: 50k -> 85k (Transfer & Programming)**
```
9. Research FPGA programming (grep docs, 10k tokens)
10. Discover update-gateware.sh via serial exploration
11. Implement serial automation (no external docs)
```

**Tokens: 85k -> 90k (Checkpoint)**
```
12. Update PROJECT_STATE.json with:
    - BeagleV-Fire LED blink complete
    - PDC/SDC separation learning
    - Serial automation pattern
    - FPGA programming workflow
```

**Total Context Used:** 90k / 200k (45%)
**Without RAG/Structure:** Would have been 180k+ (90%)

**Key Practices:**
- ✅ fpga_mcp queried 3 times (15k tokens)
- ✅ PROJECT_STATE.json updated continuously  
- ✅ Topic docs read selectively
- ❌ Did NOT read full PolarFire documentation
- ❌ Did NOT use Memory MCP (single project focus)

### Lessons from Production Use

#### What Worked Exceptionally Well

1. **FPGA MCP RAG System**
   - Saved 100k+ tokens per session
   - Faster than searching PDFs manually
   - More accurate than web search for chip-specific info

2. **PROJECT_STATE.json**
   - Perfect for session continuity
   - Survived compaction flawlessly
   - Easy to update incrementally

3. **Structured Documentation**
   - ROADMAP.md + CLAUDE.md startup pattern
   - On-demand topic docs
   - No wasted context on irrelevant info

4. **Serial Automation Pattern**
   - Eliminated 10+ minutes of manual typing per session
   - Complete workflow automation
   - Reproducible debugging

#### What Needs Improvement

1. **MCP Server Discovery**
   - Hard to know what's indexed in fpga_mcp without querying
   - Consider adding index manifest

2. **Cross-Session Sharing**
   - PROJECT_STATE.json great for local continuity
   - Need patterns for team collaboration (multiple devs)

3. **Documentation Staleness**
   - Some docs written early, not updated as project evolved
   - Need regular review cycle

4. **Context Estimation**
   - Hard to predict token cost before reading docs
   - Consider adding token estimates to doc headers

### Recommended Workflow for New Projects

**Phase 1: Setup (Week 1)**
1. Create PROJECT_STATE.json skeleton
2. Write ROADMAP.md with phases
3. Create CLAUDE.md with paths/commands
4. If domain-specific docs exist:
   - Build RAG system (like fpga_mcp)
   - OR create structured topic docs

**Phase 2: Development (Weeks 2-N)**
1. Session start: Read PROJECT_STATE.json + CLAUDE.md (~5k tokens)
2. Query RAG system as needed (~5k tokens per query)
3. Read topic docs on-demand
4. Update PROJECT_STATE.json continuously
5. Checkpoint before compactions

**Phase 3: Sharing (Week N+1)**
1. Clean up PROJECT_STATE.json (remove noise)
2. Update ROADMAP.md with current status
3. Ensure CLAUDE.md has setup instructions
4. Push to GitHub

### Token Budget Targets

**Per Session (200k window):**
- Startup (PROJECT_STATE + CLAUDE.md): 5k
- Documentation queries (RAG/topic docs): 20-30k
- Active development (code/conversations): 100-120k
- Safety buffer (for compaction): 50k

**Red Flags:**
- Startup >10k tokens -> Documentation too large
- Documentation >50k tokens -> Need better RAG/indexing
- Active development >150k -> Risk of forced compaction

### Tools Comparison

| Approach | Token Cost | Query Speed | Accuracy | Best For |
|----------|-----------|-------------|----------|----------|
| **Read Full PDFs** | 50k-100k | Slow | Perfect | Initial learning |
| **Web Search** | 1k-5k | Fast | Variable | General knowledge |
| **RAG (fpga_mcp)** | 5k | Very fast | High (0.85+) | Domain-specific |
| **Structured Docs** | 5-10k | Medium | Perfect | Project-specific |
| **PROJECT_STATE.json** | 2k | Instant | Perfect | Session continuity |

### Future Experiments

1. **Hybrid RAG + Structured Docs**
   - Index our own docs (not just vendor PDFs)
   - Query project docs via semantic search

2. **Automated PROJECT_STATE Updates**
   - Hook into git commits
   - Auto-extract learnings from session logs

3. **Multi-Project Knowledge Graph**
   - Connect tcl_monster, fpga_mcp, beaglev-fire
   - Discover relationships automatically

4. **Token-Aware Documentation**
   - Add token cost estimates to doc headers
   - Auto-suggest most efficient reading order

---

## Summary: Context Management Maturity Model

**Level 1: Ad-hoc (0-50k tokens/session)**
- Read docs as needed
- No persistence strategy
- Repeat research every session

**Level 2: Structured (50-100k tokens/session)**
- ROADMAP.md + CLAUDE.md pattern
- Topic-specific docs
- Manual session summaries

**Level 3: RAG-Assisted (20-50k tokens/session)** <- TCL Monster is here
- Semantic document search
- PROJECT_STATE.json for continuity
- Selective MCP usage
- Structured doc hierarchy

**Level 4: Fully Autonomous (10-30k tokens/session)** <- Future goal
- Auto-updating knowledge bases
- Multi-project knowledge graphs
- Context-aware documentation
- Predictive context management

---

**Status:** Level 3 - Production-validated RAG and structured docs
**Maintained by:** Jonathan Orgill (FAE) + Claude Code
**Last Updated:** 2025-11-14

---

## CORRECTIONS (2025-11-14)

### What We Actually Use

**1. PolarFire Atlas MCP** (not Memory MCP)
- Vendor documentation RAG system (~/fpga_mcp or similar)
- 1,233+ document chunks indexed
- Semantic search for IP parameters, timing, electrical specs
- **Use for:** "How do I configure PF_CCC?" "What are DDR4 timing requirements?"

**2. PROJECT_STATE.json** (not .mcp.json)
- Project-specific state file (checked into git)
- Session summaries, architecture decisions, learnings
- **Update continuously** during development
- **Commit with code changes**

**3. High-Quality Code Generation**

The real value isn't just context management - it's **how we produce production-quality code**:

#### Verilog Best Practices
- Parameterized modules for reusability
- Descriptive signal names (not x, y, z)
- Proper clock domain crossing handling
- State machines with clear enum types

#### TCL Script Patterns
- Error checking with `catch {}` for lenient builds
- Separate constraint files (PDC vs SDC)
- Modular functions for reusable operations
- Clear comments explaining Libero-specific quirks

#### SmartDesign Automation
- Scriptable canvas creation
- Automated component instantiation
- Connection validation before build
- Export patterns for sharing designs

**Example - Quality TCL:**
```tcl
# Create clock conditioning circuit with validation
proc create_ccc {instance_name input_freq output_freq} {
    set mult [expr {$output_freq / $input_freq}]
    
    # Validate PLL multiplier range
    if {$mult < 1 || $mult > 128} {
        error "Invalid PLL multiplier: $mult (range: 1-128)"
    }
    
    create_and_configure_core \
        -core_vlnv {Actel:SgCore:PF_CCC:*} \
        -component_name $instance_name \
        -params [list "PLL_MULT:$mult" ...]
        
    puts "\[INFO\] Created $instance_name: ${input_freq}MHz -> ${output_freq}MHz"
}
```

**Example - Quality Verilog:**
```verilog
// Parameterized counter with clear naming
module generic_counter #(
    parameter WIDTH = 32,
    parameter MAX_COUNT = 100_000_000  // 1 second at 100MHz
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             enable,
    output wire             pulse_out,
    output wire [WIDTH-1:0] count_value
);

    reg [WIDTH-1:0] counter_reg;
    
    assign pulse_out = (counter_reg == MAX_COUNT - 1);
    assign count_value = counter_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_reg <= {WIDTH{1'b0}};
        end else if (enable) begin
            if (counter_reg == MAX_COUNT - 1) begin
                counter_reg <= {WIDTH{1'b0}};
            end else begin
                counter_reg <= counter_reg + 1'b1;
            end
        end
    end

endmodule
```

### Documentation That Matters

**For Your Colleague:**
1. **`cli_capabilities_and_workarounds.md`** - What's scriptable, what's not, how to work around it
2. **`libero_softconsole_cli_guide.md`** - Complete CLI reference with WSL instructions
3. **`ROADMAP.md`** - Where the project is going
4. **`PROJECT_STATE.json`** - Current state, recent decisions

**Don't focus on:**
- .mcp.json files (outdated pattern)
- Memory MCP (not used for this project)
- Token counting minutiae (interesting but not actionable)

**Do focus on:**
- Real automation examples that save time
- Code quality patterns that prevent bugs
- CLI capabilities matrix (what's possible)
- Serial automation pattern (hands-free board programming)


---

## Handling Vendor Documentation at Scale

### The Challenge

PolarFire SoC has **extensive** documentation:
- 10+ user guides (200-400 pages each)
- Multiple datasheets (300+ pages)
- 50+ application notes
- Design guides, errata sheets, programming guides
- **Total: 2,000+ pages of technical content**

**Traditional approach:** Open PDFs, Ctrl+F, read pages, copy parameters
**Problem:** Each PDF read consumes 30k-80k tokens, searches are slow, context fills up fast

### Our Solution: PolarFire Atlas MCP

**What it is:** Custom MCP server wrapping a RAG (Retrieval-Augmented Generation) system

**Architecture:**
```
Query: "DDR4 memory controller timing parameters"
    |
PolarFire Atlas MCP Server
    |
Semantic Search (BAAI/bge-small-en-v1.5 embeddings)
    |
ChromaDB Vector Database
    +-- Memory Controller Guide (250 chunks)
    +-- Datasheet (227 chunks)
    +-- User IO Guide (199 chunks)
    +-- 4 more docs...
    |
Returns: Top 5 relevant chunks with context
    +-- Chunk 1: DDR4 timing requirements table
    +-- Chunk 2: Configuration parameter descriptions
    +-- Chunk 3: Example timing constraints
```

**Token cost:** ~5k tokens per query (vs 50k+ reading full PDF)

### How We Use It

**Typical Workflow:**
1. Start design task: "Configure DDR4 for BeagleV-Fire"
2. Query PolarFire Atlas: "PF_DDR4 configuration parameters"
3. Receive: Relevant excerpts + page references
4. Generate TCL with correct parameters
5. Save parameters to PROJECT_STATE.json

**What We Query For:**
- IP core parameter names and valid ranges
- Pin assignment conventions
- Timing constraint examples
- Electrical specifications (voltage, current)
- Clock frequency limits
- Resource usage estimates

**What We DON'T Query For:**
- Already-known information (cached in PROJECT_STATE.json)
- General TCL syntax (use web search)
- Non-vendor topics (use regular documentation)

### Indexing Strategy

**Document Selection** (what we indexed):
✅ User IO Guide - Pin configuration, standards, LVDS
✅ Clocking Guide - CCC/PLL configuration
✅ Memory Controller Guide - DDR3/DDR4 parameters
✅ Datasheet - Electrical specs, resource counts
✅ Transceiver Guide - SERDES, PCIe configuration
✅ Fabric User Guide - Logic resources, routing

❌ Marketing materials
❌ Quick start guides (covered in our docs)
❌ Legacy device documentation

**Chunking Strategy:**
- Semantic chunking (respect section boundaries)
- 500-1000 tokens per chunk
- 100-token overlap between chunks
- Preserve tables and code blocks intact

**Metadata Preserved:**
- Document name
- Page number
- Section title
- Figure/table numbers

### Query Quality

**Search Similarity Scores:**
- Excellent match: 0.85-0.95
- Good match: 0.75-0.84
- Acceptable: 0.65-0.74
- Poor: <0.65 (try rephrasing)

**Example Queries and Results:**
```python
Query: "DDR4 memory controller configuration"
Top Result: Memory Controller Guide, p.47
Similarity: 0.87
Content: "PF_DDR4 Configuration Parameters table..."

Query: "PCIe transceiver lanes"
Top Result: Transceiver Guide, p.112
Similarity: 0.82
Content: "PolarFire supports up to 12 PCIe lanes..."
```

### When RAG Isn't Enough

**Limitations:**
- Can't answer "Why?" questions (design philosophy)
- Won't find info across multiple disconnected sections
- May miss very specific errata or corner cases

**Fallback strategies:**
1. Read the actual section (use page reference from RAG result)
2. Search Microchip forums/knowledge base
3. Ask FAE or support engineer
4. Experiment and validate in hardware

### Building Your Own

**If you want to replicate this:**

1. **Collect PDFs** - Download vendor documentation
2. **Extract text** - Use PyPDF2 or similar
3. **Chunk intelligently** - Semantic chunking library (LangChain, LlamaIndex)
4. **Generate embeddings** - Use sentence-transformers (BAAI/bge-small-en-v1.5)
5. **Store in vector DB** - ChromaDB, Pinecone, or Weaviate
6. **Wrap in MCP server** - Expose via Model Context Protocol
7. **Configure Claude Code** - Add to .mcp.json

**Estimated effort:** 1-2 days for initial setup, ongoing updates as docs change

**Benefits:**
- 90%+ reduction in documentation token cost
- Faster information retrieval
- More accurate (vendor-specific vs web search)
- Works offline (local vector DB)

### Integration Example

```python
# In your MCP server
from sentence_transformers import SentenceTransformer
import chromadb

model = SentenceTransformer('BAAI/bge-small-en-v1.5')
chroma_client = chromadb.Client()
collection = chroma_client.get_collection("polarfire_docs")

def search_docs(query: str, top_k: int = 5):
    # Generate query embedding
    query_embedding = model.encode(query)
    
    # Search vector database
    results = collection.query(
        query_embeddings=[query_embedding],
        n_results=top_k
    )
    
    # Return formatted results
    return {
        "query": query,
        "results": [
            {
                "document": r["metadata"]["document"],
                "page": r["metadata"]["page"],
                "content": r["document"],
                "similarity": r["distance"]
            }
            for r in results
        ]
    }
```

### Real Impact

**Session token usage comparison:**

**Without RAG (traditional):**
```
Open datasheet PDF: 80k tokens
Search for DDR parameters: manual
Open user guide: 60k tokens
Find pin assignments: manual
Open memory controller guide: 70k tokens
Total: 210k tokens (exceeds context limit!)
```

**With PolarFire Atlas RAG:**
```
Query 1 "DDR4 parameters": 5k tokens
Query 2 "Pin assignments": 5k tokens  
Query 3 "Memory timing": 5k tokens
Total: 15k tokens (14x reduction!)
```

**Time savings:**
- Finding info: 10 minutes -> 30 seconds
- Context preservation: 180k tokens saved
- Can stay in flow state (no PDF switching)

### Lessons Learned

1. **Quality over quantity** - Index the RIGHT docs, not ALL docs
2. **Chunk size matters** - Too small loses context, too large reduces precision
3. **Metadata is crucial** - Page numbers let you verify sources
4. **Update regularly** - Re-index when vendor releases new docs
5. **Validate results** - Always check page references for critical parameters

---

**Bottom Line:** RAG systems for vendor docs are the most impactful context optimization we've implemented. If you work with large technical documentation regularly, build one.


### Application Note Recreation Pattern

See `docs/APP_NOTE_AUTOMATION.md` for the complete strategy, but key points:

1. **Parse existing Libero projects** - Extract IP configs, constraints, HDL
2. **Catalog vendor app notes** - Searchable database of reference designs
3. **Adapt to different boards** - Automatically retarget pin assignments
4. **One-command deployment** - `./deploy_appnote.sh AC469 BeagleV-Fire`

This is the logical extension of our automation - not just building our own designs, but recreating and adapting vendor reference designs for any target board.

**Benefits:**
- Instant access to proven designs
- Cross-board portability
- Learning from vendor best practices
- Rapid prototyping baseline


### BeagleV-Fire Documentation Pattern

**Challenge:** BeagleV-Fire docs scattered across multiple sources:
- BeagleBoard.org GitHub repository
- Microchip reference designs
- Community wiki pages
- Hardware schematics (PDF)

**Our approach:**
1. **WebFetch for online docs** - Pull markdown/HTML directly into context
2. **Local clone of reference design** - `beaglev-fire-gateware/` for TCL examples
3. **Extract patterns** - Read TCL scripts to understand configurations
4. **Document locally** - Create `docs/beaglev_fire_guide.md` with distilled info

**Why this worked:**
- BeagleBoard docs are markdown (easy to fetch/parse)
- Reference TCL scripts are self-documenting
- One-time fetch, save to PROJECT_STATE.json
- No need for RAG (docs are well-structured and findable)

**Typical workflow:**
```bash
# Fetch once
WebFetch("https://docs.beagleboard.org/latest/boards/beaglev-fire/demos-and-tutorials.html")

# Extract key info -> beaglev_fire_guide.md
# Save pin mappings -> PROJECT_STATE.json

# Never fetch again (use local docs)
```

**Token cost:** ~10k one-time vs 5k per query with RAG

**Lesson:** For well-organized, searchable online docs, WebFetch + local caching beats RAG

