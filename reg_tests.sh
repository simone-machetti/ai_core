# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

#!/bin/bash/

# Simulation
make sim TOP_LEVEL=bas_4x8_top OUT_DIR=bas_4x8_top_radix_4 MULT_TYPE=0
make sim TOP_LEVEL=bas_4x8_top OUT_DIR=bas_4x8_top_radix_8 MULT_TYPE=1

make sim TOP_LEVEL=bas_4x4_top OUT_DIR=bas_4x4_top_radix_4 MULT_TYPE=0
make sim TOP_LEVEL=bas_4x4_top OUT_DIR=bas_4x4_top_radix_8 MULT_TYPE=1

make sim TOP_LEVEL=win_4x8_top OUT_DIR=win_4x8_top_radix_4 MULT_TYPE=0
make sim TOP_LEVEL=win_4x8_top OUT_DIR=win_4x8_top_radix_8 MULT_TYPE=1

make sim TOP_LEVEL=win_4x4_top OUT_DIR=win_4x4_top_radix_4 MULT_TYPE=0
make sim TOP_LEVEL=win_4x4_top OUT_DIR=win_4x4_top_radix_8 MULT_TYPE=1

# Synthesis
make syn TOP_LEVEL=bas_4x8_top OUT_DIR=bas_4x8_top_radix_4 MULT_TYPE=0
make syn TOP_LEVEL=bas_4x8_top OUT_DIR=bas_4x8_top_radix_8 MULT_TYPE=1

make syn TOP_LEVEL=bas_4x4_top OUT_DIR=bas_4x4_top_radix_4 MULT_TYPE=0
make syn TOP_LEVEL=bas_4x4_top OUT_DIR=bas_4x4_top_radix_8 MULT_TYPE=1

make syn TOP_LEVEL=win_4x8_top OUT_DIR=win_4x8_top_radix_4 MULT_TYPE=0
make syn TOP_LEVEL=win_4x8_top OUT_DIR=win_4x8_top_radix_8 MULT_TYPE=1

make syn TOP_LEVEL=win_4x4_top OUT_DIR=win_4x4_top_radix_4 MULT_TYPE=0
make syn TOP_LEVEL=win_4x4_top OUT_DIR=win_4x4_top_radix_8 MULT_TYPE=1
