# HPack

[![Build Status](https://travis-ci.org/sorpaas/HPack.jl.svg?branch=master)](https://travis-ci.org/sorpaas/HPack.jl)

A pure Julia implementation for [HPACK specification](http://http2.github.io/http2-spec/compression.html), header compression for HTTP/2. This library is intended to be used with a HTTP/2 implementation.

## Quickstart

```julia
julia> Pkg.add("HPack")

julia> using HPack
julia> HPack.encode(HPack.new_dynamic_table(), [(b"custom-key", b"custom-header")]; huffman=false)
julia> HPack.decode(HPack.new_dynamic_table(), IOBuffer([0x82; 0x84]))
```
