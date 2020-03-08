# Declarations mirroring the C declarations in xxhash.h
#= 
32 bit hash functions =#
using xxHash_jll
using CBinding

"""
    xxh32(d, seed=0)

Compute a hash of any object `d` using the 32 bit [xxHash](http://cyan4973.github.io/xxHash) algorithm and `seed`.

# Examples
```julia-repl
julia> xxh32("abc")
0xfe8990bc
```
"""
@inline function xxh32(data::Any, seed::Union{Int32,UInt32} = UInt32(0))::UInt32
    ccall((:XXH32, xxHash_jll.libxxhash), Cuint,
      (Ptr{Cvoid}, Csize_t, Cuint),
      Ref(data), sizeof(data), seed % UInt32)
end

@ctypedef XXH32_state_t @cstruct XXH32_state_s {
   total_len_32::Cuint
   large_len::Cuint
   v1::Cuint
   v2::Cuint
   v3::Cuint
   v4::Cuint
   mem32::Cuint[4]
   memsize::Cuint
   reserved::Cuint # never read nor write, might be removed in a future version
}


@inline function XXH32_createState()::Ptr{XXH32_state_t}
    ccall((:XXH32_createState, xxHash_jll.libxxhash), Ptr{XXH32_state_t}, ())
end
@inline function XXH32_freeState(state::Ptr{XXH32_state_t})::Cint
    ccall((:XXH32_freeState, xxHash_jll.libxxhash), Cint,
      (Ptr{XXH32_state_t},), state)
end
@inline function XXH32_copyState(dst_state::Ptr{XXH32_state_t},
                                 src_state::Ptr{XXH32_state_t})
    ccall((:XXH32_copyState, xxHash_jll.libxxhash), Cvoid,
      (Ptr{XXH32_state_t}, Ptr{XXH32_state_t}),
      dst_state, src_state)
end
@inline function XXH32_reset(state::Ptr{XXH32_state_t},  seed::Cuint)::Cint
    ccall((:XXH32_reset, xxHash_jll.libxxhash), Cuint,
         (Ptr{XXH32_state_t}, Cuint), state, seed)
end
@inline function XXH32_update(state::Ptr{XXH32_state_t}, data::Any)::Cint
    input = Ref(data)
    len = sizeof(data)
    ccall((:XXH32_update, xxHash_jll.libxxhash), Cuint,
         (Ptr{XXH32_state_t}, Ptr{Cvoid}, Csize_t),
         state, input, len)
end
@inline function XXH32_digest(state::Ptr{XXH32_state_t})::UInt32
    ccall((:XXH32_digest, xxHash_jll.libxxhash), Cuint,
         (Ptr{XXH32_state_t},), state)
end

@inline function XXH32to_canonical(h::UInt32)::NTuple{4,UInt8}
    c = Ref(NTuple{4,UInt8}((0, 0, 0, 0)))
    ccall((:XXH32_canonicalFromHash, xxHash_jll.libxxhash), Cvoid,
         (Ptr{NTuple{4,Cuchar}}, Cuint), c, h)
    return c[]
end
@inline function XXH32from_canonical(c::NTuple{4,UInt8})::UInt32
    ccall((:XXH32_hashFromCanonical, xxHash_jll.libxxhash), Cuint,
         (Ptr{NTuple{4,Cuchar}},), Ref(c))
end
#= 
64 bit hash functions =#
"""
    xxh64(d, seed=0)

Compute a hash of any object `d` using the 64 bit [xxHash](http://cyan4973.github.io/xxHash) algorithm and `seed`.

# Examples
```julia-repl
julia> xxh64("abc")
0x31886f2e7daf8ca4
```
"""
@inline function xxh64(data::Any, seed::Union{Int64,UInt64} = 0)::UInt64
    ccall((:XXH64, xxHash_jll.libxxhash), Culonglong,
   (Ptr{Cvoid}, Csize_t, Culonglong),
   Ref(data), sizeof(data), seed % UInt64)
end

@ctypedef XXH64_state_t @cstruct XXH64_state_s {
   total_len::Culonglong
   v1::Culonglong
   v2::Culonglong
   v3::Culonglong
   v4::Culonglong
   mem64::Culonglong[4]
   memsize::Cuint
   reserved::Cuint[2] # never read nor write, might be removed in a future version
}

@inline function XXH64_createState()::Ptr{XXH64_state_t}
    ccall((:XXH64_createState, xxHash_jll.libxxhash), Ptr{XXH64_state_t}, ())
end
@inline function XXH64_freeState(state::Ptr{XXH64_state_t})::Cint
    ccall((:XXH64_freeState, xxHash_jll.libxxhash), Cint,
      (Ptr{XXH64_state_t},), state)
end
@inline function XXH64_copyState(dst_state::Ptr{XXH64_state_t},
                                 src_state::Ptr{XXH64_state_t})
    ccall((:XXH64_copyState, xxHash_jll.libxxhash), Cvoid,
      (Ptr{XXH64_state_t}, Ptr{XXH64_state_t}),
      dst_state, src_state)
end
@inline function XXH64_reset(state::Ptr{XXH64_state_t}, seed::Culonglong)::Cint
    ccall((:XXH64_reset, xxHash_jll.libxxhash), Cuint,
         (Ptr{XXH64_state_t}, Culonglong), state, seed)
end
@inline function XXH64_update(state::Ptr{XXH64_state_t}, data::Any)::Cint
    input = Ref(data)
    len = sizeof(data)
    ccall((:XXH64_update, xxHash_jll.libxxhash), Cuint,
         (Ptr{XXH64_state_t}, Ptr{Cvoid}, Csize_t),
         state, input, len)
end
@inline function XXH64_digest(state::Ptr{XXH64_state_t})::UInt64
    ccall((:XXH64_digest, xxHash_jll.libxxhash), Culonglong,
         (Ptr{XXH64_state_t},), state)
end

@inline function XXH64to_canonical(h::UInt64)::NTuple{8,UInt8}
    c = Ref(NTuple{8,UInt8}((0, 0, 0, 0, 0, 0, 0, 0)))
    ccall((:XXH64_canonicalFromHash, xxHash_jll.libxxhash), Cvoid,
         (Ptr{NTuple{8,Cuchar}}, Culonglong), c, h)
    return c[]
end
@inline function XXH64from_canonical(c::NTuple{8,UInt8})::UInt64
    ccall((:XXH64_hashFromCanonical, xxHash_jll.libxxhash), Culonglong,
         (Ptr{NTuple{8,Cuchar}},), Ref(c))
end


#= 
XXH3 hashing algorithms - high speed 64 and 128 bit hash =#
@inline function XXH3_64bits(data::Any)::Culonglong
   ccall((:XXH3_64bits, xxHash_jll.libxxhash), Culonglong,
  (Ptr{Cvoid}, Csize_t),
  Ref(data), sizeof(data))
end
@inline function XXH3_64bits_withSecret(data::Any, secret::Any)::Culonglong
   ccall((:XXH3_64bits_withSecret, xxHash_jll.libxxhash), Culonglong,
  (Ptr{Cvoid}, Csize_t, Ptr{Cvoid}, Csize_t),
  Ref(data), sizeof(data), Ref(secret), sizeof(secret))
end
@inline function XXH3_64bits_withSeeed(data::Any, seed::Culonglong)::Culonglong
   ccall((:XXH3_64bits_withSeeed, xxHash_jll.libxxhash), Culonglong,
  (Ptr{Cvoid}, Csize_t, Culonglong),
  Ref(data), sizeof(data), seed)
end


const XXH3_SECRET_DEFAULT_SIZE = 192   # minimum XXH3_SECRET_SIZE_MIN
const XXH3_INTERNALBUFFER_SIZE = 256
@ctypedef XXH3_state_t @cstruct XXH3_state_s {
   @calign 64
   acc::Culonglong[8]
   @calign 64
   customSecret::Cuchar[XXH3_SECRET_DEFAULT_SIZE]
   @calign 64
   buffer::Cuchar[XXH3_INTERNALBUFFER_SIZE]
   
   bufferedSize::Cuint
   nbStripesPerBlock::Cuint
   nbStripesSoFar::Cuint
   secretLimit::Cuint
   reserved32::Cuint
   reserved32_2::Cuint
   totalLen::Cuint
   seed::Culonglong
   reserved64::Cuint
   # note: there is some padding after due to alignment on 64 bytes */
   secret::Ptr{Cuchar}
}

@inline function XXH3_createState()::Ptr{XXH3_state_t}
    ccall((:XXH3_createState, xxHash_jll.libxxhash), Ptr{XXH3_state_t}, ())
end
@inline function XXH3_freeState(state::Ptr{XXH3_state_t})::Cint
    ccall((:XXH3_freeState, xxHash_jll.libxxhash), Cint,
      (Ptr{XXH3_state_t},), state)
end
@inline function XXH3_copyState(dst_state::Ptr{XXH3_state_t},
                                src_state::Ptr{XXH3_state_t})
    ccall((:XXH3_copyState, xxHash_jll.libxxhash), Cvoid,
      (Ptr{XXH3_state_t}, Ptr{XXH3_state_t}),
      dst_state, src_state)
end
@inline function XXH3_64bits_reset(state::Ptr{XXH3_state_t})::Cint
    ccall((:XXH3_64bits_reset, xxHash_jll.libxxhash), Cuint,
         (Ptr{XXH3_state_t},), state)
end
@inline function XXH3_64bits_reset_withSeed(state::Ptr{XXH3_state_t},  seed::Cuint)::Cint
    ccall((:XXH3_64bits_reset_withSeed, xxHash_jll.libxxhash), Cuint,
        (Ptr{XXH3_state_t}, Cuint), state, seed)
end
@inline function XXH3_64bits_reset_withSecret(state::Ptr{XXH3_state_t},  secret::Any)::Cint
   secret_size = sizeof(secret)
   ccall((:XXH3_64bits_reset_withSecret, xxHash_jll.libxxhash), Cuint,
      (Ptr{XXH3_state_t}, Ptr{Cvoid}, Csize_t), state, Ref(secret), secret_size)
end

@inline function XXH3_64bits_update(state::Ptr{XXH3_state_t}, data::Any)::Cint
    input = Ref(data)
    len = sizeof(data)
    ccall((:XXH3_64bits_update, xxHash_jll.libxxhash), Cuint,
         (Ptr{XXH3_state_t}, Ptr{Cvoid}, Csize_t),
         state, input, len)
end
@inline function XXH3_64bits_digest(state::Ptr{XXH3_state_t})::UInt32
    ccall((:XXH3_digest, xxHash_jll.libxxhash), Cuint,
         (Ptr{XXH3_state_t},), state)
end

@ctypedef XXH128_hash_t @cstruct XXH128_hash_s {
   low64::Culonglong
   high64::Culonglong
}

