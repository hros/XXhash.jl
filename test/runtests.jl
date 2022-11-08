using XXhash, Test

@testset "xxhash" begin
    s32 = XXH32stream()
    s64 = XXH64stream()
    s3_64 = XXH3_64stream()
    s3_128 = XXH3_128stream()
    r128 = rand(UInt128)
    xxhash_update(s32, r128)
    xxhash_update(s64, r128)
    xxhash_update(s3_64, r128)
    xxhash_update(s3_128, r128)
    h32 = xxh32(r128)
    h64 = xxh64(r128)
    h3_64 = xxh3_64(r128)
    h3_128 = xxh3_128(r128)
    @testset "hash random 128 bit number" begin
        @test xxhash_digest(s32) == h32
        @test xxhash_digest(s64) == h64
        @test xxhash_digest(s3_64) == h3_64
        @test xxhash_digest(s3_128) == h3_128
        @test xxhash_fromcanonical(xxhash_tocanonical(h32)) == h32
        @test xxhash_fromcanonical(xxhash_tocanonical(h64)) == h64
        @test xxhash_fromcanonical(xxhash_tocanonical(h3_128)) == h3_128
    end
    v = [rand(UInt8) for _ in 1:100]
    s32 = XXH32stream()
    s64 = XXH64stream()
    s3_64 = XXH3_64stream()
    s3_128 = XXH3_128stream()
    for vi in v
        xxhash_update(s32, vi)
        xxhash_update(s64, vi)
        xxhash_update(s3_64, vi)
        xxhash_update(s3_128, vi)
    end
    @testset "hash a vector of bytes" begin
        @test xxhash_digest(s32) == xxh32(v)
        @test xxhash_digest(s64) == xxh64(v)
        @test xxhash_digest(s3_64) == xxh3_64(v)
        @test xxhash_digest(s3_128) == xxh3_128(v)
    end
end
