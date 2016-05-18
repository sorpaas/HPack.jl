using HPack
using Base.Test

@test HPack.huffman_encode_bytes(b"www.example.com") == [0xf1;0xe3;0xc2;0xe5;0xf2;0x3a;0x6b;0xa0;0xab;0x90;0xf4;0xff]

@test HPack.huffman_decode_bytes(HPack.huffman_encode_bytes(b"www.example.com")) == b"www.example.com"
