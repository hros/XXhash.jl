module XXhash
#
export xxh32, XXH32stream, xxh64, XXH64stream,
       xxhash_update, xxhash_digest,
       xxhash_fromcanonical, xxhash_tocanonical
# Load XXhash libraries from our deps.jl
const depsjl_path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("XXhash not installed properly, run Pkg.build(\"XXhash\"), restart Julia and try again")
end
include(depsjl_path)

function __init__()
    check_deps()
end

include("XXhash_h.jl")
"""
    XXH32stream()

Creates a stream hash object for 32 bit xxhash

See also: [`xxhash_update`](@ref), [`xxhash_digest`](@ref)
"""
mutable struct XXH32stream
   state_ptr::Ptr{XXH32_state_t}
   function XXH32stream(seed::Union{Int32,UInt32} = UInt32(0))
      sp = XXH32_createState()
      stream = new(sp)
      finalizer(x->XXH32_freeState(x.state_ptr), stream)
      XXH32_reset(stream.state_ptr, seed % UInt32)
      return stream
   end
end
"""
    xxhash_update(xxhash_stream, data)

updates hash of stream of data. Non zero return values indicate an error

See also: [`xxhash_digest`](@ref), [`XXH32stream`](@ref), [`XXH64stream`](@ref)
"""
@inline xxhash_update(stream::XXH32stream, data::Any)::Cint =
   XXH32_update(stream.state_ptr, data)

"""
    xxhash_digest(xxhash_stream)

returns the current hash of the data stream

See also: [`xxhash_update`](@ref), [`XXH32stream`](@ref), [`XXH64stream`](@ref)
"""
@inline xxhash_digest(stream::XXH32stream)::UInt32 =
   XXH32_digest(stream.state_ptr)

"""
    xxhash_tocanonical(hash)

returns a tuple of bytes in big endian for platform independent serialization
See also: [`xxhash_fromcanonical`](@ref)
"""
@inline xxhash_tocanonical(h::UInt32) = XXH32to_canonical(h)
"""
    xxhash_fromcanonical(hash)

returns a hash by deserializing a tuple of bytes in big endian
See also: [`xxhash_tocanonical`](@ref)
"""
@inline xxhash_fromcanonical(c::NTuple{4,UInt8}) = XXH32from_canonical(c)

"""
    XXH64stream()

Creates a stream hash object for 64 bit xxhash

See also: [`xxhash_update`](@ref), [`xxhash_digest`](@ref)
"""
mutable struct XXH64stream
   state_ptr::Ptr{XXH64_state_t}
   function XXH64stream(seed::Union{UInt64,Int64} = UInt64(0))
      sp = XXH64_createState()
      stream = new(sp)
      finalizer(x->XXH64_freeState(x.state_ptr), stream)
      XXH64_reset(stream.state_ptr, seed % UInt64)
      return stream
   end
end
@inline xxhash_update(stream::XXH64stream, data::Any)::Cint =
   XXH64_update(stream.state_ptr, data)

@inline xxhash_digest(stream::XXH64stream)::UInt64 =
   XXH64_digest(stream.state_ptr)

@inline xxhash_tocanonical(h::UInt64) = XXH64to_canonical(h)
@inline xxhash_fromcanonical(c::NTuple{8,UInt8}) = XXH64from_canonical(c)

end
