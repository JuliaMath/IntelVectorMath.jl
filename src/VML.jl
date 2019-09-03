__precompile__()

module VML

# import Base: .^, ./
using SpecialFunctions
using Libdl
# TODO detect CPU architecture
# include("libdetect.jl")
include(joinpath(dirname(@__DIR__), "deps/deps.jl"))

include("setup.jl")

for t in (Float32, Float64, ComplexF32, ComplexF64)
    # Unary, real or complex
    def_unary_op(t, t, :(Base.acos), :acos!, :Acos)
    def_unary_op(t, t, :(Base.asin), :asin!, :Asin)
    def_unary_op(t, t, :(Base.acosh), :acosh!, :Acosh)
    def_unary_op(t, t, :(Base.asinh), :asinh!, :Asinh)
    def_unary_op(t, t, :(Base.sqrt), :sqrt!, :Sqrt)
    def_unary_op(t, t, :(Base.exp), :exp!, :Exp)
    def_unary_op(t, t, :(Base.log), :log!, :Ln)

    # # Binary, real or complex
    def_binary_op(t, t, :pow, :pow!, :Pow, true)
    def_binary_op(t, t, :divide, :divide!, :Div, true)
end

for t in (Float32, Float64)
    # Unary, real-only
    def_unary_op(t, t, :(Base.cbrt), :cbrt!, :Cbrt)
    def_unary_op(t, t, :(Base.expm1), :expm1!, :Expm1)
    def_unary_op(t, t, :(Base.log1p), :log1p, :Log1p)
    def_unary_op(t, t, :(Base.abs), :abs!, :Abs)
    def_unary_op(t, t, :(Base.abs2), :abs2!, :Sqr)
    def_unary_op(t, t, :(Base.ceil), :ceil!, :Ceil)
    def_unary_op(t, t, :(Base.floor), :floor!, :Floor)
    def_unary_op(t, t, :(Base.round), :round!, :Round)
    def_unary_op(t, t, :(Base.trunc), :trunc!, :Trunc)

    # now in SpecialFunctions (make smart, maybe?)
    def_unary_op(t, t, :(SpecialFunctions.erf), :erf!, :Erf)
    def_unary_op(t, t, :(SpecialFunctions.erfc), :erfc!, :Erfc)
    def_unary_op(t, t, :(SpecialFunctions.erfinv), :erfinv!, :ErfInv)
    def_unary_op(t, t, :(SpecialFunctions.erfcinv), :erfcinv!, :ErfcInv)
    def_unary_op(t, t, :(SpecialFunctions.lgamma), :lgamma!, :LGamma)
    def_unary_op(t, t, :(SpecialFunctions.gamma), :gamma!, :TGamma)
    # Not in Base
    def_unary_op(t, t, :inv_cbrt, :inv_cbrt!, :InvCbrt)
    def_unary_op(t, t, :inv_sqrt, :inv_sqrt!, :InvSqrt)
    def_unary_op(t, t, :pow2o3, :pow2o3!, :Pow2o3)
    def_unary_op(t, t, :pow3o2, :pow3o2!, :Pow3o2)

    # Enabled only for Real. MKL guarantees higher accuracy, but at a
    # substantial performance cost.
    def_unary_op(t, t, :(Base.atan), :atan!, :Atan)
    def_unary_op(t, t, :(Base.cos), :cos!, :Cos)
    def_unary_op(t, t, :(Base.sin), :sin!, :Sin)
    def_unary_op(t, t, :(Base.tan), :tan!, :Tan)
    def_unary_op(t, t, :(Base.atanh), :atanh!, :Atanh)
    def_unary_op(t, t, :(Base.cosh), :cosh!, :Cosh)
    def_unary_op(t, t, :(Base.sinh), :sinh!, :Sinh)
    def_unary_op(t, t, :(Base.tanh), :tanh!, :Tanh)
    def_unary_op(t, t, :(Base.log10), :log10!, :Log10)

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
    def_binary_op(t, t, :(Base.atan), :atan!, :Atan, false)
    def_binary_op(t, t, :(Base.hypot), :hypot!, :Hypot, false)

    # Unary, complex-only
    def_unary_op(t, Complex{t}, :(Base.cis), :cis!, :CIS)
    def_unary_op(Complex{t}, Complex{t}, :(Base.conj), :conj!, :Conj)
    def_unary_op(Complex{t}, t, :(Base.abs), :abs!, :Abs)
    def_unary_op(Complex{t}, t, :(Base.angle), :angle!, :Arg)

    # Binary, complex-only. These are more accurate but performance is
    # either equivalent to Base or slower.
    # def_binary_op(Complex{t}, Complex{t}, :(Base.(:+)), :add!, :Add, false)
    # def_binary_op(Complex{t}, Complex{t}, :(Base.(:.+)), :add!, :Add, true)
    # def_binary_op(Complex{t}, Complex{t}, :(Base.(:.*)), :multiply!, :Mul, true)
    # def_binary_op(Complex{t}, Complex{t}, :(Base.(:-)), :subtract!, :Sub, false)
    # def_binary_op(Complex{t}, Complex{t}, :(Base.(:.-)), :subtract!, :Sub, true)
    # def_binary_op(Complex{t}, Complex{t}, :multiply_conj, :multiply_conj!, :Mul, false)
end

export VML_LA, VML_HA, VML_EP, vml_set_accuracy, vml_get_accuracy

end
