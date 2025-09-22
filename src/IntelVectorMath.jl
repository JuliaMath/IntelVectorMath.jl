__precompile__()

module IntelVectorMath

export IVM
const IVM = IntelVectorMath

# import Base: .^, ./
include("setup.jl")

function __init__()
    compilersupportlibaries_jll_uuid = Base.UUID("e66e0078-7015-5450-92f7-15fbd957f2ae")
    if Sys.isapple() && haskey(Base.loaded_modules, Base.PkgId(compilersupportlibaries_jll_uuid, "CompilerSupportLibraries_jll"))
        @warn "It appears CompilerSupportLibraries_jll was loaded prior to this package, which currently on mac may lead to wrong results in some cases. For further details see github.com/JuliaMath/IntelVectorMath.jl"
    end
end

include("function_list.jl")

## define functions from previous list for all eligible input types

for t in (Float32, Float64, ComplexF32, ComplexF64)
    # Unary, real or complex
    for (f, f!, f_mkl) in unary_real_complex
        def_unary_op(t, t, f, f!, f_mkl)
    end

    # # Binary, real or complex
    for (f, f!, f_mkl, broadcast) in binary_real_complex
        def_binary_op(t, t, f, f!, f_mkl, broadcast)
    end
end

for t in (Float32, Float64)
    # Unary, real only
    for (f, f!, f_mkl) in unary_real
        def_unary_op(t, t, f, f!, f_mkl)
    end

    for (f, f!, f_mkl, broadcast) in binary_real
        def_binary_op(t, t, f, f!, f_mkl, broadcast)
    end

    # Unary, complex-only
    for (f, f!, f_mkl) in unary_complex_inout
        def_unary_op(Complex{t}, Complex{t}, f, f!, f_mkl)
    end
    for (f, f!, f_mkl) in unary_complex_in
        def_unary_op(Complex{t}, t, f, f!, f_mkl)
    end

    ### cis is special, IntelVectorMath function is based on output
    def_unary_op(t, Complex{t}, :cis, :cis!, :CIS; vmltype=Complex{t})

    def_one2two_op(t, t, :sincos, :sincos!, :SinCos)

    # Binary, complex-only. These are more accurate but performance is
    # either equivalent to Base or slower.
    # def_binary_op(Complex{t}, Complex{t}, (:+), :add!, :Add, false)
    # def_binary_op(Complex{t}, Complex{t}, (:.+), :add!, :Add, true)
    # def_binary_op(Complex{t}, Complex{t}, (:.*), :multiply!, :Mul, true)
    # def_binary_op(Complex{t}, Complex{t}, (:-), :subtract!, :Sub, false)
    # def_binary_op(Complex{t}, Complex{t}, (:.-), :subtract!, :Sub, true)
    # def_binary_op(Complex{t}, Complex{t}, :multiply_conj, :multiply_conj!, :Mul, false)

    # # .^ to scalar power
    # mklfn = Base.Meta.quot(Symbol("$(vml_prefix(t))Powx"))
    # @eval begin
    #     export pow!
    #     function pow!{N}(out::Array{$t,N}, A::Array{$t,N}, b::$t)
    #         size(out) == size(A) || throw(DimensionMismatch())
    #         ccall(($mklfn, lib), Nothing, (Int, Ptr{$t}, $t, Ptr{$t}), length(A), A, b, out)
    #         vml_check_error()
    #         out
    #     end
    #     function (.^){N}(A::Array{$t,N}, b::$t)
    #         out = similar(A)
    #         ccall(($mklfn, lib), Nothing, (Int, Ptr{$t}, $t, Ptr{$t}), length(A), A, b, out)
    #         vml_check_error()
    #         out
    #     end
    # end
end

export VML_LA, VML_HA, VML_EP, vml_set_accuracy, vml_get_accuracy
export VML_DENORMAL_FAST, VML_DENORMAL_ACCURATE, vml_set_denormalmode, vml_get_denormalmode
export vml_get_max_threads, vml_set_num_threads
export vml_get_cpu_frequency, vml_get_max_cpu_frequency

# do not export, seems to be no-op in 2022
# export VML_FPU_DEFAULT, VML_FPU_FLOAT32, VML_FPU_FLOAT64, VML_FPU_RESTORE, vml_set_fpumode, vml_get_fpumode


end
