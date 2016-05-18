include("huffmandata.jl")

function huffman_encode_bytes(out::IOBuffer, data::Array{UInt8}, offset::Int=0, length::Int=length(data))
    current::UInt64 = 0
    n = 0

    for i = 1:length
        b = data[offset + i] & 0xFF
        nbits = HUFFMAN_SYMBOL_TABLE[b + 1, 1]
        code = HUFFMAN_SYMBOL_TABLE[b + 1, 2]

        current <<= nbits
        current |= code
        n += nbits

        while n >= 8
            n -= 8
            write(out, UInt8(current >>> n))
            current = current & ~(current >>> n << n)
        end
    end

    if n > 0
        current <<= (8 - n)
        current |= (0xFF >>> n)
        write(out, UInt8(current))
    end
end
