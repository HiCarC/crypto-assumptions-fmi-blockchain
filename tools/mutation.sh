#!/usr/bin/env bash
# Mutation testing with Gambit: inject one small bug at a time into the core contracts and
# check that the Foundry suite notices. Writes audit/reports/mutation.csv and mutation.txt.
# Usage: tools/mutation.sh        (from the repository root; takes tens of minutes)
set -u
cd "$(dirname "$0")/../contracts"
FILES="src/KeyRegistry.sol src/SettlementToken.sol src/DvP.sol src/verifiers/ECDSAVerifier.sol src/verifiers/HybridVerifier.sol"
OUT=../audit/reports
rm -rf gambit_out && mkdir -p "$OUT"
echo "file,mutant,operator,line,result" > "$OUT/mutation.csv"

for f in $FILES; do
  rm -rf gambit_out
  gambit mutate --filename "$f" --solc solc --random_seed --skip_validate \
    --solc_remappings "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/" \
                      "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/" \
    >/dev/null 2>&1 || { echo "$f,-,-,-,GAMBIT_FAILED" >> "$OUT/mutation.csv"; continue; }
  cp "$f" /tmp/original.sol
  n=$(python3 -c "import json;print(len(json.load(open('gambit_out/gambit_results.json'))))")
  for i in $(seq 0 $((n-1))); do
    read -r mid mfile op line < <(python3 - "$i" <<'PY'
import json,sys,re
m=json.load(open('gambit_out/gambit_results.json'))[int(sys.argv[1])]
ln=re.search(r'@@ -(\d+)',m.get('diff',''))
print(m['id'],m['name'],m['description'],ln.group(1) if ln else '?')
PY
)
    cp "gambit_out/$mfile" "$f"
    if ! forge build >/dev/null 2>&1; then res=COMPILE_ERROR
    elif timeout 600 forge test --no-match-contract "Demo" >/dev/null 2>&1; then res=SURVIVED
    else res=KILLED; fi
    echo "$f,$mid,$op,$line,$res" >> "$OUT/mutation.csv"
    cp /tmp/original.sol "$f"
  done
  cp /tmp/original.sol "$f"
done
rm -rf gambit_out
python3 - "$OUT/mutation.csv" > "$OUT/mutation.txt" <<'PY'
import csv,sys,collections
rows=list(csv.DictReader(open(sys.argv[1])))
c=collections.Counter(r['result'] for r in rows)
valid=c['KILLED']+c['SURVIVED']
print(f"mutants generated: {len(rows)}   compile errors (excluded): {c['COMPILE_ERROR']}")
print(f"killed: {c['KILLED']}   survived: {c['SURVIVED']}   mutation score: {100*c['KILLED']/valid:.1f}% of {valid}" if valid else "no valid mutants")
for r in rows:
    if r['result']=='SURVIVED': print("SURVIVED", r['file'], "line", r['line'], r['operator'], "mutant", r['mutant'])
PY
cat "$OUT/mutation.txt"
