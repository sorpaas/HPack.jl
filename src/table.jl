const HeaderBinary = Tuple{Array{UInt8, 1}, Array{UInt8, 1}}
const Header = Tuple{String, String}

mutable struct DynamicTable
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
    pushfirst!(table.table, (name, value))
    consolidate_table!(table)
end

function add_header!(table::DynamicTable, header::Header)
    add_header!(table, (bytearr(header[1]), bytearr(header[2])))
end

function set_max_table_size!(table::DynamicTable, size::Int)
    table.max_size = size
    consolidate_table!(table)
end

const STATIC_TABLE =
    [
     (bytearr(":authority"                    ), bytearr(""             ))
     (bytearr(":method"                       ), bytearr("GET"          ))
     (bytearr(":method"                       ), bytearr("POST"         ))
     (bytearr(":path"                         ), bytearr("/"            ))
     (bytearr(":path"                         ), bytearr("/index.html"  ))
     (bytearr(":scheme"                       ), bytearr("http"         ))
     (bytearr(":scheme"                       ), bytearr("https"        ))
     (bytearr(":status"                       ), bytearr("200"          ))
     (bytearr(":status"                       ), bytearr("204"          ))
     (bytearr(":status"                       ), bytearr("206"          ))
     (bytearr(":status"                       ), bytearr("304"          ))
     (bytearr(":status"                       ), bytearr("400"          ))
     (bytearr(":status"                       ), bytearr("404"          ))
     (bytearr(":status"                       ), bytearr("500"          ))
     (bytearr("accept-"                       ), bytearr(""             ))
     (bytearr("accept-encoding"               ), bytearr("gzip, deflate"))
     (bytearr("accept-language"               ), bytearr(""             ))
     (bytearr("accept-ranges"                 ), bytearr(""             ))
     (bytearr("accept"                        ), bytearr(""             ))
     (bytearr("access-control-allow-origin"   ), bytearr(""             ))
     (bytearr("age"                           ), bytearr(""             ))
     (bytearr("allow"                         ), bytearr(""             ))
     (bytearr("authorization"                 ), bytearr(""             ))
     (bytearr("cache-control"                 ), bytearr(""             ))
     (bytearr("content-disposition"           ), bytearr(""             ))
     (bytearr("content-encoding"              ), bytearr(""             ))
     (bytearr("content-language"              ), bytearr(""             ))
     (bytearr("content-length"                ), bytearr(""             ))
     (bytearr("content-location"              ), bytearr(""             ))
     (bytearr("content-range"                 ), bytearr(""             ))
     (bytearr("content-type"                  ), bytearr(""             ))
     (bytearr("cookie"                        ), bytearr(""             ))
     (bytearr("date"                          ), bytearr(""             ))
     (bytearr("etag"                          ), bytearr(""             ))
     (bytearr("expect"                        ), bytearr(""             ))
     (bytearr("expires"                       ), bytearr(""             ))
     (bytearr("from"                          ), bytearr(""             ))
     (bytearr("host"                          ), bytearr(""             ))
     (bytearr("if-match"                      ), bytearr(""             ))
     (bytearr("if-modified-since"             ), bytearr(""             ))
     (bytearr("if-none-match"                 ), bytearr(""             ))
     (bytearr("if-range"                      ), bytearr(""             ))
     (bytearr("if-unmodified-since"           ), bytearr(""             ))
     (bytearr("last-modified"                 ), bytearr(""             ))
     (bytearr("link"                          ), bytearr(""             ))
     (bytearr("location"                      ), bytearr(""             ))
     (bytearr("max-forwards"                  ), bytearr(""             ))
     (bytearr("proxy-authenticate"            ), bytearr(""             ))
     (bytearr("proxy-authorization"           ), bytearr(""             ))
     (bytearr("range"                         ), bytearr(""             ))
     (bytearr("referer"                       ), bytearr(""             ))
     (bytearr("refresh"                       ), bytearr(""             ))
     (bytearr("retry-after"                   ), bytearr(""             ))
     (bytearr("server"                        ), bytearr(""             ))
     (bytearr("set-cookie"                    ), bytearr(""             ))
     (bytearr("strict-transport-security"     ), bytearr(""             ))
     (bytearr("transfer-encoding"             ), bytearr(""             ))
     (bytearr("user-agent"                    ), bytearr(""             ))
     (bytearr("vary"                          ), bytearr(""             ))
     (bytearr("via"                           ), bytearr(""             ))
     (bytearr("www-authenticate"              ), bytearr(""             ))
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
