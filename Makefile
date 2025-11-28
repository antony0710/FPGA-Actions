.PHONY: test sim clean build

VVP = build/sim.vvp
SIM_SOURCES = $(wildcard tests/*.v)

build:
	mkdir -p build

$(VVP): $(SIM_SOURCES) | build
	iverilog -o $(VVP) $(SIM_SOURCES)

test: $(VVP)
	vvp $(VVP)

clean:
	rm -rf build
