const HeaderBinary = Tuple{Array{UInt8, 1}, Array{UInt8, 1}}
const Header = Tuple{AbstractString, AbstractString}

type DynamicTable
    table::Array{HeaderBinary, 1}
    size::Int
    max_size::Int
end

function new_dynamic_table()
    DynamicTable(Array{HeaderBinary, 1}(), 0, 4096)
end

function consolidate_table!(table::DynamicTable)
    while table.size > table.max_size
        last_header = pop!(table.table)
        table.size -= length(last_header[1]) + length(last_header[2]) + 32
    end
end

function add_header!(table::DynamicTable, header::HeaderBinary)
    name = header[1]
    value = header[2]
    table.size += length(name) + length(value) + 32
    unshift!(table.table, (name, value))
    consolidate_table!(table)
end

function add_header!(table::DynamicTable, header::Header)
    add_header!(table, (convert(Array{UInt8, 1}, header[1]),
                        convert(Array{UInt8, 1}, header[2])))
end

function set_max_table_size!(table::DynamicTable, size::Int)
    table.max_size = size
    consolidate_table!(table)
end

STATIC_TABLE =
    [
     (b":authority", b"")
     (b":method", b"GET")
     (b":method", b"POST")
     (b":path", b"/")
     (b":path", b"/index.html")
     (b":scheme", b"http")
     (b":scheme", b"https")
     (b":status", b"200")
     (b":status", b"204")
     (b":status", b"206")
     (b":status", b"304")
     (b":status", b"400")
     (b":status", b"404")
     (b":status", b"500")
     (b"accept-", b"")
     (b"accept-encoding", b"gzip, deflate")
     (b"accept-language", b"")
     (b"accept-ranges", b"")
     (b"accept", b"")
     (b"access-control-allow-origin", b"")
     (b"age", b"")
     (b"allow", b"")
     (b"authorization", b"")
     (b"cache-control", b"")
     (b"content-disposition", b"")
     (b"content-encoding", b"")
     (b"content-language", b"")
     (b"content-length", b"")
     (b"content-location", b"")
     (b"content-range", b"")
     (b"content-type", b"")
     (b"cookie", b"")
     (b"date", b"")
     (b"etag", b"")
     (b"expect", b"")
     (b"expires", b"")
     (b"from", b"")
     (b"host", b"")
     (b"if-match", b"")
     (b"if-modified-since", b"")
     (b"if-none-match", b"")
     (b"if-range", b"")
     (b"if-unmodified-since", b"")
     (b"last-modified", b"")
     (b"link", b"")
     (b"location", b"")
     (b"max-forwards", b"")
     (b"proxy-authenticate", b"")
     (b"proxy-authorization", b"")
     (b"range", b"")
     (b"referer", b"")
     (b"refresh", b"")
     (b"retry-after", b"")
     (b"server", b"")
     (b"set-cookie", b"")
     (b"strict-transport-security", b"")
     (b"transfer-encoding", b"")
     (b"user-agent", b"")
     (b"vary", b"")
     (b"via", b"")
     (b"www-authenticate", b"")
     ]

function get_header(table::DynamicTable, index)
    # IETF's table indexing is 1-based.
    if index <= length(STATIC_TABLE)
        return STATIC_TABLE[index]
    else
        if index > length(STATIC_TABLE) + table.max_size
            throw(DecodeError("Index greater than sum of both static and dynamic tables."))
        else
            if index > length(STATIC_TABLE) + length(table.table)
                throw(DecodeError("Index out of bound."))
            else
                return table.table[index - length(STATIC_TABLE)]
            end
        end
    end
end
