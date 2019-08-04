# Declarations mirroring the C declarations in xxhash.h
#=
32 bit hash functions
=#
"""
    xxh32(d, seed=0)

Compute a hash of any object `d` using the 32 bit [xxHash](http://cyan4973.github.io/xxHash) algorithm and `seed`.

# Examples
```julia-repl
julia> xxh32("abc")
0xfe8990bc
```
"""
@inline function xxh32(data::Any, seed::Union{Int32,UInt32}=UInt32(0))::UInt32
   ccall((:XXH32, libxxhash), Cuint,
      (Ptr{Cvoid}, Csize_t, Cuint),
      Ref(data), sizeof(data), seed % UInt32)
end

struct XXH32_state_t
   total_len_32::UInt32
   large_len::UInt32
   v1::UInt32
   v2::UInt32
   v3::UInt32
   v4::UInt32
   mem32::NTuple{4,UInt32}
   memsize::UInt32
   reserved::UInt32 # never read nor write, might be removed in a future version
end

@inline function XXH32_createState()::Ptr{XXH32_state_t}
   ccall((:XXH32_createState, libxxhash), Ptr{XXH32_state_t}, ())
end
@inline function XXH32_freeState(state::Ptr{XXH32_state_t})::Cint
   ccall((:XXH32_freeState, libxxhash), Cint,
      (Ptr{XXH32_state_t},), state)
end
@inline function XXH32_copyState(dst_state::Ptr{XXH32_state_t},
                                 src_state::Ptr{XXH32_state_t})
   ccall((:XXH32_copyState, libxxhash), Cvoid,
      (Ptr{XXH32_state_t}, Ptr{XXH32_state_t}),
      dst_state, src_state)
end
@inline function XXH32_reset(state::Ptr{XXH32_state_t},  seed::Cuint)::Cint
   ccall((:XXH32_reset, libxxhash), Cuint,
         (Ptr{XXH32_state_t}, Cuint), state, seed)
end
@inline function XXH32_update(state::Ptr{XXH32_state_t}, data::Any)::Cint
   input = Ref(data)
   len = sizeof(data)
   ccall((:XXH32_update, libxxhash), Cuint,
         (Ptr{XXH32_state_t}, Ptr{Cvoid}, Csize_t),
         state, input, len)
end
@inline function XXH32_digest(state::Ptr{XXH32_state_t})::UInt32
   ccall((:XXH32_digest, libxxhash), Cuint,
         (Ptr{XXH32_state_t},), state)
end

@inline function XXH32to_canonical(h::UInt32)::NTuple{4,UInt8}
   c = Ref(NTuple{4,UInt8}((0,0,0,0)))
   ccall((:XXH32_canonicalFromHash, libxxhash), Cvoid,
         (Ptr{NTuple{4,Cuchar}}, Cuint), c, h)
   return c[]
end
@inline function XXH32from_canonical(c::NTuple{4,UInt8})::UInt32
   ccall((:XXH32_hashFromCanonical, libxxhash), Cuint,
         (Ptr{NTuple{4,Cuchar}},), Ref(c))
end
#=
64 bit hash functions
=#
"""
    xxh64(d, seed=0)

Compute a hash of any object `d` using the 64 bit [xxHash](http://cyan4973.github.io/xxHash) algorithm and `seed`.

# Examples
```julia-repl
julia> xxh64("abc")
0x31886f2e7daf8ca4
```
"""
@inline function xxh64(data::Any, seed::Union{Int64,UInt64}=0)::UInt64
   ccall((:XXH64, libxxhash), Culonglong,
   (Ptr{Cvoid}, Csize_t, Culonglong),
   Ref(data), sizeof(data), seed % UInt64)
end

struct XXH64_state_t
   total_len::UInt64
   v1::UInt64
   v2::UInt64
   v3::UInt64
   v4::UInt64
   mem64::NTuple{4,UInt64}
   memsize::UInt32
   reserved::NTuple{2,UInt32} # never read nor write, might be removed in a future version
end

@inline function XXH64_createState()::Ptr{XXH64_state_t}
   ccall((:XXH64_createState, libxxhash), Ptr{XXH64_state_t}, ())
end
@inline function XXH64_freeState(state::Ptr{XXH64_state_t})::Cint
   ccall((:XXH64_freeState, libxxhash), Cint,
      (Ptr{XXH64_state_t},), state)
end
@inline function XXH64_copyState(dst_state::Ptr{XXH64_state_t},
                                 src_state::Ptr{XXH64_state_t})
   ccall((:XXH64_copyState, libxxhash), Cvoid,
      (Ptr{XXH64_state_t}, Ptr{XXH64_state_t}),
      dst_state, src_state)
end
@inline function XXH64_reset(state::Ptr{XXH64_state_t}, seed::Culonglong)::Cint
   ccall((:XXH64_reset, libxxhash), Cuint,
         (Ptr{XXH64_state_t}, Culonglong), state, seed)
end
@inline function XXH64_update(state::Ptr{XXH64_state_t}, data::Any)::Cint
   input = Ref(data)
   len = sizeof(data)
   ccall((:XXH64_update, libxxhash), Cuint,
         (Ptr{XXH64_state_t}, Ptr{Cvoid}, Csize_t),
         state, input, len)
end
@inline function XXH64_digest(state::Ptr{XXH64_state_t})::UInt64
   ccall((:XXH64_digest, libxxhash), Culonglong,
         (Ptr{XXH64_state_t},), state)
end

@inline function XXH64to_canonical(h::UInt64)::NTuple{8,UInt8}
   c = Ref(NTuple{8,UInt8}((0,0,0,0,0,0,0,0)))
   ccall((:XXH64_canonicalFromHash, libxxhash), Cvoid,
         (Ptr{NTuple{8,Cuchar}}, Culonglong), c, h)
   return c[]
end
@inline function XXH64from_canonical(c::NTuple{8,UInt8})::UInt64
   ccall((:XXH64_hashFromCanonical, libxxhash), Culonglong,
         (Ptr{NTuple{8,Cuchar}},), Ref(c))
end
