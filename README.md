# AI Core

Fixed-point multiply-accumulate Processing Elements (PEs) for AI/ML inference, implemented in SystemVerilog. The project explores several algorithmic variants — Baseline, Winograd, and Squaring — each available in standard and split-cell (sub-lane) configurations, and characterizes them through simulation, logic synthesis, static timing analysis, and dynamic power analysis.

## Repository structure

```
.
├── rtl/                        SystemVerilog source modules
├── tb/                         Verilator testbenches
├── scripts/                    EDA flow scripts
│   ├── sim/                    Pre-synthesis simulation flow
│   │   └── run.sh              Verilator compile and run script
│   ├── syn/                    Logic synthesis flow
│   │   ├── run.tcl             Yosys top-level synthesis script (ASAP7)
│   │   ├── compile.tcl         RTL read and elaboration script
│   │   └── abc.tcl             ABC technology mapping script
│   ├── post-syn-sta/           Post-synthesis static timing analysis flow
│   │   └── run.tcl             OpenSTA timing analysis script
│   ├── post-syn-sim/           Post-synthesis gate-level simulation flow
│   │   ├── run.sh              Verilator compile and run script
│   │   └── filelist.f          Gate-level netlist and cell library filelist
│   ├── post-syn-dpa/           Post-synthesis dynamic power analysis flow
│   │   └── run.tcl             OpenSTA power analysis script
│   └── flow/                   End-to-end automation scripts
│       ├── run_regres.sh       Full regression runner across all PE variants
│       ├── ext_results.sh      Result extraction from synthesis/STA/DPA reports
│       └── gen_charts.sh       Chart generation from extracted results
├── doc/                        Documentation and results
│   ├── charts/                 Output charts
│   │   ├── area/               Area comparison charts (PNG + Python scripts)
│   │   ├── freq/               Maximum frequency comparison charts
│   │   └── power/              Dynamic power comparison charts
│   ├── data/                   Extracted results in tabular form
│   │   ├── area/               area.csv, area.md
│   │   ├── freq/               freq.csv, freq.md
│   │   └── power/              power.csv, power.md
│   └── diagrams/               Architecture diagrams
│       └── ai-core.excalidraw  PE architecture diagram (Excalidraw)
├── sim/                        Simulation outputs (generated)
├── imp/                        Synthesis/STA/DPA outputs (generated)
├── Makefile                    Build system entry point
├── sourceme.sh                 Environment setup (tool paths, CODE_HOME)
└── CLAUDE.md                   AI assistant guidance for this repository
```

## Environment setup

Source the environment script once before running any command. It sets tool paths for Verilator, Yosys, Yosys-Slang, OpenSTA, OpenROAD, and sets `CODE_HOME`:

```bash
source sourceme.sh
```

## Commands

### Pre-synthesis simulation (Verilator)

```bash
make sim TOP_LEVEL=<top_level> CLK_PERIOD_NS=<val> OUT_DIR=<name> [PARAMS="KEY=VAL ..."]
```

Outputs go to `sim/<OUT_DIR>/output/`. A `activity.vcd` waveform is produced for dynamic power analysis.

### Logic synthesis (Yosys + ABC, ASAP7 target)

```bash
make syn TOP_LEVEL=<top_level> OUT_DIR=<name> [PARAMS="KEY=VAL ..."] [KEEP_HIERARCHY=1]
```

Set `KEEP_HIERARCHY=1` to preserve module boundaries in the netlist (skips `flatten`). Default is `0` (fully flattened). `TOP_LEVEL` can be any module in the hierarchy, not only the top-level PEs.

### Post-synthesis static timing analysis (OpenSTA)

```bash
make post-syn-sta TOP_LEVEL=<top_level> CLK_PERIOD_NS=<val> OUT_DIR=<name> NETLIST_DIR=<netlist_dir>
```

### Post-synthesis gate-level simulation

```bash
make post-syn-sim TOP_LEVEL=<top_level> CLK_PERIOD_NS=<val> OUT_DIR=<name> NETLIST_DIR=<netlist_dir> [PARAMS="KEY=VAL ..."]
```

### Post-synthesis dynamic power analysis (OpenSTA)

```bash
make post-syn-dpa TOP_LEVEL=<top_level> CLK_PERIOD_NS=<val> OUT_DIR=<name> NETLIST_DIR=<netlist_dir> VCD_DIR=<vcd_dir> [KEEP_HIERARCHY=1]
```

Set `KEEP_HIERARCHY=1` (requires a hierarchical netlist) to also produce `power_hierarchy.rpt` with a per-instance breakdown.

### Cleanup

```bash
make clean-sim OUT_DIR=<name>   # remove one simulation run
make clean-imp OUT_DIR=<name>   # remove one synthesis/STA/DPA run
make clean-all                  # remove all sim/ and imp/ directories
```

## Architecture

Each PE is a fixed-point multiply-accumulate array that sums the products of 64 input pairs and adds one or more accumulators. All PEs share a common 3-stage pipeline:

```
Input FFs (ff_n) → Partial Product Generator → Compression Tree (cpr_tree) → Output FF
```

- **Stage 1**: `ff_n` registers the `a_i` and `b_i` input arrays.
- **Stage 2**: The partial product generator produces compressed partial sums; `cpr_tree` compresses them in stage 0 and optionally stores the result in a pipeline register (when `IS_PIPELINED = 1`).
- **Stage 3**: `cpr_tree` completes the reduction; `ff` registers the final 48-bit output.

With `IS_PIPELINED = 1` the latency is 3 clock cycles; with `IS_PIPELINED = 0` it is 2 clock cycles.

### PE variants

| Top-level module         | Algorithm   | PP generator       | Accumulators | Notes                              |
|--------------------------|-------------|--------------------|--------------|------------------------------------|
| `top_bas_4x8`            | Baseline    | `bas_4x8`          | 1            | Standard 4×8 Booth array           |
| `top_bas_4x8_sc`         | Baseline SC | `bas_4x8_sc`       | 1            | B split into two 4-bit sub-lanes   |
| `top_win_4x8`            | Winograd    | `win_4x8`          | 3            | Winograd pairing halves multipliers|
| `top_win_4x8_sc`         | Winograd SC | `win_4x8_sc`       | 3            | Winograd + B sub-lane split        |
| `top_sqr_4x8_sc`         | Squaring SC | `sqr_4x8_sc`       | 3            | (a+b_lo)^2 + 16*(a+b_hi)^2         |
| `top_sqr_4x8_sc_alpha`   | Squaring α  | `sqr_alpha_array`  | 0            | 32 inputs, configurable square/sum |

### Algorithms

**Baseline (BAS)** — Computes `out = Σ(a[i] × b[i]) + acc[0]` directly using a Booth multiplier array over 64 pairs. The split-cell variant (`_sc`) decomposes the 8-bit B operand into `B = B_lo + 16 × B_hi`, processing each 4-bit half with a separate (narrower) Booth array to reduce the critical path.

**Winograd (WIN)** — Exploits the identity `(a+b)(c+d)` to pair adjacent inputs and compute `(a[i+1]+b[i]) × (a[i]+b[i+1])` using a single multiply per pair, halving the multiplier count. The split-cell variant further decomposes B into halves.

**Squaring (SQR)** — Replaces multiplication with squaring via the identity `(a+b)^2 = a^2 + 2ab + b^2`. Computes `Σ[(a[k]+b_lo[k])^2 + 16×(a[k]+b_hi[k])^2]` using dedicated squaring cells (`sqr_s_4_bit`, `sqr_s_5_bit`) that are more area-efficient than general multipliers.

### Booth encoding

Both partial product generators (`bas_4x8`, `win_4x8`, `bas_4x8_sc`, `win_4x8_sc`) support two Booth encodings, selected at elaboration time by `MULT_TYPE`:

| `MULT_TYPE` | Encoding  | Partial products per multiplier | Operations                |
|-------------|-----------|---------------------------------|---------------------------|
| `0`         | Radix-4   | `(IN_WIDTH_A + 1) / 2`          | `{0, ±B, ±2B}`            |
| `1`         | Radix-8   | `(IN_WIDTH_A + 2) / 3`          | `{0, ±B, ±2B, ±3B, ±4B}`  |

Radix-8 produces fewer partial products (faster compression tree) at the cost of a wider encoding table (the `±3B` term).

### Compression tree

`cpr_tree` is a three-stage hierarchical 4:2 compressor tree. It takes up to PP_SIZE partial products plus ACC_SIZE 48-bit accumulators and reduces them to a single 48-bit output:

```
Stage 0: 8 groups × (PP_SIZE/8) inputs → 8 groups × 2 outputs  [pipeline FF here]
Stage 1: 4 groups ×        4 inputs    → 4 groups × 2 outputs
Stage 2: 2 groups ×        4 inputs    → 2 groups × 2 outputs
Final:   (4 outputs + ACC_SIZE accumulators) → cpr_n_2 → add_n → 48-bit result
```

Between stages, `ext_n` conditionally sign/zero-extends and optionally left-shifts the compressor outputs to grow the bit width. The `is_signed_i` and `is_shift_i` port arrays (15 entries each) control the extension mode for every stage/lane position.

## Module hierarchy

```
top_bas_4x8 / top_bas_4x8_sc
├── ff_n            (input registers for a_i, b_i)
├── bas_4x8 / bas_4x8_sc
│   ├── mult_array
│   │   ├── booth_r4 → booth_r4_cell → fa
│   │   └── booth_r8 → booth_r8_cell
│   └── cpr_n_2 → cpr_4_2 → cpr_4_2_bit → fa
├── cpr_tree
│   ├── cpr_n_2
│   ├── ext_n
│   ├── ff_n        (internal pipeline register)
│   └── add_n
└── ff              (output register)

top_win_4x8 / top_win_4x8_sc
├── ff_n
├── win_4x8 / win_4x8_sc
│   ├── add_mult_array → booth_r4/r8
│   └── cpr_n_2
├── cpr_tree
└── ff

top_sqr_4x8_sc
├── ff_n
├── sqr_4x8_sc
│   └── add_sqr_array → sqr_s_5_bit → sqr_u_4_bit + ha
├── cpr_tree
└── ff

top_sqr_4x8_sc_alpha
├── ff_n
├── sqr_alpha_array → sqr_s_4_bit → sqr_u_3_bit + ha
├── cpr_tree_alpha → cpr_n_2, ext_n, add_n, ff_n
└── ff
```

## Parameters

| Parameter     | Scope                  | Values              | Description                                      |
|---------------|------------------------|---------------------|--------------------------------------------------|
| `IS_PIPELINED`| All top-levels         | `0`, `1`            | Enable pipeline register in cpr_tree             |
| `MULT_TYPE`   | BAS/WIN top-levels     | `0` = R4, `1` = R8  | Booth encoding radix                             |
| `IS_SQUARE`   | `top_sqr_4x8_sc_alpha` | `0`, `1`            | Square inputs (`1`) or accumulate them (`0`)     |
| `IN_SIZE`     | Internal               | `64` (fixed)        | Number of multiply-accumulate lanes              |
| `IN_WIDTH_A`  | Internal               | `4` (fixed)         | Bit width of operand A                           |
| `IN_WIDTH_B`  | Internal               | `8` (fixed)         | Bit width of operand B                           |
| `ACC_SIZE`    | Internal               | `1` or `3`          | Number of 48-bit accumulator inputs              |
| `ACC_WIDTH`   | Internal               | `48` (fixed)        | Bit width of accumulator and output              |

## Testbenches

Each PE top-level has a matching testbench in `tb/`. All testbenches follow the same structure:

- **Clock/reset generation**: configurable period via `` `CLK_PERIOD_NS `` define.
- **Random tests**: 1000 iterations of randomized inputs and accumulator values.
- **Corner cases**: max-positive, min-negative, mixed-sign, and zero inputs.
- **Self-checking**: the testbench computes the expected result in software and calls `$fatal` on any mismatch.
- **VCD dump**: `activity.vcd` capturing the DUT hierarchy, used as stimulus for dynamic power analysis.
- **Post-synthesis support**: compile with `` `define POST_SYNTH `` to instantiate the flattened gate-level netlist instead of the RTL.

| Testbench                    | DUT                      | Expected function                                                    |
|------------------------------|--------------------------|----------------------------------------------------------------------|
| `tb_top_bas_4x8`             | `top_bas_4x8`            | `Σ(a[i]×b[i]) + acc[0]`                                             |
| `tb_top_bas_4x8_sc`          | `top_bas_4x8_sc`         | `Σ(a[i]×b[i]) + acc[0]`                                             |
| `tb_top_win_4x8`             | `top_win_4x8`            | `Σ[(a[i+1]+b[i])×(a[i]+b[i+1])] + Σacc`                            |
| `tb_top_win_4x8_sc`          | `top_win_4x8_sc`         | Winograd with B sub-lane split + Σacc                                |
| `tb_top_sqr_4x8_sc`          | `top_sqr_4x8_sc`         | `Σ[(a[k]+b_lo[k])^2 + 16×(a[k]+b_hi[k])^2] + Σacc`                 |
| `tb_top_sqr_4x8_sc_alpha`    | `top_sqr_4x8_sc_alpha`   | `Σ(a[i]^2)` or `Σ(a[i])` depending on `IS_SQUARE`                  |

## RTL modules reference

### Primitives

| Module          | Description                                                       |
|-----------------|-------------------------------------------------------------------|
| `fa`            | 1-bit full adder                                                  |
| `ha`            | 1-bit half adder                                                  |
| `ff`            | WIDTH-bit D flip-flop with active-low asynchronous reset          |
| `ff_n`          | Array of SIZE D flip-flops, WIDTH bits each                       |
| `sign_ext`      | Sign extension from IN_WIDTH to OUT_WIDTH bits                    |
| `shifter_n`     | Static barrel shifter for an array of values                      |
| `ext_n`         | Runtime-controlled sign/zero extension with optional left shift   |
| `add_n`         | Signed (IN_WIDTH+1)-bit adder                                     |
| `adder_n`       | Signed SIZE-bit adder                                             |

### Compressor hierarchy

| Module          | Description                                                       |
|-----------------|-------------------------------------------------------------------|
| `cpr_4_2_bit`   | 1-bit 4:2 compressor cell (two cascaded full adders)              |
| `cpr_4_2`       | Multi-bit 4:2 compressor with sign extension                      |
| `cpr_n_2`       | Tree of 4:2 compressors reducing N inputs to sum + carry          |
| `cpr_tree`      | Full 3-stage compression tree with accumulators and pipeline FF   |
| `cpr_tree_alpha`| Compression tree variant for `top_sqr_4x8_sc_alpha`              |

### Booth multipliers

| Module           | Description                                                      |
|------------------|------------------------------------------------------------------|
| `booth_r4_cell`  | Radix-4 Booth encoder cell: {0, ±B, ±2B}                        |
| `booth_r4`       | Radix-4 Booth multiplier (PP_SIZE = (A_width+1)/2)               |
| `booth_r8_cell`  | Radix-8 Booth encoder cell: {0, ±B, ±2B, ±3B, ±4B}              |
| `booth_r8`       | Radix-8 Booth multiplier (PP_SIZE = (A_width+2)/3)               |
| `mult_array`     | Array of parallel Booth multipliers (R4 or R8 selectable)        |

### Squaring units

| Module           | Description                                                      |
|------------------|------------------------------------------------------------------|
| `sqr_u_3_bit`    | Unsigned 3-bit squarer (combinational truth-table logic)         |
| `sqr_u_4_bit`    | Unsigned 4-bit squarer (combinational truth-table logic)         |
| `sqr_s_4_bit`    | Signed 4-bit squarer (2's complement → magnitude + sqr_u_3_bit) |
| `sqr_s_5_bit`    | Signed 5-bit squarer (2's complement → magnitude + sqr_u_4_bit) |
| `sqr_alpha_array`| Array: either a[i]^2 or a[i] passthrough, selected by IS_SQUARE |
| `add_sqr_array`  | Array: pp[i] = (a[i]+b[i])^2 using sqr_s_5_bit                  |

### Partial product generators

| Module           | Description                                                      |
|------------------|------------------------------------------------------------------|
| `bas_4x8`        | Baseline 4×8 PP generator (8 lanes, full 8-bit B)                |
| `bas_4x8_sc`     | Baseline split-cell (8 lanes × 2 sub-lanes, B split into halves) |
| `add_mult_array` | Winograd pairing: (a[i+1]+b[i]) × (a[i]+b[i+1]) per pair        |
| `win_4x8`        | Winograd 4×8 PP generator (8 lanes, Winograd pairing)            |
| `win_4x8_sc`     | Winograd split-cell (8 lanes × 2 sub-lanes)                      |
| `sqr_4x8_sc`     | Squaring split-cell: (a+b_lo)^2 + 16*(a+b_hi)^2 per lane        |
