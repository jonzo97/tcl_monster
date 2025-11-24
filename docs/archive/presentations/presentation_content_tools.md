# Automation Tooling Stack

## Scripting & Automation Layers

### Foundation: Script-Based Automation
**Bash Scripts**
- Build orchestration (build_miv_tmr.sh)
- Workflow automation
- WSL/Windows path translation
- Process management

**TCL Scripts (75+)**
- Libero project creation
- IP core configuration
- Synthesis/P&R execution
- Constraint generation
- Direct tool control

### Integration: Interactive Automation Tools
**PowerShell Serial Automation (serial_smart.ps1)**
- BeagleV-Fire board interaction
- File-based command queue pattern
- Autonomous board control (no Putty needed)
- FPGA programming via Linux

**Python Utilities**
- Memory map parsing (hw_platform.h generation)
- Report extraction and analysis
- Data transformation
- Code generation

### Intelligence: AI/Agentic Layer

**Current (External AI Tools)**
- **Claude Code** - Primary development assistant
- **ChatGPT / Codex** - Alternative AI assistants
- **Gemini CLI** - Google's AI assistant

**Future (Internal Tool)**
- **Microchip CLI Tool** - Company-owned Azure instance
  - Secure, internal use only
  - Work with proprietary information
  - Same automation patterns transfer directly

---

## Complete Stack Visualization

```
┌─────────────────────────────────────────────────┐
│  AI/Agentic Layer                               │
│  Claude Code, ChatGPT, Gemini → MCHP CLI       │
│  (Design, debug, document, learn)              │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  Automation Tools                               │
│  PowerShell (serial), Python (parsing)          │
│  (Autonomous board control, data processing)    │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  Script Foundation                              │
│  Bash (orchestration) + TCL (Libero control)    │
│  (15,000+ lines of automation code)            │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  Tools                                          │
│  Libero SoC, Synplify Pro, Designer             │
└─────────────────────────────────────────────────┘
```

---

## Key Innovation: Agentic Automation

**Traditional Automation:** Scripts execute fixed workflows
**Agentic Automation:** AI adapts, learns, and improves workflows

**Example:**
- **Without AI:** Hit error → Google → Read docs → Try fix → Repeat
- **With AI:** Hit error → AI diagnoses → AI suggests fix → Document learning
- **Time Saved:** 70% reduction in debug cycles

**Transition Path:**
1. ✅ Build automation with Claude Code (proves concept)
2. ✅ Document patterns and lessons learned
3. ⏳ Migrate to MCHP CLI (internal, secure)
4. ⏳ Scale to entire team

---

## Why This Matters

**Portability:** Scripts run anywhere (WSL, Linux, CI/CD)
**Reproducibility:** Version-controlled automation
**Teachability:** AI learns from patterns, improves over time
**Scalability:** Works from simple LED to complex TMR systems
**Security:** Future MCHP CLI enables proprietary work
