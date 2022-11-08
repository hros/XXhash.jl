# XXhash.jl
Julia wrapper for [xxHash](https://github.com/Cyan4973/xxHash) C library.  
Initial xxHash algorithm has variants for 32 and 64 bit hashes.  
The XXH3 algorithm is faster and supports 64 and 128 bit hashes.  
All hash variants can be used directly, or incrementally using stream states.

## Examples
```julia-repl
julia> using XXhash

julia> xxh64("abc")
0xf4740f6daf499e0e

julia> xxh32([5,3,'a'])
0xc4aeaa41

julia> s=XXH64stream();

julia> xxhash_update(s,"hello");

julia> xxhash_update(s," world!");

julia> xxhash_digest(s)
0x10844a095bea2da9

julia> xxhash_tocanonical(0x31886f2e7daf8ca4)
(0x31, 0x88, 0x6f, 0x2e, 0x7d, 0xaf, 0x8c, 0xa4)

julia> xxhash_fromcanonical((0x31, 0x88, 0x6f, 0x2e, 0x7d, 0xaf, 0x8c, 0xa4))
0x31886f2e7daf8ca4

julia> xxh3_64([1,1,2,3,5,8])
0x49eac9036e48d1a4

julia> xxh3_128([1,1,2,3,5,8])
0x0bfce8c8d2b5ca93c770975256fdbe32
```
