module XXhash
#
export xxh32, XXH32stream, xxh64, XXH64stream,
    xxh3_64, XXH3_64stream, xxh3_128, XXH3_128stream,
    xxhash_update, xxhash_digest,
    xxhash_fromcanonical, xxhash_tocanonical,
    xxh_version

# # Load XXhash libraries from our deps.jl
# const depsjl_path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
# if !isfile(depsjl_path)
#     error("XXhash not installed properly, run Pkg.build(\"XXhash\"), restart Julia and try again")
# end
# include(depsjl_path)

# function __init__()
#     check_deps()
# end

include("XXhash_h.jl")

#= 
32 bit hash functions =#
"""
    xxh32(d, seed=0)

Compute a hash of any object `d` using the 32 bit [xxHash](http://cyan4973.github.io/xxHash) algorithm and `seed`.

# Examples
```julia-repl
julia> xxh32("abc")
0x32d153ff

julia> xxh32([1, 2, 3])
0x2a1c9a49
```
"""
@inline xxh32(data::Union{Array,String}, seed::Union{Int32,UInt32}=UInt32(0))::UInt32 = GC.@preserve data libxxhash.XXH32(pointer(data), sizeof(data), seed % UInt32)
@inline xxh32(data::Any, seed::Union{Int32,UInt32}=UInt32(0))::UInt32 = libxxhash.XXH32(Ref(data), sizeof(data), seed % UInt32)


#= 
64 bit hash functions =#
"""
    xxh64(d, seed=0)

Compute a hash of any object `d` using the 64 bit [xxHash](http://cyan4973.github.io/xxHash) algorithm and `seed`.

# Examples
```julia-repl
julia> xxh64("abc")
0x44bc2cf5ad770999

julia> xxh64([1,2,3])
0x8799e152e5c0cdfa
```
"""
@inline xxh64(data::Union{Array,String}, seed::Union{Int64,UInt64}=0)::UInt64 = GC.@preserve data libxxhash.XXH64(pointer(data), sizeof(data), seed % UInt32)
@inline xxh64(data::Any, seed::Union{Int64,UInt64}=0)::UInt64 = libxxhash.XXH64(Ref(data), sizeof(data), seed % UInt32)



"""
    XXH32stream()

Creates a stream hash object for 32 bit xxhash

See also: [`xxhash_update`](@ref), [`xxhash_digest`](@ref)
"""
mutable struct XXH32stream
    state_ptr::Ptr{libxxhash.XXH32_state_t}
    function XXH32stream(seed::Union{Int32,UInt32}=UInt32(0))
        sp = libxxhash.XXH32_createState()
        stream = new(sp)
        finalizer(x -> libxxhash.XXH32_freeState(x.state_ptr), stream)
        libxxhash.XXH32_reset(stream.state_ptr, seed % UInt32)
        return stream
    end
end
"""
    xxhash_update(xxhash_stream, data)

updates hash of stream of data. Non zero return values indicate an error

See also: [`xxhash_digest`](@ref), [`XXH32stream`](@ref), [`XXH64stream`](@ref), [`XXH3_64stream`](@ref), [`XXH3_128stream`](@ref)
"""
@inline xxhash_update(stream::XXH32stream, data::Any)::Cint =
    libxxhash.libxxhash.XXH32_update(stream.state_ptr, Ref(data), sizeof(data))

@inline xxhash_update(stream::XXH32stream, data::Union{Array,String})::Cint =
    GC.@preserve data libxxhash.libxxhash.XXH32_update(stream.state_ptr, pointer(data), sizeof(data))

"""
    xxhash_digest(xxhash_stream)

returns the current hash of the data stream

See also: [`xxhash_update`](@ref), [`XXH32stream`](@ref), [`XXH64stream`](@ref)
"""
@inline xxhash_digest(stream::XXH32stream)::UInt32 =
    libxxhash.XXH32_digest(stream.state_ptr)

"""
    xxhash_tocanonical(hash)

returns a tuple of bytes in big endian for platform independent serialization
See also: [`xxhash_fromcanonical`](@ref)
"""
@inline function xxhash_tocanonical(h::UInt32)
    c = Libc.malloc(libxxhash.XXH32_canonical_t)
    libxxhash.XXH32_canonicalFromHash(c, h)
    res = Tuple(c.digest[])
    Libc.free(c)
    return res
end
"""
    xxhash_fromcanonical(hash)

returns a hash by deserializing a tuple of bytes in big endian
See also: [`xxhash_tocanonical`](@ref)
"""
@inline function xxhash_fromcanonical(v::NTuple{4,UInt8})
    c = Libc.malloc(libxxhash.XXH32_canonical_t)
    c.digest = v
    h = libxxhash.XXH32_hashFromCanonical(c)
    Libc.free(c)
    return h
end

"""
    XXH64stream()

Creates a stream hash object for 64 bit xxhash

See also: [`xxhash_update`](@ref), [`xxhash_digest`](@ref)
"""
mutable struct XXH64stream
    state_ptr::Ptr{libxxhash.XXH64_state_t}
    function XXH64stream(seed::Union{UInt64,Int64}=UInt64(0))
        sp = libxxhash.XXH64_createState()
        stream = new(sp)
        finalizer(x -> libxxhash.XXH64_freeState(x.state_ptr), stream)
        libxxhash.XXH64_reset(stream.state_ptr, seed % UInt64)
        return stream
    end
end
@inline xxhash_update(stream::XXH64stream, data::Any)::Cint =
    libxxhash.XXH64_update(stream.state_ptr, Ref(data), sizeof(data))

@inline xxhash_update(stream::XXH64stream, data::Union{Array,String})::Cint =
    GC.@preserve data libxxhash.XXH64_update(stream.state_ptr, pointer(data), sizeof(data))

@inline xxhash_digest(stream::XXH64stream)::UInt64 =
    libxxhash.XXH64_digest(stream.state_ptr)

@inline function xxhash_tocanonical(h::UInt64)
    c = Libc.malloc(libxxhash.XXH64_canonical_t)
    libxxhash.XXH64_canonicalFromHash(c, h)
    res = Tuple(c.digest[])
    Libc.free(c)
    return res
end
@inline function xxhash_fromcanonical(v::NTuple{8,UInt8})
    c = Libc.malloc(libxxhash.XXH64_canonical_t)
    c.digest = v
    h = libxxhash.XXH64_hashFromCanonical(c)
    Libc.free(c)
    return h
end

#=
 XXH3 is a more recent hash algorithm featuring:
  - Improved speed for both small and large inputs
  - True 64-bit and 128-bit outputs
  - SIMD acceleration
  - Improved 32-bit viability

  Speed analysis methodology is explained here:

    https://fastcompression.blogspot.com/2019/03/presenting-xxh3.html

 Compared to XXH64, expect XXH3 to run approximately
 ~2x faster on large inputs and >3x faster on small ones,
 exact differences vary depending on platform.

 XXH3's speed benefits greatly from SIMD and 64-bit arithmetic,
 but does not require it.
 Most 32-bit and 64-bit targets that can run XXH32 smoothly can run XXH3
 at competitive speeds, even without vector support. Further details are
 explained in the implementation.
 =#


"""
xxh3_64(data)

Compute a hash of any object `d` using the 64 bit [xxHash](http://cyan4973.github.io/xxHash) XXH3 algorithm and `seed`.

`XXH3` is a more recent hash algorithm offering 2 variants, _64bits and _128bits.
This function returns the 64 bit variant, which is considerably faster than `xxh64`.
Hashes can be ~2x as fast for large inputs and >3x faster for small ones.

The function has 3 methods:
   - `xxh3_64(data, seed)` returns a 64 bit hash of `data` with `seed` as the seed. Generates a custom secret on the fly based on default secret altered using the `seed` value
   - `xxh3_64(data)`  equivalent to `xxh3_64(data, seed=0)`, however it may have slightly better performance due to constant propagation of the defaults
   - `xxh3_64(data, secret)` returns a 64 bit hash of `data` with `secret` as the secret. `secret` is an array of random bytes at least 136 long. High entropy secrets can be generated with [`XXH3_generateSecret`](@ref)
   
   See also: [`xxh3_128`](@ref)
   

# Examples
```julia-repl
julia> xxh3_64("abc")
0x78af5f94892f3950

julia> xxh3_64("abc", UInt64(0))
0x78af5f94892f3950

julia> xxh3_64(collect(100:200))
0xff8cb2af8e253283
```
"""
@inline xxh3_64(data::Union{Array,String})::UInt64 = GC.@preserve data libxxhash.XXH3_64bits(pointer(data), sizeof(data))
@inline xxh3_64(data::Any)::UInt64 = libxxhash.XXH3_64bits(Ref(data), sizeof(data))

@inline xxh3_64(data::Union{Array,String}, seed::libxxhash.XXH64_hash_t)::UInt64 = GC.@preserve data libxxhash.XXH3_64bits_withSeed(pointer(data), sizeof(data), seed)
@inline xxh3_64(data::Any, seed::libxxhash.XXH64_hash_t)::UInt64 = libxxhash.XXH3_64bits_withSeed(Ref(data), sizeof(data), seed)

@inline xxh3_64(data::Union{Array,String}, secret::Array)::UInt64 = GC.@preserve data libxxhash.XXH3_64bits_withSecret(pointer(data), sizeof(data), secret, sizeof(secret))
@inline xxh3_64(data::Any, secret::Array)::UInt64 = libxxhash.XXH3_64bits_withSecret(Ref(data), sizeof(data), secret, sizeof(secret))




@inline XXH128_hash_to_U128(w::libxxhash.XXH128_hash_t) = ((w.high64 % UInt128) << 64) | w.low64

"""
xxh3_128(data)

Compute a hash of any object `d` using the 128 bit [xxHash](http://cyan4973.github.io/xxHash) XXH3 algorithm and `seed`.

`XXH3` is a more recent hash algorithm offering 2 variants, _64bits and _128bits.
This function returns the 64 bit variant, which is considerably faster than `xxh64`.
Hashes can be ~2x as fast for large inputs and >3x faster for small ones.

The function has 3 methods:
   - `xxh3_128(data, seed)` returns a 128 bit hash of `data` with `seed` as the seed. Generates a custom secret on the fly based on default secret altered using the `seed` value
   - `xxh3_128(data)`  equivalent to `xxh3_128(data, seed=0)`, however it may have slightly better performance due to constant propagation of the defaults
   - `xxh3_128(data, secret)` returns a 128 bit hash of `data` with `secret` as the secret. `secret` is an array of random bytes at least 136 long. High entropy secrets can be generated with [`XXH3_generateSecret`](@ref)
   
   See also: [`xxh3_64`](@ref)
   

# Examples
```julia-repl
julia> xxh3_128("abc")
0x06b05ab6733a618578af5f94892f3950

julia> xxh3_128("abc", UInt64(0))
0x06b05ab6733a618578af5f94892f3950

julia> xxh3_128(collect(100:200))
0xc1d19d1716502f1cff8cb2af8e253283
```
"""
@inline xxh3_128(data::Union{Array,String})::UInt128 = GC.@preserve data XXH128_hash_to_U128(libxxhash.XXH3_128bits(pointer(data), sizeof(data)))
@inline xxh3_128(data::Any)::UInt128 = XXH128_hash_to_U128(libxxhash.XXH3_128bits(Ref(data), sizeof(data)))

@inline xxh3_128(data::Union{Array,String}, seed::libxxhash.XXH64_hash_t)::UInt128 = GC.@preserve data XXH128_hash_to_U128(libxxhash.XXH3_128bits_withSeed(pointer(data), sizeof(data), seed))
@inline xxh3_128(data::Any, seed::libxxhash.XXH64_hash_t)::UInt128 = XXH128_hash_to_U128(libxxhash.XXH3_128bits_withSeed(Ref(data), sizeof(data), seed))

@inline xxh3_128(data::Union{Array,String}, secret::Array)::UInt128 = GC.@preserve data XXH128_hash_to_U128(libxxhash.XXH3_128bits_withSecret(pointer(data), sizeof(data), secret, sizeof(secret)))
@inline xxh3_128(data::Any, secret::Array)::UInt64 = XXH128_hash_to_U128(libxxhash.XXH3_128bits_withSecret(Ref(data), sizeof(data), secret, sizeof(secret)))


#= 
XXH3 - 64 bit hash functions =#

"""
 XXH3_64stream

Creates a stream hash object for 64 bit xxhash using XXH3 algorithm.
The constructor can take either an optional seed or secret arguments, see [`xxh3_64`](@ref) for details.

See also: [`xxhash_update`](@ref), [`xxhash_digest`](@ref)
"""
mutable struct XXH3_64stream
    state_ptr::Ptr{libxxhash.XXH3_state_t}
    function XXH3_64stream(seed::Union{Int64,UInt64}=UInt64(0))
        sp = libxxhash.XXH3_createState()
        stream = new(sp)
        finalizer(x -> libxxhash.XXH3_freeState(x.state_ptr), stream)
        libxxhash.XXH3_64bits_reset_withSeed(stream.state_ptr, seed % UInt64)
        return stream
    end
    function XXH3_64stream(secret::Array)
        sp = libxxhash.XXH3_createState()
        stream = new(sp)
        finalizer(x -> libxxhash.XXH3_freeState(x.state_ptr), stream)
        libxxhash.XXH3_64bits_reset_withSecret(stream.state_ptr, secret, sizeof(secret))
        return stream
    end
end

@inline xxhash_update(stream::XXH3_64stream, data::Any)::Cint =
    libxxhash.XXH3_64bits_update(stream.state_ptr, Ref(data), sizeof(data))
@inline xxhash_update(stream::XXH3_64stream, data::Union{Array,String})::Cint =
    GC.@preserve data libxxhash.XXH3_64bits_update(stream.state_ptr, pointer(data), sizeof(data))

@inline xxhash_digest(stream::XXH3_64stream)::UInt64 =
    libxxhash.XXH3_64bits_digest(stream.state_ptr)


#= 
XXH3 - 128 bit hash functions =#

"""
 XXH3_128stream

Creates a stream hash object for 128 bit xxhash using XXH3 algorithm.
The constructor can take either an optional seed or secret arguments, see [`xxh3_128`](@ref) for details.

See also: [`xxhash_update`](@ref), [`xxhash_digest`](@ref)
"""
mutable struct XXH3_128stream
    state_ptr::Ptr{libxxhash.XXH3_state_t}
    function XXH3_128stream(seed::Union{Int64,UInt64}=UInt64(0))
        sp = libxxhash.XXH3_createState()
        stream = new(sp)
        finalizer(x -> libxxhash.XXH3_freeState(x.state_ptr), stream)
        libxxhash.XXH3_128bits_reset_withSeed(stream.state_ptr, seed % UInt64)
        return stream
    end
    function XXH3_128stream(secret::Array)
        sp = libxxhash.XXH3_createState()
        stream = new(sp)
        finalizer(x -> libxxhash.XXH3_freeState(x.state_ptr), stream)
        libxxhash.XXH3_128bits_reset_withSecret(stream.state_ptr, secret, sizeof(secret))
        return stream
    end
end

@inline xxhash_update(stream::XXH3_128stream, data::Any)::Cint =
    libxxhash.XXH3_128bits_update(stream.state_ptr, Ref(data), sizeof(data))
@inline xxhash_update(stream::XXH3_128stream, data::Union{Array,String})::Cint =
    GC.@preserve data libxxhash.XXH3_128bits_update(stream.state_ptr, pointer(data), sizeof(data))

@inline xxhash_digest(stream::XXH3_128stream)::UInt128 =
    XXH128_hash_to_U128(libxxhash.XXH3_128bits_digest(stream.state_ptr))


@inline function xxhash_tocanonical(h::UInt128)
    c = Libc.malloc(libxxhash.XXH128_canonical_t)
    ht = Libc.malloc(libxxhash.XXH128_hash_t)
    ht.high64[] = (h >> 64) % UInt64
    ht.low64[] = h % UInt64
    libxxhash.XXH128_canonicalFromHash(c, ht[])
    res = Tuple(c.digest[])
    Libc.free(ht)
    Libc.free(c)
    return res
end

@inline function xxhash_fromcanonical(v::NTuple{16,UInt8})::UInt128
    c = Libc.malloc(libxxhash.XXH128_canonical_t)
    c.digest = v
    h = libxxhash.XXH128_hashFromCanonical(c)
    Libc.free(c)
    return XXH128_hash_to_U128(h)
end


"""
    xxh_version
Version number, encoded as two digits each: `MMmmrr`, where `MM` is the major version, `mm` is the minor version, and `rr` is the release number.
"""
xxh_version() = libxxhash.XXH_versionNumber() % Int32

# XXH3_generateSecret(void* secretBuffer, size_t secretSize, const void* customSeed, size_t customSeedSize)
#=
@inline function xxh3_generate_secret(secret_size, seed::Union{Array, Tuple})
    secretptr = Libc.malloc(secret_size)
    libxxhash.XXH3_generateSecret(secretptr, secret_size, seed, sizeof(seed))
    secret = copy(reinterpret(UInt8, secretptr, secret_size))
    Libc.free(secretptr)
    return Tuple(secret[])
end
=#




#=
/*!
 * XXH3_generateSecret():
 *
 * Derive a high-entropy secret from any user-defined content, named customSeed.
 * The generated secret can be used in combination with `*_withSecret()` functions.
 * The `_withSecret()` variants are useful to provide a higher level of protection
 * than 64-bit seed, as it becomes much more difficult for an external actor to
 * guess how to impact the calculation logic.
 *
 * The function accepts as input a custom seed of any length and any content,
 * and derives from it a high-entropy secret of length @p secretSize into an
 * already allocated buffer @p secretBuffer.
 *
 * The generated secret can then be used with any `*_withSecret()` variant.
 * The functions @ref XXH3_128bits_withSecret(), @ref XXH3_64bits_withSecret(),
 * @ref XXH3_128bits_reset_withSecret() and @ref XXH3_64bits_reset_withSecret()
 * are part of this list. They all accept a `secret` parameter
 * which must be large enough for implementation reasons (>= @ref XXH3_SECRET_SIZE_MIN)
 * _and_ feature very high entropy (consist of random-looking bytes).
 * These conditions can be a high bar to meet, so @ref XXH3_generateSecret() can
 * be employed to ensure proper quality.
 *
 * @p customSeed can be anything. It can have any size, even small ones,
 * and its content can be anything, even "poor entropy" sources such as a bunch
 * of zeroes. The resulting `secret` will nonetheless provide all required qualities.
 *
 * @pre
 *   - @p secretSize must be >= @ref XXH3_SECRET_SIZE_MIN
 *   - When @p customSeedSize > 0, supplying NULL as customSeed is undefined behavior.
 *
 * Example code:
 * @code{.c}
 *    #include <stdio.h>
 *    #include <stdlib.h>
 *    #include <string.h>
 *    #define XXH_STATIC_LINKING_ONLY // expose unstable API
 *    #include "xxhash.h"
 *    // Hashes argv[2] using the entropy from argv[1].
 *    int main(int argc, char* argv[])
 *    {
 *        char secret[XXH3_SECRET_SIZE_MIN];
 *        if (argv != 3) { return 1; }
 *        XXH3_generateSecret(secret, sizeof(secret), argv[1], strlen(argv[1]));
 *        XXH64_hash_t h = XXH3_64bits_withSecret(
 *             argv[2], strlen(argv[2]),
 *             secret, sizeof(secret)
 *        );
 *        printf("%016llx\n", (unsigned long long) h);
 *    }
 * @endcode
 */
XXH_PUBLIC_API XXH_errorcode XXH3_generateSecret(void* secretBuffer, size_t secretSize, const void* customSeed, size_t customSeedSize);

/*!
 * @brief Generate the same secret as the _withSeed() variants.
 *
 * The generated secret can be used in combination with
 *`*_withSecret()` and `_withSecretandSeed()` variants.
 *
 * Example C++ `std::string` hash class:
 * @code{.cpp}
 *    #include <string>
 *    #define XXH_STATIC_LINKING_ONLY // expose unstable API
 *    #include "xxhash.h"
 *    // Slow, seeds each time
 *    class HashSlow {
 *        XXH64_hash_t seed;
 *    public:
 *        HashSlow(XXH64_hash_t s) : seed{s} {}
 *        size_t operator()(const std::string& x) const {
 *            return size_t{XXH3_64bits_withSeed(x.c_str(), x.length(), seed)};
 *        }
 *    };
 *    // Fast, caches the seeded secret for future uses.
 *    class HashFast {
 *        unsigned char secret[XXH3_SECRET_SIZE_MIN];
 *    public:
 *        HashFast(XXH64_hash_t s) {
 *            XXH3_generateSecret_fromSeed(secret, seed);
 *        }
 *        size_t operator()(const std::string& x) const {
 *            return size_t{
 *                XXH3_64bits_withSecret(x.c_str(), x.length(), secret, sizeof(secret))
 *            };
 *        }
 *    };
 * @endcode
 * @param secretBuffer A writable buffer of @ref XXH3_SECRET_SIZE_MIN bytes
 * @param seed The seed to seed the state.
 */
XXH_PUBLIC_API void XXH3_generateSecret_fromSeed(void* secretBuffer, XXH64_hash_t seed);

=#

end