include("huffmandata.jl")

function huffman_encode_bytes(data::Vector{UInt8}, offset::Int=0, length::Int=length(data))
    out = IOBuffer()
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

    return take!(out)
end


function huffman_decode_bytes(buf::Vector{UInt8}, length::Int=length(buf))
    state = 0
    accept = true
    out = IOBuffer()

    for i = 1:length
        c = buf[i]
        x = c >> 4
        for j = 1:2
            t = HUFFMAN_DECODE_TABLE[state * 16 + x + 1, :]
            flags = t[2]

            if flags & 0x4 != 0 # Decode fail
                return nothing
            end

            if flags & 0x2 != 0 # Decode success
                write(out, UInt8(t[3]))
            end

            state = t[1]
            accept = (flags & 0x1) != 0

            x = c & 0xf
        end

    end

    if !accept
        return nothing # Decoder ended prematurely
    end

    return take!(out)
end
