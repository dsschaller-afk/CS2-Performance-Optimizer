# CS2 Performance Optimizer — Improvement Roadmap

## Executive Summary

The current repository has a solid core idea: bundle a few useful Windows and CS2 tweaks into one accessible tool.
However, the implementation is currently much smaller and riskier than the README and documentation suggest.

At the moment, the project is best described as:

- a small PowerShell-based tuning script
- with a simple hardware scan
- a few registry and power plan changes
- an NVIDIA MSI-mode toggle
- and generation of a CS2 autoexec file

That is a useful starting point, but not yet a robust, trustworthy, benchmark-driven optimizer.

This roadmap explains how to evolve the project from a personal tuning script into a reliable optimization tool with:

- safer system changes
- real backup and restore
- measurable before/after benchmarking
- modular architecture
- better hardware compatibility
- improved user trust
- maintainable code and release quality

---

## 1. Current State Assessment

### What already works

The current script already provides:

- Administrator check before execution
- Basic system scan for:
  - CPU model and core count
  - GPU detection
  - current refresh rate
  - RAM module count
- Windows power optimization by enabling Ultimate Performance
- Game Mode enablement
- NetworkThrottlingIndex tweak
- NVIDIA MSI mode registry modification
- CS2 `autoexec.cfg` generation

This is a valid prototype and gives the project a real foundation.

### What is currently missing

Several important areas are either incomplete, inconsistent, or not implemented:

#### 1. Backup / Restore mismatch
The README states that the tool automatically creates a backup and provides a restore function via menu item 4.
The script currently defines a backup path, but no complete backup/restore workflow is implemented, and menu item 4 is "run all optimizations".

#### 2. Documentation vs implementation gap
The documentation and README suggest deeper functionality such as:
- advanced timer-resolution control
- more extensive kernel tuning
- background app disabling
- deeper platform-specific logic

The visible script does not currently implement these areas.

#### 3. Unsafe change model
System tweaks are applied directly with little rollback logic, no per-change validation, and no transaction-style execution.

#### 4. Low hardware abstraction
Parts of the NVIDIA logic still look too close to a single-machine setup and should be generalized.

#### 5. No real benchmark framework
The project claims measurable benefits, but there is no reproducible benchmark subsystem built into the code.

#### 6. No automated tests
There are currently no visible tests, no CI validation, and no static analysis pipeline.

#### 7. No release-grade packaging
The project is still script-first and not yet user-safe enough for wider distribution.

---

## 2. Vision: What this project should become

The ideal version of this project should become a:

**safe, benchmark-driven Windows and CS2 optimization toolkit**

with these principles:

- Every tweak is optional
- Every tweak is explained
- Every change is reversible
- Every risky action is clearly labeled
- Every claim can be measured
- Every supported platform is detected correctly
- Every release is testable and versioned

The tool should not try to be "the tweak that magically fixes everything".
It should become a transparent optimizer that helps users make informed changes and verify real outcomes.

---

## 3. Highest Priority Improvements

### A. Real Backup and Restore System

This is the single most important improvement.

Before any system modification happens, the tool should:

1. detect the current value/state
2. store it in a structured backup file
3. apply the new value
4. verify success
5. allow restoring the original state later

#### Required backup coverage

At minimum:
- Power plan state
- Registry values changed by the tool
- CS2 config file changes
- GPU MSI state if changed
- Any future service or scheduled-task changes

#### Recommended backup structure

Use a structured JSON format such as:

```json
{
  "version": "3.0.0",
  "created_at": "2026-04-15T12:00:00Z",
  "machine": {
    "hostname": "...",
    "os_version": "...",
    "cpu": "...",
    "gpu": "..."
  },
  "changes": [
    {
      "type": "registry",
      "path": "HKLM\\...",
      "name": "NetworkThrottlingIndex",
      "before": 10,
      "after": 4294967295
    }
  ]
}
```

#### Needed commands/features

- `Backup-SystemState`
- `Restore-SystemState`
- `Test-BackupIntegrity`
- `Show-ChangesSummary`

#### Why this matters

Without reliable rollback, the tool will always feel unsafe, especially for:
- registry changes
- interrupt mode changes
- future timer or scheduler changes

### B. Modular Architecture

The current script should be split into modules.

#### Recommended structure

```text
/CS2-Performance-Optimizer
  /src
    /Core
      Admin.ps1
      Logging.ps1
      Backup.ps1
      Detection.ps1
      Validation.ps1
    /Tweaks
      Windows.Power.ps1
      Windows.Network.ps1
      Windows.GameMode.ps1
      Nvidia.MSI.ps1
      CS2.Config.ps1
    /Benchmark
      Bench.Framework.ps1
      Bench.System.ps1
      Bench.CS2.ps1
    /UI
      Menu.ps1
      Reports.ps1
  /tests
    Backup.Tests.ps1
    Detection.Tests.ps1
    Nvidia.Tests.ps1
    Config.Tests.ps1
  main.ps1
```

#### Why modularization matters

It enables:
- easier maintenance
- smaller and safer changes
- better testing
- better documentation
- optional reuse of components
- future GUI or CLI packaging

### C. Risk Classification System

Not every tweak is equally safe.

The project should classify all tweaks into categories:

#### Safe
Low-risk changes with easy rollback  
Examples:
- CS2 config generation
- read-only hardware detection
- refresh-rate warnings

#### Moderate
System changes that are usually safe but affect Windows behavior  
Examples:
- power plan changes
- game mode changes
- network throttling changes

#### Advanced
Deeper tweaks that may behave differently per machine  
Examples:
- MSI mode
- interrupt routing changes
- timer resolution changes
- service-related tuning

#### Experimental
Only for advanced users after validation  
Examples:
- undocumented registry changes
- scheduler-affinity logic
- advanced process policy tuning

Each tweak should display:
- purpose
- risk level
- rollback availability
- compatibility notes

### D. Real Benchmark and Verification Layer

This project needs actual measurement, not only claims.

#### Benchmark goals

Measure before and after:
- frame pacing stability
- scheduler jitter
- DPC/ISR latency indicators
- input-related timing consistency
- average / 1% low / frametime behavior
- network latency consistency where relevant

#### Recommended benchmark modes

##### 1. System Baseline Benchmark
Before any tweak:
- run system timing tests
- capture hardware and OS data
- save report

##### 2. Post-Optimization Benchmark
After applying tweaks:
- rerun same tests
- compare results
- generate a delta report

##### 3. CS2 Session Benchmark
Optional:
- produce a recommended workflow for users to benchmark in-game with external tools

#### Report output ideas

- Markdown report
- JSON report
- CSV report
- console summary

Example:

```text
Before:
- Scheduling jitter stddev: 0.34 ms
- Active refresh rate: 60 Hz
- NetworkThrottlingIndex: default

After:
- Scheduling jitter stddev: 0.16 ms
- Active refresh rate: 144 Hz
- NetworkThrottlingIndex: disabled
```

#### Important note

Claims in the README should only remain if they can be reproduced by the benchmark implementation.

### E. Safer NVIDIA / GPU Logic

The current GPU-specific logic should be generalized.

#### Needed improvements

- Detect GPU vendor cleanly
- Detect device instance path safely
- Match exact GPU device identities instead of loose text matching
- Confirm current MSI support state before writing
- Allow restore to previous state
- Warn users that driver or motherboard behavior may differ

#### Should be added later

- AMD-specific pathway
- Intel GPU handling
- multi-GPU awareness
- laptop/hybrid-graphics awareness

---

## 4. Functional Improvements Beyond the Current Scope

These are not required for the first stabilization pass, but would significantly improve the project.

### A. CS2-aware configuration assistant

Instead of only generating a desktop file, the tool should:

- detect the actual CS2 config location
- backup existing config files
- compare current values against recommended values
- show conflicts with existing settings
- allow dry-run preview
- optionally apply directly to the correct folder

### B. Dry-Run Mode

A very important trust-building feature.

Users should be able to run:

```powershell
.\main.ps1 -DryRun
```

This would:
- scan the system
- show what would be changed
- show risk labels
- create no changes

### C. Logging and audit trail

Every run should create a log file:

```text
/logs/2026-04-15_optimization_run.log
```

Include:
- detected system info
- selected tweaks
- values before and after
- warnings
- failures
- restore instructions

### D. Exportable optimization report

After each run, the tool should be able to produce:

- summary report for the user
- benchmark comparison report
- support bundle for troubleshooting

### E. Compatibility matrix

Document support by:
- Windows version
- desktop vs laptop
- NVIDIA vs AMD vs Intel
- single GPU vs multi-GPU
- CS2 installed vs not installed

---

## 5. Code Quality Improvements

### A. PowerShell best practices

Adopt:
- strict mode
- parameter validation
- proper function naming
- structured return values
- non-silent error handling where needed

### B. Static analysis

Add:
- PSScriptAnalyzer

Use it to catch:
- style problems
- risky patterns
- missing validations
- PowerShell anti-patterns

### C. Test framework

Add:
- Pester tests

Test at least:
- backup creation
- restore logic
- config generation
- hardware detection parsing
- menu routing
- dry-run behavior
- NVIDIA path resolution logic

### D. Continuous Integration

Add GitHub Actions for:
- linting
- Pester tests
- packaging verification

---

## 6. Documentation Improvements

The documentation should be rewritten to align with reality.

### Immediate documentation fixes

- remove or reword features that are not actually implemented
- mark prototype functionality clearly
- describe every tweak honestly
- distinguish measured facts from hypotheses
- explain system risk clearly

### Recommended documentation set

- `README.md`
- `ARCHITECTURE.md`
- `TWEAKS.md`
- `RISK_MODEL.md`
- `BENCHMARKING.md`
- `RESTORE.md`
- `CHANGELOG.md`

---

## 7. UX / Product Improvements

To become genuinely usable, the project should improve the user experience.

### Recommended UX features

- cleaner menu layout
- colored risk levels
- explanation per option
- dry-run preview
- restore menu
- benchmark menu
- report export menu

### Future UX upgrades

- lightweight GUI
- preset profiles:
  - Safe
  - Competitive
  - Advanced
  - Experimental
- one-click restore
- one-click report export

---

## 8. Suggested Development Phases

### Phase 1 — Stabilization
Goal: make current functionality safe and truthful

Tasks:
- implement real backup
- implement real restore
- split code into modules
- align README with real functionality
- add logs
- add dry-run mode
- generalize GPU detection
- add test skeleton
- add PSScriptAnalyzer and Pester

Success criteria:
- all existing tweaks are reversible
- all existing features are documented correctly
- code is modular and testable

### Phase 2 — Measurement
Goal: make the optimizer evidence-based

Tasks:
- add benchmark subsystem
- create before/after reporting
- collect system and tweak outcome data
- validate performance claims
- improve compatibility reporting

Success criteria:
- every performance claim can be measured
- users can export comparison reports

### Phase 3 — Expansion
Goal: become a polished optimizer platform

Tasks:
- add AMD support
- add direct CS2 config detection and integration
- add profile presets
- improve menu UX
- optional GUI
- release packaging
- signed scripts or trusted distribution path

Success criteria:
- broader compatibility
- better trust
- easier adoption by non-technical users

---

## 9. Concrete File-Level Refactor Proposal

### Existing
- `CS2_Optimizer_Expert.ps1`

### Proposed replacements

- `main.ps1`
- `src/Core/Admin.ps1`
- `src/Core/Backup.ps1`
- `src/Core/Detection.ps1`
- `src/Core/Logging.ps1`
- `src/Core/Validation.ps1`
- `src/Tweaks/Windows.Power.ps1`
- `src/Tweaks/Windows.GameMode.ps1`
- `src/Tweaks/Windows.Network.ps1`
- `src/Tweaks/Nvidia.MSI.ps1`
- `src/Tweaks/CS2.Config.ps1`
- `src/Benchmark/Bench.Framework.ps1`
- `src/UI/Menu.ps1`
- `tests/*.Tests.ps1`

---

## 10. Recommended Immediate Next 10 Tasks

1. Implement `Backup-SystemState`
2. Implement `Restore-SystemState`
3. Add `-DryRun` support
4. Split the monolithic script into modules
5. Replace hardcoded/loose NVIDIA detection with safer device matching
6. Add a `Show-TweakDetails` layer with risk levels
7. Add structured logging
8. Add Pester tests
9. Add PSScriptAnalyzer configuration
10. Rewrite README to match current reality

---

## 11. Final Recommendation

This project has a real and usable concept, but it needs to move from:
**personal tweak script**
to
**safe, benchmark-driven optimization tool**

The next version should focus less on adding more tweaks and more on:
- safety
- rollback
- measurement
- structure
- user trust

If those fundamentals are built first, the project can become genuinely valuable.
Without them, every new tweak increases complexity faster than quality.

---

## 12. Proposed Short PR Summary

This roadmap proposes evolving the project from a monolithic PowerShell tweak script into a safer, modular, benchmark-driven optimizer.

Main priorities:
- implement real backup and restore
- modularize code
- add dry-run mode
- improve hardware safety
- add automated tests
- benchmark actual changes
- align documentation with real implementation

This is intended to improve trust, maintainability, and measurable performance outcomes.
