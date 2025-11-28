# FPGA-Actions

This repository provides a minimal, local-runnable CI setup for FPGA simulation development using Icarus Verilog (iverilog). It includes:
- A GitHub Actions workflow that installs `iverilog` and runs `make test`.
- A `Dockerfile` to run the same steps locally in a container.
- A `Makefile` and a simple example in `tests/` demonstrating compilation and simulation with `iverilog` + `vvp`.
- A helper script `run_local_ci.sh` to build and run the Docker image locally.

Quick start
-----------
Run tests locally using Docker (recommended):

```bash
./run_local_ci.sh
```
Make the script executable if needed:

```bash
chmod +x run_local_ci.sh
```
Or run the build & test manually inside a container:

```bash
docker build -t fpga-actions-ci:local .
docker run --rm -v "$(pwd)":/workspace -w /workspace fpga-actions-ci:local
```
Run tests locally without Docker (if `iverilog` is installed on your machine):

```bash
make test
```
GitHub Actions
--------------

The workflow in `.github/workflows/ci.yml` runs on `ubuntu-latest`, installs `iverilog` via `apt` and runs `make test`.
Local workflow runner alternative
---------------------------------

You can also use `act` (https://github.com/nektos/act) to run the GitHub Actions workflow locally. Install `act`, then run:
```bash
act -j sim
```
Notes
-----

- The example tests produce `wave.vcd` in the repository root when run; view with `gtkwave` or other VCD viewers.
- This setup is intentionally minimal — adapt `Dockerfile`, workflow, and `Makefile` to match your project's simulator flags, test vectors, and artifact handling.

Have fun simulating!
# FPGA-Actions