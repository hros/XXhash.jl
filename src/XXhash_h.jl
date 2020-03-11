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
"""
    XXH3_64bits(data)
 default 64-bit variant, using default secret and default seed of 0.
 It's the fastest variant
"""
@inline function XXH3_64bits(data::Any)::Culonglong
    ccall((:XXH3_64bits, xxHash_jll.libxxhash), Culonglong,
  (Ptr{Cvoid}, Csize_t),
  Ref(data), sizeof(data))
end
"""
    XXH3_64bits_withSecret(data, secret)
It's possible to provide any blob of bytes as a "secret" to generate the hash.
This makes it more difficult for an external actor to prepare an intentional
collision.
The secret *must* be large enough (>= XXH3_SECRET_SIZE_MIN=136).
It should consist of random bytes.
Avoid trivial sequences, such as repeating sequences and especially '\0',
as this can cancel out itself.
Failure to respect these conditions will result in a poor quality hash.
"""
@inline function XXH3_64bits_withSecret(data::Any, secret::Any)::Culonglong
   ccall((:XXH3_64bits_withSecret, xxHash_jll.libxxhash), Culonglong,
  (Ptr{Cvoid}, Csize_t, Ptr{Cvoid}, Csize_t),
  Ref(data), sizeof(data), Ref(secret), sizeof(secret))
end
"""
    XXH3_64bits_withSeeed(data, seed)
This variant generates a custom secret on the fly based on the default
secret, altered using the `seed` value.
While this operation is decently fast, note that it's not completely free.
Note: seed==0 produces the same results as XXH3_64bits().
"""
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

#= 
@ctypedef XXH128_hash_t @cstruct XXH128_hash_s {
   low64::Culonglong
   high64::Culonglong
} =# 
struct XXH128_hash_t
   low64::Culonglong
   high64::Culonglong
end

@inline u64hl2u128(h::UInt64, l::UInt64)::UInt128 = ((h % UInt128) << 64) | l


@inline function XXH3_128bits(data::Any)::UInt128
    t = ccall((:XXH3_128bits, xxHash_jll.libxxhash), XXH128_hash_t,
  (Ptr{Cvoid}, Csize_t),
  Ref(data), sizeof(data))
  u64hl2u128(t.high64, t.low64)
end
#= 
XXH128_hash_t XXH3_128bits(const void* data, size_t len);
XXH128_hash_t XXH3_128bits_withSeed(const void* data, size_t len, XXH64_hash_t seed);   == XXH128()
XXH128_hash_t XXH3_128bits_withSecret(const void* data, size_t len, const void* secret, size_t secretSize);
const XXH128 = XXH3_128bits_withSeed

XXH_errorcode XXH3_128bits_reset(XXH3_state_t* statePtr);
XXH_errorcode XXH3_128bits_reset_withSeed(XXH3_state_t* statePtr, XXH64_hash_t seed);
XXH_errorcode XXH3_128bits_reset_withSecret(XXH3_state_t* statePtr, const void* secret, size_t secretSize);

XXH_errorcode XXH3_128bits_update (XXH3_state_t* statePtr, const void* input, size_t length);
XXH128_hash_t XXH3_128bits_digest (const XXH3_state_t* statePtr);


/*!
 * XXH128_isEqual():
 * Return: 1 if `h1` and `h2` are equal, 0 if they are not.
 */
int XXH128_isEqual(XXH128_hash_t h1, XXH128_hash_t h2);

/*!
 * XXH128_cmp():
 *
 * This comparator is compatible with stdlib's `qsort()`/`bsearch()`.
 *
 * return: >0 if *h128_1  > *h128_2
 *         <0 if *h128_1  < *h128_2
 *         =0 if *h128_1 == *h128_2
 */
int XXH128_cmp(const void* h128_1, const void* h128_2);


/*******   Canonical representation   *******/
typedef struct { unsigned char digest[16]; } XXH128_canonical_t;
void XXH128_canonicalFromHash(XXH128_canonical_t* dst, XXH128_hash_t hash);
XXH128_hash_t XXH128_hashFromCanonical(const XXH128_canonical_t* src); =#