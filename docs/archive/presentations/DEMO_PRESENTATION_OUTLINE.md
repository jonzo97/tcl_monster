# TCL Monster - Function Group Demo Presentation

**Duration:** 10-15 minutes (10-12 min presentation + 3-5 min Q&A)
**Audience:** FPGA function group
**Goals:**
1. Recruit collaborators
2. Solicit feature ideas
3. Demonstrate Claude Code value
4. Show transition path to MCHP CLI

---

## Slide 1: Title Slide

**Title:** TCL Monster: 10x Faster FPGA Development

**Subtitle:** Command-Line Automation for Libero + BeagleV-Fire

**Your Info:**
- Jonathan Orgill, Field Applications Engineer
- [Date]

**Visuals:**
- TCL Monster logo/icon (if you have one)
- Background: FPGA board image or abstract tech background

**Speaker Notes:**
- "Good morning/afternoon everyone!"
- "Today I'm excited to show you something that's going to change how we develop FPGA designs"
- "From idea to blinking LED on hardware in under 5 minutes - fully automated"

---

## Slide 2: The Problem

**Title:** FPGA Development is Too Slow

**Content:**
**Manual GUI Workflows Waste Time:**
- 🖱️ 50+ clicks to configure a single IP core
- 📋 Repetitive setup for every new project
- 🔄 Hard to replicate designs across different boards
- 💾 Knowledge trapped in one person's head
- ⏱️ Hours spent on routine tasks

**Real Example:**
- Simple LED blink project: 30-45 minutes manually
- Includes: project creation, HDL import, constraints, synthesis, P&R
- And that's AFTER you've done it dozens of times!

**Visuals:**
- Screenshot of Libero GUI with many dialogs open
- Frustrated engineer at desk (stock photo)
- Stopwatch/clock showing time wasted

**Speaker Notes:**
- "Who here has spent an hour clicking through Libero to set up a project?"
- "Raise your hand if you've had to recreate the same design for a different board"
- "This is the problem I set out to solve"

---

## Slide 3: The Solution

**Title:** TCL Monster - Automation + AI

**Content:**
**What is TCL Monster?**
- 🤖 Command-line automation toolkit for Libero SoC
- 📜 TCL scripts for project creation, build, and deployment
- 🎯 AI-assisted development (Claude Code)
- 📦 Reusable templates and IP generators
- 📚 Comprehensive documentation

**Key Innovation:**
```bash
# One command to create complete FPGA project
./create_instant_fpga.sh beaglev_fire led_blink

# Automated end-to-end:
# ✓ Project creation    ✓ Synthesis
# ✓ HDL import          ✓ Place & Route
# ✓ Constraints         ✓ Bitstream
```

**Time Savings:**
- Manual workflow: 30-45 min
- Automated workflow: 2-5 min
- **Result: 10x faster!**

**Visuals:**
- Before/After comparison (GUI vs command-line)
- Terminal screenshot showing one-command automation
- Graph showing time savings

**Speaker Notes:**
- "TCL Monster automates everything from project creation to bitstream generation"
- "What used to take 45 minutes now takes 5 minutes"
- "And the best part? It's repeatable and shareable"

---

## Slide 4: What We've Built

**Title:** Capabilities - What's Working Now

**Content (Two Columns):**

**Column 1: Core Automation**
- ✅ Complete project creation
- ✅ Automated build flow (synthesis → bitstream)
- ✅ Constraint generation (PDC/SDC)
- ✅ Build diagnostics (Build Doctor)
- ✅ BeagleV-Fire Linux FPGA programming

**Column 2: IP Configuration Generators**
- ✅ DDR4 Memory Controller (1-4GB configs)
- ✅ Clock Conditioning Circuit (CCC/PLL)
- ✅ UART (auto baud rate calculation)
- ✅ GPIO (1-32 pins, templates)
- ✅ PCIe (endpoint/root port, Gen1/Gen2)

**Bottom:**
**20+ Pre-Generated IP Templates Ready to Use!**

**Visuals:**
- Checkmark list with icons
- Code snippet showing simple IP generator usage
- Screenshot of template directory

**Speaker Notes:**
- "These aren't just concepts - everything you see here is working and tested on real hardware"
- "The IP generators alone save hours of GUI clicking"
- "And we have 20+ pre-configured templates you can use right now"

---

## Slide 5: Live Demo - BeagleV-Fire Automation

**Title:** Demo: HDL to Hardware in <5 Minutes

**Content:**
**BeagleV-Fire LED Blink - Complete Automation**

**What This Shows:**
1. ✍️ Write simple Verilog (led_blinker.v)
2. 🎬 Run automation script
3. ⚙️ Libero builds design (synthesis + P&R)
4. 📦 Exports .spi bitstream
5. 🚀 Programs FPGA via Linux
6. 💡 LED blinks on hardware!

**Results:**
- **Resources:** 48 LUTs, 27 FFs (0.2% of MPFS025T)
- **Build Time:** ~5 minutes (automated)
- **Pin:** Cape connector P8[3], 1 Hz blink

**[VIDEO/GIF HERE - 30-60 seconds]**
- Show serial console during programming
- Show LED blinking on hardware
- Highlight automation messages

**Visuals:**
- Embedded video/GIF of demo
- Photo of BeagleV-Fire with blinking LED
- Terminal output showing automated workflow

**Speaker Notes:**
- "Let me show you what this looks like in action"
- [Play video]
- "From Verilog to blinking LED in under 5 minutes, completely hands-off"
- "This is running on real hardware right now"

---

## Slide 6: Scaling Demo - Simple to Complex (+ TMR)

**Title:** It Scales: Counter → RISC-V → Triple Redundancy

**Content:**
**Same Workflow, Any Complexity**

**Simple:** Counter (33 LUTs, 32 FFs, 2 min)
**↓ Same automation ↓**
**Complex:** MI-V RISC-V (11,607 LUTs, 5,644 FFs, 25 min)
**↓ Same automation ↓**
**Advanced:** TMR - 3x RISC-V + Voter (NEW!)

**Triple Modular Redundancy (TMR):**
- 3x MI-V RV32IMC cores (64KB TCM each)
- Custom voter logic (2-of-3 majority voting)
- Fault detection LEDs
- Build: `./build_miv_tmr.sh` (one command, 45 min)
- Use Case: High-reliability systems (aerospace, medical)

**Key Innovation:** AI discovered SmartDesign limitation, designed HDL workaround autonomously in <1 hour

**Visuals:**
- Three-tier comparison table
- TMR architecture diagram (3 cores + voter)
- Build output showing successful synthesis

**Speaker Notes:**
- "Same automation scales from simple LED to fault-tolerant systems"
- "TMR required solving a CLI limitation - AI handled it automatically"
- "Production-ready reliability automation"

---

## Slide 7: Instant FPGA Generator (NEW!)

**Title:** 🚀 NEW: One-Command Project Generator

**Content:**
**Instant FPGA - For Your Colleagues Without Claude**

**The Problem:**
- "This looks great, but I don't have a Claude subscription"
- "How can I use this without AI?"

**The Solution:**
```bash
# One command creates complete, working project
./create_instant_fpga.sh <board> <design>

# Examples:
./create_instant_fpga.sh mpf300_eval led_blink
./create_instant_fpga.sh beaglev_fire uart_echo
./create_instant_fpga.sh mpf300_eval gpio_test
```

**What It Does (Fully Automated):**
1. Creates Libero project with device config
2. Imports HDL sources and constraints
3. Runs synthesis + place & route
4. Generates bitstream
5. Extracts reports
6. **All in 2-10 minutes!**

**Current Templates:**
- ✅ LED blink (rotating pattern)
- ⏳ UART echo (coming soon)
- ⏳ GPIO test (coming soon)

**Visuals:**
- Terminal screenshot showing usage
- Flowchart of what happens
- Example output/reports

**Speaker Notes:**
- "Built this specifically for colleagues who want to use the scripts without AI"
- "It's proof that the automation works standalone"
- "You get all the benefits even without a Claude subscription"

---

## Slide 8: IP Configuration Made Easy

**Title:** Before vs After: IP Configuration

**Content (Split Screen):**

**Before (GUI Method):**
1. Open IP Catalog
2. Find core (scroll through 100+ cores)
3. Click "Configure"
4. Dialog box opens
5. Set 15-20 parameters manually
6. Calculate values (e.g., baud divisor)
7. Click OK
8. Hope you got it right!
9. **Repeat for every core**

⏱️ **Time:** 5-10 minutes per IP core

**After (TCL Generator):**
```tcl
# One command!
source tcl_scripts/lib/generators/uart_config_generator.tcl
generate_uart_115200 "UART0" "my_uart.tcl"

# Done! Automatic:
# ✓ Baud rate divisor calculated
# ✓ Error checking (<2% error tolerance)
# ✓ FIFO config optimized
# ✓ Ready to instantiate
```

⏱️ **Time:** 10 seconds

**Example: DDR4 Configuration**
- GUI: 50+ parameter fields, geometry calculations by hand
- Generator: `generate_mpf300_4gb_ddr4 "DDR0" "ddr.tcl"` - Done!

**Visuals:**
- Screenshot of IP configurator dialog (many fields)
- Code snippet showing one-line generator call
- Stopwatch comparison

**Speaker Notes:**
- "Let's talk about IP configuration - everyone's favorite tedious task"
- "The GUI method requires you to know all the parameters upfront"
- "With generators, you specify what you want and it calculates everything"

---

## Slide 9: What YOU Can Use Today

**Title:** Available Now (No Claude Required!)

**Content:**
**Scripts & Templates (GitHub Repository):**

**Automation Scripts:**
- ✅ Project creation templates
- ✅ Build automation (synthesis + P&R)
- ✅ Constraint generators
- ✅ BeagleV-Fire programming workflow
- ✅ Instant FPGA generator

**IP Generators:**
- ✅ 5 complete generators (DDR4, CCC, UART, GPIO, PCIe)
- ✅ 20+ pre-configured templates
- ✅ Works with standard `tclsh` - no AI needed

**Documentation:**
- ✅ Complete CLI capabilities guide
- ✅ BeagleV-Fire hardware setup
- ✅ Toolchain installation guides
- ✅ Example designs with READMEs

**How to Get Started:**
1. Clone repository: [github.com/jonzo97/tcl_monster](https://github.com/jonzo97/tcl_monster)
2. Run `./create_instant_fpga.sh mpf300_eval led_blink`
3. Program your board!

**Visuals:**
- GitHub repository screenshot
- QR code to repo (optional)
- File tree showing available resources

**Speaker Notes:**
- "Everything I've shown you is available right now on GitHub"
- "You don't need a Claude subscription to use the scripts"
- "All the templates and generators work standalone"
- "Documentation explains everything step-by-step"

---

## Slide 10: Collaboration & Ideas

**Title:** Let's Build This Together!

**Content:**
**Looking For:**

**1. Collaborators**
- Help expand design library
- Test on different boards (Igloo2, SmartFusion2)
- Contribute IP generators
- Improve documentation

**2. Your Use Cases**
- What designs do you build repeatedly?
- What GUI workflows waste YOUR time?
- What boards/devices should we support next?

**3. Feature Ideas**
- What would make YOUR workflow 10x faster?
- What pain points can we automate?

**Quick Poll:**
- 🙋 Who would use Instant FPGA generator?
- 🙋 Who wants to contribute designs?
- 🙋 Who has ideas for new features?

**How to Contribute:**
- GitHub Issues: Feature requests and bug reports
- Pull Requests: Code contributions welcome
- Slack/Email: Informal discussions

**Visuals:**
- Call-to-action graphics
- Collaboration icons
- Contact information

**Speaker Notes:**
- "I built this for us - the FPGA engineers who are tired of repetitive work"
- "But it's even better with input from all of you"
- "What would YOU automate first?"
- [Pause for responses, discussion]

---

## Slide 11: Roadmap & MCHP CLI Transition

**Title:** Where We're Going

**Content:**
**Current State:**
- 🟢 Claude Code (Anthropic) - External tool, requires subscription
- 🟢 Scripts work standalone (no AI required for use)
- 🟢 Proven ROI: 10x faster development

**↓ Transition Path ↓**

**Future State:**
- 🔵 MCHP CLI Tool - Internal, secure Azure instance
- 🔵 Work with proprietary/sensitive information
- 🔵 Same automation patterns transfer directly
- 🔵 Company-wide accessibility

**Why This Matters:**
- 📊 **Proof of Concept:** TCL Monster shows AI-assisted FPGA development works
- 💼 **Business Case:** Documented time savings justify investment
- 🔧 **Ready to Migrate:** Scripts are tool-agnostic (TCL + Python)
- 🚀 **Foundation:** We're building expertise now

**Near-Term Roadmap (tcl_monster):**
- ⏳ More Instant FPGA templates (UART, SPI, I2C)
- ⏳ SmartDesign automation
- ⏳ Simulation framework (ModelSim)
- ⏳ Debugging automation (Identify, SmartDebug)

**Visuals:**
- Timeline graphic showing transition
- Roadmap with milestones
- ROI chart (time savings)

**Speaker Notes:**
- "Claude Code is great for now, but our end goal is the MCHP CLI tool"
- "This project proves the value - makes the business case easier"
- "Everything we're building here transfers directly to MCHP CLI"
- "We're not wasting time - we're building the foundation"

---

## Slide 12: Q&A + Discussion

**Title:** Questions? Ideas? Let's Discuss!

**Content:**
**Key Takeaways:**
- ✅ TCL Monster automates FPGA workflows (10x faster)
- ✅ Works today - scripts available on GitHub
- ✅ No Claude subscription required to use it
- ✅ Collaboration welcome!

**Get Started:**
- 📦 Repository: [github.com/jonzo97/tcl_monster](https://github.com/jonzo97/tcl_monster)
- 📧 Contact: [Your email]
- 💬 Slack: [Your Slack handle]

**Questions?**
- Technical details?
- How to contribute?
- Feature requests?
- Other ideas?

**Optional Discussion Topics:**
- What should we automate next?
- Which boards/devices to prioritize?
- Integration with CI/CD pipelines?
- Training/documentation needs?

**Visuals:**
- QR code to GitHub repo
- Your contact info
- Thank you message

**Speaker Notes:**
- "I'll take questions now"
- "But please also grab me afterward if you want to dive deeper"
- "I'm looking for collaborators, so if this interests you, let's talk!"
- [Answer questions]
- "Thank you!"

---

## Backup Slides (Optional - Not Presented Unless Asked)

### Backup Slide 1: Technical Architecture

**Content:**
- Project structure diagram
- File organization
- Build flow chart
- Integration points

### Backup Slide 2: Build Doctor Details

**Content:**
- What it analyzes
- Sample output
- How it helps debugging
- Future enhancements

### Backup Slide 3: BeagleV-Fire Programming Workflow

**Content:**
- Step-by-step breakdown
- Linux FPGA manager details
- Serial automation framework
- Alternative methods

---

## Presentation Tips

**Timing:**
- Slides 1-2: 2 minutes (intro + problem)
- Slides 3-4: 2 minutes (solution + capabilities)
- Slide 5: 2 minutes (BeagleV demo video)
- Slides 6-8: 3 minutes (scaling + new features)
- Slides 9-11: 3 minutes (collaboration + roadmap)
- Slide 12: 3-5 minutes (Q&A)
- **Total:** 12-15 minutes

**Delivery:**
- Start with the hook (BeagleV video on Slide 5 can open if you prefer)
- Be enthusiastic! This is cool stuff
- Pause for questions during Slide 10 (collaboration)
- Have GitHub repo open in browser (live demo backup)

**What to Have Ready:**
- BeagleV-Fire demo video (30-60 sec, embedded in slide 5)
- Terminal window with repo open (backup demo if needed)
- GitHub repo link ready to share
- Photo of BeagleV-Fire with LED lit up
- Build Doctor output screenshot

**Engagement Points:**
- Slide 2: "Raise your hand if..." (get audience involved)
- Slide 10: Quick poll about who would use/contribute
- Slide 12: Open discussion

---

**Last Updated:** 2025-11-23
**Presentation Length:** 10-15 minutes
**Status:** Ready for content creation
