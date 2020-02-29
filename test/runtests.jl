# import MKL_jll
using Test
using IntelVectorMath

IntelVectorMath.vml_get_mode()

include("common.jl")
include("real.jl")
include("complex.jl")
