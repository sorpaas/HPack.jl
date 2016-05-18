type DynamicTable
    table::Array{Tuple{Array{UInt8}, Array{UInt8}}}
    size::Int
    max_size::Int
end

function consolidate_table!(table::DynamicTable)
    while table.size > table.max_size
        last_header = pop!(table.table)
        table.size -= length(last_header[1]) + length(last_header[2]) + 32
    end
end

function add_header!(table::DynamicTable, name::Array{UInt8}, value::Array{UInt8})
    table.size += length(name) + length(value) + 32
    unshift!(table.table, (name, value))
    consolidate_table!(table)
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

function get_header(table::DynamicTable, index:Int)
    # IETF's table indexing is 1-based.
    if index <= length(STATIC_TABLE)
        return STATIC_TABLE[index]
    else
        return table.table[index - length(STATIC_TABLE) ]
    end
end
