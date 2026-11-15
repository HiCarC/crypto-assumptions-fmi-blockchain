| Verification mode | Key (bytes) | Signature (bytes) | Verification gas | × ECDSA | Full transfer gas | Transfers per 30M gas |
|---|---|---|---|---|---|---|
| ECDSA secp256k1 (today's default) | 20 | 65 | 7,955 | 1× | 146,191 | 205 |
| ECDSA P-256, native precompile | 64 | 64 | 12,712 | 2× | not measured | |
| ECDSA P-256, contract code only | 64 | 64 | 237,278 | 30× | not measured | |
| Hybrid: secp256k1 + P-256 | 84 | 288 | 26,322 | 3× | not measured | |
| ML-DSA-44 (post-quantum), contract code | 1,312 | 2,420 | 8,146,057 | 1,024× | 8,253,943 | 3 |
| Hybrid: secp256k1 + ML-DSA-44 | 1,332 | 2,656 | 8,160,630 | 1,026× | 8,342,154 | 3 |

One-off registration of an ML-DSA-44 public key (stored expanded, 22,400 bytes): 5,263,193 gas.
