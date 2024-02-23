import Pkg
using Pkg

if Sys.isapple() && Sys.ARCH == :x86_64
    Pkg.add(name="MKL_jll", version="2023");
    Pkg.pin(name="MKL_jll", version="2023");
end

import MKL_jll
if !MKL_jll.is_available()
    @warn "MKL is not available/installed. Exiting."
    exit()
end

using Test
using IntelVectorMath
using SpecialFunctions

include("nonbase-functions.jl")
include("common.jl")
include("real.jl")
include("complex.jl")
