#!/usr/bin/env python3
"""ML-DSA-44 fixture generator for the Foundry tests. TEST KEYS ONLY (public seeds).

  mldsa.py fixtures <digests.json> <out.json>

Reads {"seed": "<hex>", "digests": {"name": "0x<32 bytes>", ...}} and writes
{"pk": "0x<ABI blob of the expanded public key>", "sigs": {"name": "0x<2420-byte signature>"}}.

Signatures follow FIPS 204 ML-DSA.Sign with an empty context string. The signer is the
Python reference shipped with ZKNoxHQ/ETHDILITHIUM (pinned submodule); nothing here is
production cryptography.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REF = os.path.join(HERE, "..", "contracts", "lib", "ETHDILITHIUM", "pythonref")
sys.path.insert(0, REF)


def main() -> None:
    if len(sys.argv) != 4 or sys.argv[1] != "fixtures":
        raise SystemExit(__doc__)
    spec = json.load(open(sys.argv[2]))
    seed = spec["seed"]

    pk_blob = subprocess.run(
        [sys.executable, os.path.join(REF, "prepare_pk_for_deployment.py"), "NIST", seed],
        cwd=REF, check=True, capture_output=True, text=True,
    ).stdout.strip()
    if not pk_blob.startswith("0x"):
        pk_blob = "0x" + pk_blob

    from dilithium_py.dilithium.default_parameters import Dilithium2 as D

    pk, sk = D.key_derive(bytes.fromhex(seed))
    sigs = {}
    for name, digest in spec["digests"].items():
        msg = bytes.fromhex(digest[2:])
        assert len(msg) == 32, name
        sig = D.sign(sk, msg, deterministic=True)
        assert D.verify(pk, msg, sig) and len(sig) == 2420
        sigs[name] = "0x" + sig.hex()

    json.dump({"seed": seed, "raw_pk_bytes": len(pk), "pk": pk_blob, "digests": spec["digests"], "sigs": sigs},
              open(sys.argv[3], "w"), indent=1, sort_keys=True)
    print(f"wrote {len(sigs)} signatures; raw public key {len(pk)} bytes; signature 2420 bytes")


if __name__ == "__main__":
    main()
