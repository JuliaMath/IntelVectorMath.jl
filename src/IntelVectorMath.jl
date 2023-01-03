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

## list all functions
# all functions that work for Floats and ComplexFloats
unary_real_complex = (
    (:acos, :acos!, :Acos),
    (:asin, :asin!, :Asin),
    (:acosh, :acosh!, :Acosh),
    (:asinh, :asinh!, :Asinh),
    (:sqrt, :sqrt!, :Sqrt),
    (:exp, :exp!, :Exp),
    (:log, :log!, :Ln),
)

binary_real_complex = (
    (:pow, :pow!, :Pow, true),
    (:divide, :divide!, :Div, true),
)

# all functions that work for Floats only
unary_real = (
    (:cbrt, :cbrt!, :Cbrt),
    (:expm1, :expm1!, :Expm1),
    (:log1p, :log1p!, :Log1p),
    (:log2, :log2!, :Log2),
    (:abs, :abs!, :Abs),
    (:abs2, :abs2!, :Sqr),
    (:ceil, :ceil!, :Ceil),
    (:floor, :floor!, :Floor),
    (:round, :round!, :Round),
    (:trunc, :trunc!, :Trunc),
    (:cospi, :cospi!, :Cospi),
    (:sinpi, :sinpi!, :Sinpi),
    (:tanpi, :tanpi!, :Tanpi),
    (:acospi, :acospi!, :Acospi),
    (:asinpi, :asinpi!, :Asinpi),
    (:atanpi, :atanpi!, :Atanpi),
    (:cosd, :cosd!, :Cosd),
    (:sind, :sind!, :Sind),
    (:tand, :tand!, :Tand),
    # Enabled only for Real. MKL guarantees higher accuracy, but at a
    # substantial performance cost.
    (:atan, :atan!, :Atan),
    (:cos, :cos!, :Cos),
    (:sin, :sin!, :Sin),
    (:tan, :tan!, :Tan),
    (:atanh, :atanh!, :Atanh),
    (:cosh, :cosh!, :Cosh),
    (:sinh, :sinh!, :Sinh),
    (:tanh, :tanh!, :Tanh),
    (:log10, :log10!, :Log10),
    # now in SpecialFunctions (make smart, maybe?)
    (:erf, :erf!, :Erf),
    (:erfc, :erfc!, :Erfc),
    (:erfinv, :erfinv!, :ErfInv),
    (:erfcinv, :erfcinv!, :ErfcInv),
    (:lgamma, :lgamma!, :LGamma),
    (:gamma, :gamma!, :TGamma),
    # Not in Base
    (:inv_cbrt, :inv_cbrt!, :InvCbrt),
    (:inv_sqrt, :inv_sqrt!, :InvSqrt),
    (:pow2o3, :pow2o3!, :Pow2o3),
    (:pow3o2, :pow3o2!, :Pow3o2),
)

binary_real = (
    (:atan, :atan!, :Atan2, false),
    (:atanpi, :atanpi!, :Atan2pi, false),
    (:hypot, :hypot!, :Hypot, false),
)

unary_complex_in = (
    (:abs, :abs!, :Abs),
    (:angle, :angle!, :Arg),
)

unary_complex_inout = (
    (:conj, :conj!, :Conj),
)

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

    def_one2two_op(t, t, :sincos, :sincos!, :SinCos)

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
