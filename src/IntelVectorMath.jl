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

for t in (Float32, Float64, ComplexF32, ComplexF64)
    # Unary, real or complex
    def_unary_op(t, t, :acos, :acos!, :Acos)
    def_unary_op(t, t, :asin, :asin!, :Asin)
    def_unary_op(t, t, :acosh, :acosh!, :Acosh)
    def_unary_op(t, t, :asinh, :asinh!, :Asinh)
    def_unary_op(t, t, :sqrt, :sqrt!, :Sqrt)
    def_unary_op(t, t, :exp, :exp!, :Exp)
    def_unary_op(t, t, :log, :log!, :Ln)

    # # Binary, real or complex
    def_binary_op(t, t, :pow, :pow!, :Pow, true)
    def_binary_op(t, t, :divide, :divide!, :Div, true)
end

for t in (Float32, Float64)
    # Unary, real-only
    def_unary_op(t, t, :cbrt, :cbrt!, :Cbrt)
    def_unary_op(t, t, :expm1, :expm1!, :Expm1)
    def_unary_op(t, t, :log1p, :log1p!, :Log1p)
    def_unary_op(t, t, :log2, :log2!, :Log2)
    def_unary_op(t, t, :abs, :abs!, :Abs)
    def_unary_op(t, t, :abs2, :abs2!, :Sqr)
    def_unary_op(t, t, :ceil, :ceil!, :Ceil)
    def_unary_op(t, t, :floor, :floor!, :Floor)
    def_unary_op(t, t, :round, :round!, :Round)
    def_unary_op(t, t, :trunc, :trunc!, :Trunc)

    # Enabled only for Real. MKL guarantees higher accuracy, but at a
    # substantial performance cost.
    def_unary_op(t, t, :atan, :atan!, :Atan)
    def_unary_op(t, t, :cos, :cos!, :Cos)
    def_unary_op(t, t, :sin, :sin!, :Sin)
    def_unary_op(t, t, :tan, :tan!, :Tan)
    def_unary_op(t, t, :atanh, :atanh!, :Atanh)
    def_unary_op(t, t, :cosh, :cosh!, :Cosh)
    def_unary_op(t, t, :sinh, :sinh!, :Sinh)
    def_unary_op(t, t, :tanh, :tanh!, :Tanh)
    def_unary_op(t, t, :log10, :log10!, :Log10)

    # Unary, real-only
    def_unary_op(t, t, :cospi, :cospi!, :Cospi)
    def_unary_op(t, t, :sinpi, :sinpi!, :Sinpi)
    def_unary_op(t, t, :tanpi, :tanpi!, :Tanpi)
    def_unary_op(t, t, :acospi, :acospi!, :Acospi)
    def_unary_op(t, t, :asinpi, :asinpi!, :Asinpi)
    def_unary_op(t, t, :atanpi, :atanpi!, :Atanpi)
    def_unary_op(t, t, :cosd, :cosd!, :Cosd)
    def_unary_op(t, t, :sind, :sind!, :Sind)
    def_unary_op(t, t, :tand, :tand!, :Tand)

    # now in SpecialFunctions (make smart, maybe?)
    def_unary_op(t, t, :erf, :erf!, :Erf)
    def_unary_op(t, t, :erfc, :erfc!, :Erfc)
    def_unary_op(t, t, :erfinv, :erfinv!, :ErfInv)
    def_unary_op(t, t, :erfcinv, :erfcinv!, :ErfcInv)
    def_unary_op(t, t, :lgamma, :lgamma!, :LGamma)
    def_unary_op(t, t, :gamma, :gamma!, :TGamma)
    # Not in Base
    def_unary_op(t, t, :inv_cbrt, :inv_cbrt!, :InvCbrt)
    def_unary_op(t, t, :inv_sqrt, :inv_sqrt!, :InvSqrt)
    def_unary_op(t, t, :pow2o3, :pow2o3!, :Pow2o3)
    def_unary_op(t, t, :pow3o2, :pow3o2!, :Pow3o2)

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

    # # Binary, real-only
    def_binary_op(t, t, :atan, :atan!, :Atan2, false)
    def_binary_op(t, t, :atanpi, :atanpi!, :Atan2pi, false)
    def_binary_op(t, t, :hypot, :hypot!, :Hypot, false)

    # Unary, complex-only
    def_unary_op(Complex{t}, Complex{t}, :conj, :conj!, :Conj)
    def_unary_op(Complex{t}, t, :abs, :abs!, :Abs)
    def_unary_op(Complex{t}, t, :angle, :angle!, :Arg)

    ### cis is special, IntelVectorMath function is based on output
    def_unary_op(t, Complex{t}, :cis, :cis!, :CIS; vmltype = Complex{t})

    # Binary, complex-only. These are more accurate but performance is
    # either equivalent to Base or slower.
    # def_binary_op(Complex{t}, Complex{t}, (:+), :add!, :Add, false)
    # def_binary_op(Complex{t}, Complex{t}, (:.+), :add!, :Add, true)
    # def_binary_op(Complex{t}, Complex{t}, (:.*), :multiply!, :Mul, true)
    # def_binary_op(Complex{t}, Complex{t}, (:-), :subtract!, :Sub, false)
    # def_binary_op(Complex{t}, Complex{t}, (:.-), :subtract!, :Sub, true)
    # def_binary_op(Complex{t}, Complex{t}, :multiply_conj, :multiply_conj!, :Mul, false)
end

export VML_LA, VML_HA, VML_EP, vml_set_accuracy, vml_get_accuracy
export VML_DENORMAL_FAST, VML_DENORMAL_ACCURATE, vml_set_denormalmode, vml_get_denormalmode
export vml_get_max_threads, vml_set_num_threads
export vml_get_cpu_frequency, vml_get_max_cpu_frequency

# do not export, seems to be no-op in 2022
# export VML_FPU_DEFAULT, VML_FPU_FLOAT32, VML_FPU_FLOAT64, VML_FPU_RESTORE, vml_set_fpumode, vml_get_fpumode


end
