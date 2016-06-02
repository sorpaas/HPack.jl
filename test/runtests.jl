using HPack
using Base.Test

@test HPack.huffman_encode_bytes(b"www.example.com") ==
    [0xf1; 0xe3; 0xc2; 0xe5; 0xf2; 0x3a; 0x6b; 0xa0; 0xab; 0x90; 0xf4; 0xff]

@test HPack.huffman_decode_bytes(HPack.huffman_encode_bytes(b"www.example.com")) == b"www.example.com"

@test HPack.decode(HPack.new_dynamic_table(), IOBuffer([0x82; 0x84])) ==
    [(b":method", b"GET")
     (b":path", b"/")]

## Below are examples copied from Appendix C

### C.2.1

headers = [(b"custom-key", b"custom-header")]
headers_raw =
    [0x40; 0x0a; 0x63; 0x75; 0x73; 0x74; 0x6f; 0x6d; 0x2d; 0x6b; 0x65; 0x79;
     0x0d; 0x63; 0x75; 0x73; 0x74; 0x6f; 0x6d; 0x2d; 0x68; 0x65; 0x61; 0x64;
     0x65; 0x72]

@test HPack.encode(HPack.new_dynamic_table(), headers; huffman=false) ==
    headers_raw

@test HPack.decode(HPack.new_dynamic_table(), IOBuffer(headers_raw)) == headers

### C.2.2

headers = [(b":path", b"/sample/path")]
headers_raw =
    [0x04; 0x0c; 0x2f; 0x73; 0x61; 0x6d; 0x70; 0x6c; 0x65; 0x2f; 0x70; 0x61;
     0x74; 0x68]

@test HPack.decode(HPack.new_dynamic_table(), IOBuffer(HPack.encode(HPack.new_dynamic_table(), headers; huffman=true))) == headers

@test HPack.decode(HPack.new_dynamic_table(), IOBuffer(headers_raw)) == headers

### Server and client examples

request_headers = [(b":method", b"GET"),
                   (b":path", b"/"),
                   (b":scheme", b"http"),
                   (b":authority", b"127.0.0.1:9000"),
                   (b"accept", b"*/*"),
                   (b"accept-encoding", b"gzip, deflate"),
                   (b"user-agent", b"HTTP2.jl")]

response_headers = [(b":status", b"404"),
                    (b"server", b"nghttpd nghttpd2/1.10.0"),
                    (b"date", b"Thu, 02 Jun 2016 19:00:13 GMT"),
                    (b"content-type", b"text/html; charset=UTF-8")]

client_dt = HPack.new_dynamic_table()
server_dt = HPack.new_dynamic_table()

request_headers_raw = HPack.encode(client_dt, request_headers; huffman=true)
@test HPack.decode(server_dt, IOBuffer(request_headers_raw)) == request_headers

response_headers_raw = HPack.encode(server_dt, response_headers; huffman=true)
@test HPack.decode(client_dt, IOBuffer(response_headers_raw)) == response_headers

#### Recorded nghttp server response

response_headers_raw = [0x8d,0x76,0x90,0xaa,0x69,0xd2,0x9a,0xe4,0x52,0xa9,0xa7,0x4a,0x6b,0x13,0x01,0x5c,0x20,0x5c,0x1f,0x61,0x96,0xdf,0x3d,0xbf,0x4a,0x00,0x4a,0x65,0xb6,0xa5,0x04,0x00,0xb8,0xa0,0x5f,0xb8,0x26,0xee,0x32,0xda,0x98,0xb4,0x6f,0x5f,0x92,0x49,0x7c,0xa5,0x89,0xd3,0x4d,0x1f,0x6a,0x12,0x71,0xd8,0x82,0xa6,0x0e,0x1b,0xf0,0xac,0xf7]

client_dt = HPack.new_dynamic_table()
HPack.encode(client_dt, request_headers; huffman=false)
response_headers = HPack.decode(client_dt, IOBuffer(response_headers_raw))
println("Headers")
println("======================")
for i = 1:length(response_headers)
    print(ascii(response_headers[i][1]))
    print(": ")
    print(ascii(response_headers[i][2]))
    print("\n")
end
