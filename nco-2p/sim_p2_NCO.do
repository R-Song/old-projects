
#####################################################################
#####################################################################
## Author: Ryan Song   											   ##		
## Date: November 27th, 2018									   ##
## Description: Simulation File for 2 parallel NCO				   ##
## 				***Part of Keplar Challenge***		               ##                     
#####################################################################
#####################################################################

vlib work
vlog p2_NCO.v
vsim p2_NCO
log {/*}
add wave {/*}

#####################################################################

# Resetting the system, 1 MHz frequency
force {resetn} 0
force {out_en} 0
force {freq} 0000001111101000
force {ld_freq} 1
force {clk} 0
run 0.5 ns
force {clk} 1
run 0.5 ns
force {clk} 0
force {resetn} 1
force {ld_freq} 0

# start sending output signal
force {out_en} 1
force {clk} 0 0 ns, 1 0.5 ns -r 1 ns

run 1500 ns

# load in new frequency of 50 MHz

force {clk} 0
force {ld_freq} 1
force {freq} 1100001101010000
force {clk} 0
run 0.5 ns
force {clk} 1
run 0.5 ns
force {clk} 0
force {ld_freq} 0

force {clk} 0 0 ns, 1 0.5 ns -r 1 ns

run 1500 ns

#####################################################################
########################***END SIMULATION***#########################


