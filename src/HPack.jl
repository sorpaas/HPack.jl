module HPack

struct DecodeError <: Exception
    message::String
end

bytearr(a::Vector{UInt8}) = a
bytearr(cs::Base.CodeUnits{UInt8,String}) = convert(Vector{UInt8}, cs)
bytearr(s::String) = bytearr(codeunits(s))

include("table.jl")
include("huffman.jl")
include("encode.jl")
include("decode.jl")

export encode
export decode
export DecodeError

end # module HPack
