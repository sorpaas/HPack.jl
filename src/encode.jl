function encode_string_literal(buf::IOBuffer, data::Array{UInt8}; huffman=true)
    mask::UInt8 = 0x0
    if huffman
        mask = 0x80
        data = huffman_encode_bytes(data)
    end

    h = mask | UInt8(length(data))
    write(buf, h)
    write(buf, data)
end

function encode_literal(buf::IOBuffer, header::Header; options...)
    mask::UInt8 = 0x0
    write(buf, mask)

    encode_string_literal(buf, header[1]; options...)
    encode_string_literal(buf, header[2]; options...)
end

function encode_indexed(buf::IOBuffer, index::UInt8, header::Header; options...)
    mask::UInt8 = 0x40
    write(buf, mask | index)

    encode_string_literal(buf, header[2]; options...)
end

function encode_totally_indexed(buf::IOBuffer, index::UInt8; options...)
    mask::UInt8 = 0x80
    write(buf, mask | index)
end

function find_totally_indexed(name::Array{UInt8, 1}, value::Array{UInt8, 1})
    for i = 1:length(STATIC_TABLE)
        if STATIC_TABLE[i][1] == name && STATIC_TABLE[i][2] == value
            return Nullable(UInt8(i))
        end
    end
    return Nullable{UInt8}()
end

function encode(table::DynamicTable, headers::Headers; options...)
    buf = IOBuffer()
    for header in headers
        index = find_totally_indexed(convert(Array{UInt8, 1}, header[1]),
                                     convert(Array{UInt8, 1}, header[2]))
        if isnull(index)
            encode_literal(buf, (convert(Array{UInt8, 1}, header[1]),
                                 convert(Array{UInt8, 1}, header[2])); options...)
        else
            encode_totally_indexed(buf, index.value; options...)
        end
    end

    return takebuf_array(buf)
end
