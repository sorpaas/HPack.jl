function test_dynamic_table()
    # Section 2.3.2: The dynamic table can contain duplicate entries (i.e., entries
    # with the same name and same value). Therefore, duplicate entries MUST NOT be
    # treated as an error by a decoder.
    table = HPack.DynamicTable()
    HPack.add_header!(table, (":method", "GET"))
    HPack.add_header!(table, (":method", "GET"))

    # Section 2.3.3: Indices strictly greater than the sum of the lengths of both
    # tables MUST be treated as a decoding error.

    table = HPack.DynamicTable()
    HPack.set_max_table_size!(table, 1)
    @test_throws DecodeError HPack.get_header(table, 100)
end

test_dynamic_table()
