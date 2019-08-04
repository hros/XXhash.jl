using XXhash, Test

@testset "xxhash" begin
    s32 = XXH32stream()
    s64 = XXH64stream()
    r128 = rand(UInt128)
    xxhash_update(s32, r128)
    xxhash_update(s64, r128)
    h64 = xxh64(r128)
    h32 = xxh32(r128)
    @test xxhash_digest(s64) == h64
    @test xxhash_digest(s32) == h32
    @test xxhash_fromcanonical(xxhash_tocanonical(h64)) == h64
    @test xxhash_fromcanonical(xxhash_tocanonical(h32)) == h32
end
