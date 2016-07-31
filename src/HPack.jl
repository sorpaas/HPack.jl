module HPack

import HttpCommon: Headers

type DecodeError <: Exception
    message::AbstractString
end

# package code goes here
include("table.jl")
include("huffman.jl")
include("encode.jl")
include("decode.jl")

export encode
export decode
export DecodeError

end # module
