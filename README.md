# HPack

[![Build Status](https://travis-ci.org/sorpaas/HPack.jl.svg?branch=master)](https://travis-ci.org/sorpaas/HPack.jl)

A pure Julia implementation for
[HPACK specification](http://http2.github.io/http2-spec/compression.html),
header compression for HTTP/2. This library is intended to be used with a HTTP/2
implementation.

Note: `JuliaWeb/HTTP.jl` includes a work-in-progress HPack decoder for Julia 1.0:
https://github.com/JuliaWeb/HTTP.jl/blob/so/lazyprep/src/HPack.jl

## Quickstart

The main functionality of HPack are in the `encode` and `decode` function. HPack
is stateful, and requires a dynamic table. The table can be created by
`DynamicTable`.

First, install `HPack`:

```julia
julia> Pkg.add("HPack")
julia> using HPack
```

### `DynamicTable`

The function takes no argument, and returns a dynamic table.

```
HPack.DynamicTable()
# => DynamicTable
```

### `encode`

The encode function is defined as `encode(table::DynamicTable, headers::Headers;
huffman=false)`. The headers are a type imported from `HttpCommon.jl` library.
The `huffman` key specifies whether it will use Huffman algorithm to compress
header values. It can be used as follows:

```
headers = Headers("custom-key" => "custom-header")

HPack.encode(HPack.DynamicTable(), headers; huffman=false)
# => [0x00; 0x0a; 0x63; 0x75; 0x73; 0x74; 0x6f; 0x6d; 0x2d; 0x6b; 0x65; 0x79;
#     0x0d; 0x63; 0x75; 0x73; 0x74; 0x6f; 0x6d; 0x2d; 0x68; 0x65; 0x61; 0x64;
#     0x65; 0x72]
```

### `decode`

The decode function is defined as `decode(table::DynamicTable, buf::IOBuffer)`.
Again, the headers are a type imported from `HttpCommon.jl`. `buf` needs to be
an IOBuffer. It will handle any valid HPack messages.

```
headers_raw =
    [0x04; 0x0c; 0x2f; 0x73; 0x61; 0x6d; 0x70; 0x6c; 0x65; 0x2f; 0x70; 0x61;
     0x74; 0x68]

HPack.decode(HPack.DynamicTable(), IOBuffer(headers_raw))
# => Headers(":path" => "/sample/path")
```
