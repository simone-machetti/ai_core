# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

#!/bin/bash/

make sim TOP_LEVEL=bas_4x8_top OUT_DIR=bas_4x8_top MULT_TYPE=0
make sim TOP_LEVEL=bas_4x8_top OUT_DIR=bas_4x8_top MULT_TYPE=1

make sim TOP_LEVEL=bas_4x4_top OUT_DIR=bas_4x4_top MULT_TYPE=0
make sim TOP_LEVEL=bas_4x4_top OUT_DIR=bas_4x4_top MULT_TYPE=1

make sim TOP_LEVEL=win_4x8_top OUT_DIR=win_4x8_top MULT_TYPE=0
make sim TOP_LEVEL=win_4x8_top OUT_DIR=win_4x8_top MULT_TYPE=1
