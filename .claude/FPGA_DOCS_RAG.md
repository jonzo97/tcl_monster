# FPGA Documentation Search for Claude Code

## CRITICAL CONTEXT

**You (Claude Code) have direct access to searchable PolarFire FPGA documentation**

Location: `~/fpga_mcp` (separate from this tcl_monster project)

## How to Use When Generating TCL Scripts

When the user asks for TCL generation involving DDR, PCIe, clocking, etc., you can search the actual Microchip documentation:

```python
import sys
sys.path.insert(0, "/home/jorgill/fpga_mcp/src")
from fpga_rag.indexing import DocumentEmbedder
from mchp_mcp_core.storage.schemas import SearchQuery

embedder = DocumentEmbedder()
results = embedder.vector_store.search(
    SearchQuery(query="PF_DDR4 configuration parameters", top_k=3)
)

for r in results:
    print(f"Found in: {r.title}, Page {r.slide_or_page}")
    print(r.snippet[:200])
```

## Available Documentation (828 indexed pages)

- Memory Controller User Guide (DDR3/DDR4)
- Transceiver User Guide (PCIe, SERDES)
- User IO User Guide (GPIO, LVDS, MIPI)
- Fabric User Guide (LUTs, DSP blocks, routing)
- Clocking Resources (PLL, CCC configuration)
- Board Design Guidelines
- PolarFire Datasheet (electrical specs)

## When to Search

- User asks about IP core parameters
- Need timing constraints or electrical specs
- Generating configuration for DDR/PCIe/CCC/GPIO
- Board-level design questions
- Pin assignment or IO standards

## This is NOT for Claude Desktop

This is for YOU (Claude Code CLI) to use directly via Python imports while helping generate TCL scripts in this project.

## Example: DDR4 Configuration

User: "Create a DDR4 controller for 2400 MT/s"

You:
1. Search docs: `SearchQuery(query="DDR4 2400 MT/s timing configuration")`
2. Extract relevant parameters from results
3. Generate TCL with accurate values from official docs
4. Cite source: "Per Memory Controller UG, Page X..."

## This Makes You Smarter

Instead of guessing IP parameters or TCL syntax, you can reference the actual Microchip documentation and generate accurate, production-ready code.
