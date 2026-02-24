# AI Core

This work explores the AI Core architecture.

## Repository structure

```
.
├── rtl
├── tb
├── scripts
│   ├── sim
|   ├── syn
|   ├── post-syn-sta
|   ├── post-syn-sim
│   └── post-syn-dpa
├── sim
├── imp
├── Makefile
├── README.md
└── .gitignore
```

## Getting started

```
https://github.com/simone-machetti/ai_core.git
```

## Simulation

```
make sim TOP_LEVEL=<top_level> IN_SIZE_0=<in_size_0> IN_SIZE_1=<in_size_1> ARRAY_SIZE=<array_size> CLK_PERIOD_NS=<clk_period_ns> OUT_DIR=<out_dir>
```

## Synthesis

```
make syn TOP_LEVEL=<top_level> IN_SIZE_0=<in_size_0> IN_SIZE_1=<in_size_1> ARRAY_SIZE=<array_size> OUT_DIR=<out_dir>
```

## Post-synthesis static timing analysis

```
make post-syn-sta TOP_LEVEL=<top_level> IN_SIZE_0=<in_size_0> IN_SIZE_1=<in_size_1> ARRAY_SIZE=<array_size> CLK_PERIOD_NS=<clk_period_ns> OUT_DIR=<out_dir> NETLIST_DIR=<netlist_dir>
```

## Post-synthesis simulation

```
make post-syn-sim TOP_LEVEL=<top_level> IN_SIZE_0=<in_size_0> IN_SIZE_1=<in_size_1> ARRAY_SIZE=<array_size> CLK_PERIOD_NS=<clk_period_ns> OUT_DIR=<out_dir> NETLIST_DIR=<netlist_dir>
```

## Post-synthesis dynamic power analysis

```
make post-syn-dpa TOP_LEVEL=<top_level> IN_SIZE_0=<in_size_0> IN_SIZE_1=<in_size_1> ARRAY_SIZE=<array_size> CLK_PERIOD_NS=<clk_period_ns> OUT_DIR=<out_dir> NETLIST_DIR=<netlist_dir> VCD_DIR=<vcd_dir>
```
