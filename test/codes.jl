function test_encode_decode()
    @test HPack.huffman_encode_bytes(HPack.bytearr("www.example.com")) ==
        [0xf1; 0xe3; 0xc2; 0xe5; 0xf2; 0x3a; 0x6b; 0xa0; 0xab; 0x90; 0xf4; 0xff]

    @test HPack.huffman_decode_bytes(HPack.huffman_encode_bytes(HPack.bytearr("www.example.com"))) == convert(Vector{UInt8}, b"www.example.com")

    @test HPack.decode(HPack.DynamicTable(), IOBuffer([0x82; 0x84])) == [(":method", "GET"), (":path", "/")]

    ## Below are examples copied from Appendix C

    ### C.2.1

    headers = [("custom-key", "custom-header")]
    headers_raw =
        [0x00; 0x0a; 0x63; 0x75; 0x73; 0x74; 0x6f; 0x6d; 0x2d; 0x6b; 0x65; 0x79;
         0x0d; 0x63; 0x75; 0x73; 0x74; 0x6f; 0x6d; 0x2d; 0x68; 0x65; 0x61; 0x64;
         0x65; 0x72]

    @test HPack.encode(HPack.DynamicTable(), headers; huffman=false) == headers_raw

    @test HPack.decode(HPack.DynamicTable(), IOBuffer(headers_raw)) == headers

    ### C.2.2

    headers = [(":path", "/sample/path")]
    headers_raw =
        [0x04; 0x0c; 0x2f; 0x73; 0x61; 0x6d; 0x70; 0x6c; 0x65; 0x2f; 0x70; 0x61;
         0x74; 0x68]

    @test HPack.decode(HPack.DynamicTable(), IOBuffer(HPack.encode(HPack.DynamicTable(), headers; huffman=true))) == headers

    @test HPack.decode(HPack.DynamicTable(), IOBuffer(headers_raw)) == headers
end

function test_client_server()
    ### Server and client examples
    request_headers = [(":method", "GET"),
                       ( ":path", "/"),
                       ( ":scheme", "http"),
                       ( ":authority", "127.0.0.1:9000"),
                       ( "accept", "*/*"),
                       ( "accept-encoding", "gzip, deflate"),
                       ( "user-agent", "HTTP2.jl")]

    response_headers = [(":status", "404"),
                        ("server", "nghttpd nghttpd2/1.10.0"),
                        ("date", "Thu, 02 Jun 2016 19:00:13 GMT"),
                        ("content-type", "text/html; charset=UTF-8")]

    client_dt = HPack.DynamicTable()
    server_dt = HPack.DynamicTable()

    request_headers_raw = HPack.encode(client_dt, request_headers; huffman=true)
    @test HPack.decode(server_dt, IOBuffer(request_headers_raw)) == request_headers

    request_headers_raw = HPack.encode(client_dt, request_headers; huffman=false)
    @test HPack.decode(server_dt, IOBuffer(request_headers_raw)) == request_headers

    response_headers_raw = HPack.encode(server_dt, response_headers; huffman=true)
    @test HPack.decode(client_dt, IOBuffer(response_headers_raw)) == response_headers
end

function test_nghttp_response()
    #### Recorded nghttp server response
    response_headers_raw = [0x8d,0x76,0x90,0xaa,0x69,0xd2,0x9a,0xe4,0x52,0xa9,0xa7,0x4a,0x6b,0x13,0x01,0x5c,0x20,0x5c,0x1f,0x61,0x96,0xdf,0x3d,0xbf,0x4a,0x00,0x4a,0x65,0xb6,0xa5,0x04,0x00,0xb8,0xa0,0x5f,0xb8,0x26,0xee,0x32,0xda,0x98,0xb4,0x6f,0x5f,0x92,0x49,0x7c,0xa5,0x89,0xd3,0x4d,0x1f,0x6a,0x12,0x71,0xd8,0x82,0xa6,0x0e,0x1b,0xf0,0xac,0xf7]

    client_dt = HPack.DynamicTable()
    #HPack.encode(client_dt, request_headers; huffman=false)
    response_headers = HPack.decode(client_dt, IOBuffer(response_headers_raw))
    println("Headers")
    println("======================")
    for header in response_headers
        println(header)
    end
end

test_encode_decode()
test_client_server()
test_nghttp_response()
