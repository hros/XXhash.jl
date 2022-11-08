module libxxhash

# julia wrappers for C types and functions in xxhash.h

using xxHash_jll
using CBinding


c`-I $(xxHash_jll.artifact_dir)/include -L $(xxHash_jll.artifact_dir)/lib -lxxhash`
const c"int32_t" = Int32
const c"int64_t" = Int64
const c"uint32_t" = UInt32
const c"uint64_t" = UInt64
const c"size_t" = Csize_t

c"""
#include <xxhash.h>
"""j

end