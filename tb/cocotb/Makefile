SIM = icarus
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(abspath rtl/async_fifo.sv)
COCOTB_TOPLEVEL = async_fifo
COCOTB_TEST_MODULES = test_async_fifo
DATA_WIDTH ?= 8
DEPTH ?= 16
COMPILE_ARGS += -g2012 -Pasync_fifo.DATA_WIDTH=$(DATA_WIDTH) -Pasync_fifo.DEPTH=$(DEPTH)
export PYTHONPATH := $(abspath tb/cocotb):$(PYTHONPATH)
include $(shell cocotb-config --makefiles)/Makefile.sim
