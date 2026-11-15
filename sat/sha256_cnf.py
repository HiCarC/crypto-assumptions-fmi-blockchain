#!/usr/bin/env python3
"""Reduced-round SHA-256 as CNF (Tseitin encoding), plus a reference implementation.

Scope: one compression-function call from the standard initial value on a 512-bit block,
with the number of rounds reduced to `rounds` (the full function has 64). The preimage
problem is: given the 256-bit output, find message bits that produce it.

This is a plain textbook encoding written for this repository so that every clause can be
inspected: XOR, choice and majority gates are encoded directly, modular addition as a
ripple-carry chain. It is NOT an optimised cryptanalytic encoding; specialised encoders in
the literature (e.g. Nossum 2012; Nejati et al. 2017, "Adaptive restart and CEGAR-based
solver for inverting cryptographic hash functions") do better, and the absolute times
measured here should be read with that in mind. Correctness is checked in `selftest()`:
the 64-round reference equals hashlib, and for each reduced round count the CNF with a
fully fixed message unit-propagates to the reference digest.
"""
import hashlib
import struct

K = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
]
IV = [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19]
M32 = 0xFFFFFFFF


def _rotr(x, n):
    return ((x >> n) | (x << (32 - n))) & M32


def compress_reference(words, rounds):
    """`rounds`-round SHA-256 compression of 16 message words from the standard IV."""
    w = list(words)
    for t in range(16, rounds):
        s0 = _rotr(w[t - 15], 7) ^ _rotr(w[t - 15], 18) ^ (w[t - 15] >> 3)
        s1 = _rotr(w[t - 2], 17) ^ _rotr(w[t - 2], 19) ^ (w[t - 2] >> 10)
        w.append((w[t - 16] + s0 + w[t - 7] + s1) & M32)
    a, b, c, d, e, f, g, h = IV
    for t in range(rounds):
        t1 = (h + (_rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25)) + ((e & f) ^ (~e & g)) + K[t] + w[t]) & M32
        t2 = ((_rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22)) + ((a & b) ^ (a & c) ^ (b & c))) & M32
        h, g, f, e, d, c, b, a = g, f, e, (d + t1) & M32, c, b, a, (t1 + t2) & M32
    return [(x + y) & M32 for x, y in zip(IV, [a, b, c, d, e, f, g, h])]


class Encoder:
    """Words are lists of 32 literals, index 0 = least significant bit. Literal 0 is unused;
    constants are represented by a dedicated always-true variable."""

    def __init__(self):
        self.nvars = 1
        self.clauses = [[1]]  # variable 1 is TRUE
        self.T, self.F = 1, -1

    def new(self):
        self.nvars += 1
        return self.nvars

    def const_word(self, value):
        return [self.T if (value >> i) & 1 else self.F for i in range(32)]

    def fresh_word(self):
        return [self.new() for _ in range(32)]

    def xor2(self, a, b):
        if a in (self.T, self.F):
            a, b = b, a
        if b == self.F:
            return a
        if b == self.T:
            return -a
        o = self.new()
        self.clauses += [[-a, -b, -o], [a, b, -o], [a, -b, o], [-a, b, o]]
        return o

    def xor3(self, a, b, c):
        return self.xor2(self.xor2(a, b), c)

    def and2(self, a, b):
        for x, y in ((a, b), (b, a)):
            if x == self.F:
                return self.F
            if x == self.T:
                return y
        o = self.new()
        self.clauses += [[-a, -b, o], [a, -o], [b, -o]]
        return o

    def or2(self, a, b):
        return -self.and2(-a, -b)

    def maj(self, a, b, c):
        consts = [x for x in (a, b, c) if x in (self.T, self.F)]
        if consts:
            rest = [x for x in (a, b, c) if x not in (self.T, self.F)]
            if len(consts) == 3:
                return self.T if sum(x == self.T for x in consts) >= 2 else self.F
            if len(consts) == 2:
                return rest[0] if consts[0] != consts[1] else consts[0]
            return self.or2(*rest) if consts[0] == self.T else self.and2(*rest)
        o = self.new()
        self.clauses += [[-a, -b, o], [-a, -c, o], [-b, -c, o], [a, b, -o], [a, c, -o], [b, c, -o]]
        return o

    def ch(self, e, f, g):
        """e ? f : g"""
        if e == self.T:
            return f
        if e == self.F:
            return g
        o = self.new()
        self.clauses += [[-e, -f, o], [-e, f, -o], [e, -g, o], [e, g, -o]]
        return o

    def rotr(self, w, n):
        return [w[(i + n) % 32] for i in range(32)]

    def shr(self, w, n):
        return [w[i + n] if i + n < 32 else self.F for i in range(32)]

    def wxor3(self, a, b, c):
        return [self.xor3(x, y, z) for x, y, z in zip(a, b, c)]

    def add(self, a, b):
        out, carry = [], self.F
        for x, y in zip(a, b):
            out.append(self.xor3(x, y, carry))
            carry = self.maj(x, y, carry)
        return out

    def add_many(self, *ws):
        acc = ws[0]
        for w in ws[1:]:
            acc = self.add(acc, w)
        return acc

    def fix(self, lit, value):
        self.clauses.append([lit if value else -lit])


def encode(rounds, target, known_bits=None):
    """CNF for: rounds-reduced compression(message) == target.

    known_bits: dict {bit index 0..511: 0/1} of message bits given to the solver
    (bit index = 32*word + bit, bit 0 = least significant). Returns (encoder, message literals).
    """
    enc = Encoder()
    msg = [enc.fresh_word() for _ in range(16)]
    w = list(msg)
    for t in range(16, rounds):
        s0 = enc.wxor3(enc.rotr(w[t - 15], 7), enc.rotr(w[t - 15], 18), enc.shr(w[t - 15], 3))
        s1 = enc.wxor3(enc.rotr(w[t - 2], 17), enc.rotr(w[t - 2], 19), enc.shr(w[t - 2], 10))
        w.append(enc.add_many(w[t - 16], s0, w[t - 7], s1))
    st = [enc.const_word(v) for v in IV]
    for t in range(rounds):
        a, b, c, d, e, f, g, h = st
        S1 = enc.wxor3(enc.rotr(e, 6), enc.rotr(e, 11), enc.rotr(e, 25))
        chw = [enc.ch(x, y, z) for x, y, z in zip(e, f, g)]
        t1 = enc.add_many(h, S1, chw, enc.const_word(K[t]), w[t])
        S0 = enc.wxor3(enc.rotr(a, 2), enc.rotr(a, 13), enc.rotr(a, 22))
        mj = [enc.maj(x, y, z) for x, y, z in zip(a, b, c)]
        t2 = enc.add(S0, mj)
        st = [enc.add(t1, t2), a, b, c, enc.add(d, t1), e, f, g]
    out = [enc.add(enc.const_word(v), s) for v, s in zip(IV, st)]
    for word, value in zip(out, target):
        for i, lit in enumerate(word):
            enc.fix(lit, (value >> i) & 1)
    flat = [lit for word in msg for lit in word]
    for idx, bit in (known_bits or {}).items():
        enc.fix(flat[idx], bit)
    return enc, flat


def write_dimacs(enc, path):
    with open(path, "w") as fh:
        fh.write(f"p cnf {enc.nvars} {len(enc.clauses)}\n")
        for c in enc.clauses:
            fh.write(" ".join(map(str, c)) + " 0\n")


def words_from_model(model_true, flat):
    return [sum(1 << i for i in range(32) if flat[32 * w + i] in model_true) for w in range(16)]


def selftest():
    # 1. the 64-round reference equals hashlib on a correctly padded one-block message
    data = b"fmi chapter 2"
    block = data + b"\x80" + b"\x00" * (55 - len(data)) + struct.pack(">Q", 8 * len(data))
    words = list(struct.unpack(">16I", block))
    assert struct.pack(">8I", *compress_reference(words, 64)) == hashlib.sha256(data).digest()
    # 2. for several round counts, the CNF with the whole message fixed is satisfiable with
    #    the reference digest and unsatisfiable with a digest that differs in one bit
    from pysat.solvers import Cadical153

    for r in (1, 8, 16, 17, 24, 64):
        target = compress_reference(words, r)
        known = {32 * w + i: (words[w] >> i) & 1 for w in range(16) for i in range(32)}
        enc, _ = encode(r, target, known)
        with Cadical153(bootstrap_with=enc.clauses) as s:
            assert s.solve(), r
        bad = list(target)
        bad[3] ^= 1 << 7
        enc, _ = encode(r, bad, known)
        with Cadical153(bootstrap_with=enc.clauses) as s:
            assert not s.solve(), r
    print("selftest ok")


if __name__ == "__main__":
    selftest()
