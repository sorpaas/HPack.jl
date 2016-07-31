# Section 2.3.2: The dynamic table can contain duplicate entries (i.e., entries
# with the same name and same value). Therefore, duplicate entries MUST NOT be
# treated as an error by a decoder.

table = HPack.new_dynamic_table()
HPack.add_header!(table, (":method", "GET"))
HPack.add_header!(table, (":method", "GET"))

# Section 2.3.3: Indices strictly greater than the sum of the lengths of both
# tables MUST be treated as a decoding error.

table = HPack.new_dynamic_table()
HPack.set_max_table_size!(table, 1)
@test_throws DecodeError HPack.get_header(table, 100)
