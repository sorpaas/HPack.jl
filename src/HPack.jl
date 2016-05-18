module HPack

# package code goes here
include("table.jl")
include("huffman.jl")
include("encode.jl")
include("decode.jl")

export encode
export decode

end # module
