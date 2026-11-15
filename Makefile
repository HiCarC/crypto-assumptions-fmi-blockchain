# One command reproduces every number and figure: `make all`
# Requires the toolchain listed in docs/environment.md. Nothing here touches a live network.
PY      ?= $(HOME)/.venvs/research/bin/python
PQPY    ?= tools/.venv-pq/bin/python
FORGE   := cd contracts && forge
HALMOS  := cd contracts && FOUNDRY_DYNAMIC_TEST_LINKING=false halmos

.PHONY: all quick test coverage gas pq-venv pq-fixtures static halmos echidna certora mutation soroban sat cbom figures clean

all: test coverage gas static halmos echidna soroban cbom sat figures   ## everything except Certora (needs a key) and mutation (slow)
quick: test gas cbom figures                                            ## a few minutes

test:                ## unit, fuzz, invariant tests and the failure-mode demonstrations
	$(FORGE) test

coverage:
	$(FORGE) coverage --ir-minimum --no-match-coverage "(test|script|lib|src/demos)" --report summary \
	  | grep -E "^\| (File|src|Total)" | tee ../audit/reports/coverage.txt

gas:                 ## results/gas.json -> results/gas_table.md, fig_gas.png
	$(FORGE) test --match-test test_writeGasTable
	$(PY) scripts/gas_table.py

pq-venv:             ## isolated Python environment for the ML-DSA reference signer
	uv venv tools/.venv-pq --python 3.12
	uv pip install --python $(PQPY) -r tools/requirements-pq.txt

pq-fixtures:         ## regenerate ML-DSA signatures after any change that moves contract addresses
	$(FORGE) test --match-test test_emitDigests
	$(PQPY) tools/mldsa.py fixtures results/pq-digests.json contracts/test/fixtures/mldsa44.json

static:              ## Slither, Aderyn, Semgrep (rule set path in SEMGREP_RULES)
	cd contracts && slither . --filter-paths "lib/|test/|src/demos/" --exclude-informational --exclude-optimization > ../audit/reports/slither.txt 2>&1 || true
	cd contracts && aderyn . --path-excludes "lib/,test/,src/demos/" -o ../audit/reports/aderyn.md
	@if [ -n "$(SEMGREP_RULES)" ]; then cd contracts && semgrep --metrics=off --config $(SEMGREP_RULES)/solidity src/DvP.sol src/KeyRegistry.sol src/SettlementToken.sol src/verifiers --text > ../audit/reports/semgrep.txt 2>&1; \
	  else echo "SEMGREP_RULES not set (clone github.com/Decurity/semgrep-smart-contracts); skipping Semgrep"; fi

halmos:              ## symbolic checks, then vacuity controls (which must FAIL)
	$(HALMOS) --contract HalmosChecks | grep -E "PASS|FAIL|result" | sed 's/\x1b\[[0-9;]*m//g' | tee ../audit/reports/halmos.txt
	-$(HALMOS) --contract HalmosVacuity --match-test EXPECT_FAIL | grep -E "PASS|FAIL|result" | sed 's/\x1b\[[0-9;]*m//g' | tee ../audit/reports/halmos-vacuity.txt

echidna:
	cd contracts && FOUNDRY_DYNAMIC_TEST_LINKING=false echidna . --contract FuzzHarness --config ../audit/echidna.yaml --format text \
	  | grep -E "^echidna_|^Unique|^Corpus|^Seed|^Total" | tee ../audit/reports/echidna.txt

certora:             ## needs CERTORAKEY; uses prover minutes
	certoraRun audit/certora/SettlementToken.conf

mutation:            ## Gambit; tens of minutes to hours
	tools/mutation.sh

soroban:
	cd soroban && cargo test && stellar contract build

sat:                 ## reduced-round SHA-256 scaling; about an hour with default limits
	cd sat && $(PY) run_experiment.py && $(PY) plot.py

cbom:
	cd cbom && $(PY) build.py

figures:
	$(PY) scripts/gas_table.py
	$(PY) scripts/migration_timeline.py
	$(PY) scripts/incidents_chart.py
	@test -f results/sat_scaling.csv && (cd sat && $(PY) plot.py) || echo "no SAT data yet: run 'make sat'"

clean:
	rm -rf contracts/out contracts/cache contracts/crytic-export soroban/target sat/work
