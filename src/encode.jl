function encode_string_literal(buf::IOBuffer, table::DynamicTable, data::Array{UInt8}, huffman=true)
    if huffman
        data = huffman_encode_bytes(data)
        mask::UInt8 = 0x80
    else
        mask::UInt8 = 0x0
    end

    h = mask | UInt8(length(data))
    write(buf, h)
    write(buf, data)
end

function encode_literal(buf::IOBuffer, table::DynamicTable, header::(Array{UInt8}, Array{UInt8}), should_index=true)
    mask::UInt8 = 0x0
    if should_index
        mask::UInt8 = 0x40
        add_header!(table, header)
    end
    write(buf, mask)

    encode_string_literal(buf, table, header[1])
    encode_string_literal(buf, table, header[2])
end

function encode(table::DynamicTable, headers: Array{(Array{UInt8}, Array{UInt8})})
    buf = IOBuffer()
    for i = 1:length(headers)
        encode_literal(buf, table, headers[i])
    end

    return takebuf_array(buf)
end
