# XXhash.jl
Julia wrapper for [xxHash](https://github.com/Cyan4973/xxHash) C library

## Examples
```julia-repl
julia> using XXhash

julia> xxh64("abc")
0x31886f2e7daf8ca4

julia> xxh32([5,3,'a'])
0xd0602ac3

julia> s=XXH64stream();

julia> xxhash_update(s,"hello");

julia> xxhash_update(s," world!");

julia> xxhash_digest(s)
0x10844a095bea2da9

julia> xxhash_tocanonical(0x31886f2e7daf8ca4)
(0x31, 0x88, 0x6f, 0x2e, 0x7d, 0xaf, 0x8c, 0xa4)

julia> xxhash_fromcanonical((0x31, 0x88, 0x6f, 0x2e, 0x7d, 0xaf, 0x8c, 0xa4))
0x31886f2e7daf8ca4
```
