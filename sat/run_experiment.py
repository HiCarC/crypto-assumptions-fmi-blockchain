#!/usr/bin/env python3
"""How do today's SAT solvers scale on reduced-round SHA-256 preimage instances?

Two sweeps, both on one compression call from the standard initial value:

  A. rounds:  all 512 message bits unknown, rounds = 12, 13, ... until every solver times out.
  B. unknown: full 64 rounds, all but k message bits given to the solver, k = 4, 8, ...
              (at full rounds, does the solver do better than trying the 2^k candidates?)

Output: results/sat_scaling.csv (one row per instance and solver). Every solved instance is
checked by recomputing the hash from the solver's model.

Usage: run_experiment.py [--timeout 120] [--instances 3]
This measures specific solvers on a specific, unoptimised encoding. It says nothing about
what a different algorithm could do, and nothing here extrapolates to an attack cost.
"""
import argparse
import csv
import os
import random
import subprocess
import time
from concurrent.futures import ThreadPoolExecutor

import sha256_cnf as S

HERE = os.path.dirname(os.path.abspath(__file__))
WORK = os.path.join(HERE, "work")
OUT = os.path.join(HERE, "..", "results", "sat_scaling.csv")
SOLVERS = {
    "kissat": ["kissat", "-q"],
    "cadical": ["cadical", "-q"],
    "cryptominisat": ["cryptominisat5", "--verb", "0"],
}


def solve(solver, path, timeout):
    t0 = time.perf_counter()
    try:
        p = subprocess.run(SOLVERS[solver] + [path], capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return "TIMEOUT", timeout, None
    dt = time.perf_counter() - t0
    if p.returncode == 10:
        model = {int(x) for line in p.stdout.splitlines() if line.startswith("v") for x in line[1:].split() if int(x) > 0}
        return "SAT", dt, model
    return ("UNSAT" if p.returncode == 20 else f"ERROR{p.returncode}"), dt, None


def instance(sweep, rounds, k, seed):
    rng = random.Random(f"fmi-chapter2/{sweep}/{rounds}/{k}/{seed}")
    words = [rng.getrandbits(32) for _ in range(16)]
    target = S.compress_reference(words, rounds)
    unknown = set(range(512)) if k is None else set(rng.sample(range(512), k))
    known = {i: (words[i // 32] >> (i % 32)) & 1 for i in range(512) if i not in unknown}
    enc, flat = S.encode(rounds, target, known)
    path = os.path.join(WORK, f"{sweep}_r{rounds}_k{k if k is not None else 512}_s{seed}.cnf")
    S.write_dimacs(enc, path)
    return path, enc, flat, target


def run_point(sweep, rounds, k, args, active, writer, fh):
    insts = [instance(sweep, rounds, k, s) for s in range(args.instances)]
    for solver in list(active):
        with ThreadPoolExecutor(args.instances) as ex:
            res = list(ex.map(lambda it: solve(solver, it[0], args.timeout), insts))
        solved = 0
        for seed, ((path, enc, flat, target), (status, dt, model)) in enumerate(zip(insts, res)):
            verified = ""
            if status == "SAT":
                verified = S.compress_reference(S.words_from_model(model, flat), rounds) == target
                solved += 1
            writer.writerow([sweep, rounds, 512 if k is None else k, seed, solver, enc.nvars, len(enc.clauses), status, f"{dt:.3f}", verified])
            fh.flush()
        print(f"{sweep} rounds={rounds} unknown={512 if k is None else k} {solver}: {solved}/{len(insts)} solved", flush=True)
        if solved == 0:
            active.discard(solver)  # assume harder points also time out; stated in the annex
    for it in insts:
        os.remove(it[0])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--timeout", type=int, default=120)
    ap.add_argument("--instances", type=int, default=3)
    args = ap.parse_args()
    os.makedirs(WORK, exist_ok=True)
    S.selftest()
    with open(OUT, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["sweep", "rounds", "unknown_bits", "seed", "solver", "variables", "clauses", "status", "seconds", "model_verified"])
        active = set(SOLVERS)
        for r in range(12, 33):
            if not active:
                break
            run_point("A_rounds", r, None, args, active, w, fh)
        active = set(SOLVERS)
        for k in range(4, 65, 4):
            if not active:
                break
            run_point("B_unknown_bits", 64, k, args, active, w, fh)
    print("wrote", OUT)


if __name__ == "__main__":
    main()
