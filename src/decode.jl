function decode_integer(buf::IOBuffer, prefix_size)
    mask = 0xFF
    if prefix_size != 8
        mask = UInt8(1) << prefix_size - 1
    end
    value = read(buf, UInt8) & mask

    if value < mask
        return value
    end

    # The value does not fit into the prefix bits.
    total = 1
    m = 0
    octet_limit = 5

    while true
        b = read(buf, UInt8)
        total += 1
        value += (UInt(b & 127)) * (1 << m)
        m += 7

        if b & 128 != 128
            return value
        end

        #TODO handle errors here
    end
end

function decode_string(buf::IOBuffer)
    huffman = buf.data[buf.ptr] & 128 == 128
    len = decode_integer(buf, 7)
    str = readbytes(buf, nb=len)
    if huffman
        str = huffman_decode_bytes(str)
    end

    return str
end

function decode_literal(table::DynamicTable, buf::IOBuffer, index::Bool)
    prefix = index ? 6 : 4
    table_index = decode_integer(buf, prefix)

    name =
        if table_index == 0
            decode_string(buf)
        else
            get_header(table, table_index)[1]
        end

    value = decode_string(buf)

    if index
        add_header!(table, (name, value))
    end

    return (name, value)
end

function decode_indexed(table::DynamicTable, buf::IOBuffer)
    index = decode_integer(buf, 7)
    return get_header(table, index)
end

function decode(table::DynamicTable, buf::IOBuffer)
    header_list = Array{Header, 1}()

    while !eof(buf)
        initial_octet = buf.data[buf.ptr]

        if initial_octet & 128 == 128 # Indexed
            header = decode_indexed(table, buf)
            push!(header_list, header)
        elseif initial_octet & 64 == 64 # Literal with incremental indexing
            header = decode_literal(table, buf, true)
            push!(header_list, header)
        elseif initial_octet & 32 == 32 # Size update
            new_size = decode_integer(buf, 5)
            set_max_table_size!(table, new_size)
        elseif initial_octet & 16 == 16 # Literal never indexed
            header = decode_literal(table, buf, false)
            push!(header_list, header)
        else # Literal without indexing
            header = decode_literal(table, buf, false)
            push!(header_list, header)
        end
    end

    return header_list
end
