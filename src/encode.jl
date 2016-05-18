function encode_string_literal(buf::IOBuffer, table::DynamicTable, data::Array{UInt8}; huffman=true)
    mask::UInt8 = 0x0
    if huffman
        mask = 0x80
        data = huffman_encode_bytes(data)
    end

    h = mask | UInt8(length(data))
    write(buf, h)
    write(buf, data)
end

function encode_literal(buf::IOBuffer, table::DynamicTable, header::Header; should_index=true, options...)
    mask::UInt8 = 0x0
    if should_index
        mask = 0x40
        add_header!(table, header)
    end
    write(buf, mask)

    encode_string_literal(buf, table, header[1]; options...)
    encode_string_literal(buf, table, header[2]; options...)
end

function encode(table::DynamicTable, headers::Array{Header, 1}; options...)
    buf = IOBuffer()
    for i = 1:length(headers)
        encode_literal(buf, table, headers[i]; options...)
    end

    return takebuf_array(buf)
end
