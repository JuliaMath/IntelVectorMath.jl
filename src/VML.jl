module VML
using Libdl
using SpecialFunctions

import Base: ^, /

# TODO detect CPU architecture
const lib = :libmkl_vml_avx2

struct VMLAccuracy
    mode::UInt
end
const VML_LA = VMLAccuracy(0x00000001)
const VML_HA = VMLAccuracy(0x00000002)
const VML_EP = VMLAccuracy(0x00000003)
Base.show(io::IO, m::VMLAccuracy) = print(io, m == VML_LA ? "VML_LA" :
                                              m == VML_HA ? "VML_HA" : "VML_EP")
vml_get_mode() = ccall((:_vmlGetMode, lib), Cuint, ())
vml_set_mode(mode::Integer) = (ccall((:_vmlSetMode, lib), Cuint, (UInt,), mode); nothing)

vml_set_accuracy(m::VMLAccuracy) = vml_set_mode((vml_get_mode() & ~0x03) | m.mode)
vml_get_accuracy() = VMLAccuracy(vml_get_mode() & 0x3)

function vml_check_error()
    vml_error = ccall((:_vmlClearErrStatus, lib), Cint, ())
    if vml_error != 0
        if vml_error == 1
            throw(DomainError(NaN,"(arg val not avail for VML error)"))
        elseif vml_error == 2 || vml_error == 3 || vml_error == 4
            # Singularity, overflow, or underflow
            # I don't think Base throws on these
        elseif vml_error == 1000
            warn("VML does not support $(vml_get_accuracy); lower accuracy used instead")
        else
            error("an unexpected error occurred in VML ($vml_error)")
        end
    end
end

function vml_prefix(t::DataType)
    if t == Float32
        return "_vmls"
    elseif t == Float64
        return "_vmld"
    elseif t == Complex{Float32}
        return "_vmlc"
    elseif t == Complex{Float64}
        return "_vmlz"
    end
    error("unknown type $t")
end

function def_unary_op(tin, tout, jlname, jlvname, jlname!, mklname)
    mklfn = Base.Meta.quot(Symbol("$(vml_prefix(tin))$mklname"))
    exports = Symbol[]
    isa(jlvname, Expr) || push!(exports, jlvname)
    isa(jlname!, Expr) || push!(exports, jlname!)
    @eval begin
        $(isempty(exports) ? nothing : Expr(:export, exports...))
        function $(jlname!)(out::Array{$tout,N}, A::Array{$tin,N}) where N
            size(out) == size(A) || throw(DimensionMismatch())
            ccall(($mklfn, lib), Cvoid, (Int, Ptr{$tin}, Ptr{$tout}), length(A), A, out)
            vml_check_error()
            out
        end
        $(if tin == tout
            quote
                function $(jlname!)(A::Array{$tin})
                    ccall(($mklfn, lib), Cvoid, (Int, Ptr{$tin}, Ptr{$tout}), length(A), A, A)
                    vml_check_error()
                    A
                end
            end
        end)
        function $(jlvname)(A::Array{$tin})
            out = similar(A, $tout)
            ccall(($mklfn, lib), Cvoid, (Int, Ptr{$tin}, Ptr{$tout}), length(A), A, out)
            vml_check_error()
            out
        end
    end
end

function def_binary_op(tin, tout, jlname, jlvname, jlname!, mklname, broadcast)
    mklfn = Base.Meta.quot(Symbol("$(vml_prefix(tin))$mklname"))
    exports = Symbol[]
    isa(jlvname, Expr) || push!(exports, jlvname)
    isa(jlname!, Expr) || push!(exports, jlname!)
    @eval begin
        $(isempty(exports) ? nothing : Expr(:export, exports...))
        function $(jlname!)(out::Array{$tout,N}, A::Array{$tin,N}, B::Array{$tin,N}) where N
            size(out) == size(A) == size(B) || $(broadcast ? :(return broadcast!($jlname, out, A, B)) : :(throw(DimensionMismatch())))
            ccall(($mklfn, lib), Cvoid, (Int, Ptr{$tin}, Ptr{$tin}, Ptr{$tout}), length(A), A, B, out)
            vml_check_error()
            out
        end
        function $(jlvname)(A::Array{$tout,N}, B::Array{$tin,N}) where N
            size(A) == size(B) || $(broadcast ? :(return broadcast($jlname, A, B)) : :(throw(DimensionMismatch())))
            out = similar(A)
            ccall(($mklfn, lib), Cvoid, (Int, Ptr{$tin}, Ptr{$tin}, Ptr{$tout}), length(A), A, B, out)
            vml_check_error()
            out
        end
    end
end

for t in (Float32, Float64, ComplexF32, ComplexF64)
    # Unary, real or complex
    def_unary_op(t, t, :(Base.acos), :v_acos, :acos!, :Acos)
    def_unary_op(t, t, :(Base.asin), :v_asin, :asin!, :Asin)
    def_unary_op(t, t, :(Base.acosh), :v_acosh, :acosh!, :Acosh)
    def_unary_op(t, t, :(Base.asinh), :v_asinh, :asinh!, :Asinh)
    def_unary_op(t, t, :(Base.sqrt), :v_sqrt, :sqrt!, :Sqrt)
    def_unary_op(t, t, :(Base.exp), :v_exp, :exp!, :Exp)
    def_unary_op(t, t, :(Base.log), :v_log, :log!, :Ln)

    # Binary, real or complex
    def_binary_op(t, t, :(^), :v_pow, :pow!, :Pow, true)
    def_binary_op(t, t, :(/), :v_divide, :divide!, :Div, true)
end

for t in (Float32, Float64)
    # Unary, real-only
    def_unary_op(t, t, :(Base.cbrt), :v_cbrt, :cbrt!, :Cbrt)
    def_unary_op(t, t, :(Base.expm1), :v_expm1, :expm1!, :Expm1)
    def_unary_op(t, t, :(Base.log1p), :v_log1p, :log1p!, :Log1p)
    def_unary_op(t, t, :(Base.abs), :v_abs, :abs!, :Abs)
    def_unary_op(t, t, :(Base.abs2), :v_abs2, :abs2!, :Sqr)
    def_unary_op(t, t, :(Base.ceil), :v_ceil, :ceil!, :Ceil)
    def_unary_op(t, t, :(Base.floor), :v_floor, :floor!, :Floor)
    def_unary_op(t, t, :(Base.round), :v_round, :round!, :Round)
    def_unary_op(t, t, :(Base.trunc), :v_trunc, :trunc!, :Trunc)
    def_unary_op(t, t, :(SpecialFunctions.erf), :v_erf, :erf!, :Erf)
    def_unary_op(t, t, :(SpecialFunctions.erfc), :v_erfc, :erfc!, :Erfc)
    def_unary_op(t, t, :(SpecialFunctions.erfinv), :v_erfinv, :erfinv!, :ErfInv)
    def_unary_op(t, t, :(SpecialFunctions.erfcinv), :v_erfcinv, :erfcinv!, :ErfcInv)
    def_unary_op(t, t, :(SpecialFunctions.lgamma), :v_lgamma, :lgamma!, :LGamma)
    def_unary_op(t, t, :(SpecialFunctions.gamma), :v_gamma, :gamma!, :TGamma)
    # Not in Base
    def_unary_op(t, t, :inv_cbrt, :v_inv_cbrt, :inv_cbrt!, :InvCbrt)
    def_unary_op(t, t, :inv_sqrt, :v_inv_sqrt, :inv_sqrt!, :InvSqrt)
    def_unary_op(t, t, :pow2o3, :v_pow2o3, :pow2o3!, :Pow2o3)
    def_unary_op(t, t, :pow3o2, :v_pow3o2, :pow3o2!, :Pow3o2)

    # Enabled only for Real. MKL guarantees higher accuracy, but at a
    # substantial performance cost.
    def_unary_op(t, t, :(Base.atan), :v_atan, :atan!, :Atan)
    def_unary_op(t, t, :(Base.cos), :v_cos, :cos!, :Cos)
    def_unary_op(t, t, :(Base.sin), :v_sin, :sin!, :Sin)
    def_unary_op(t, t, :(Base.tan), :v_tan, :tan!, :Tan)
    def_unary_op(t, t, :(Base.atanh), :v_atanh, :atanh!, :Atanh)
    def_unary_op(t, t, :(Base.cosh), :v_cosh, :cosh!, :Cosh)
    def_unary_op(t, t, :(Base.sinh), :v_sinh, :sinh!, :Sinh)
    def_unary_op(t, t, :(Base.tanh), :v_tanh, :tanh!, :Tanh)
    def_unary_op(t, t, :(Base.log10), :v_log10, :log10!, :Log10)

    # Binary, real-only
    def_binary_op(t, t, :(Base.atan), :v_atan2, :atan2!, :Atan2, false)
    def_binary_op(t, t, :(Base.hypot), :v_hypot, :hypot!, :Hypot, false)

    # Unary, complex-only
    def_unary_op(t, Complex{t}, :(Base.cis), :v_cis, :cis!, :CIS)
    # def_unary_op(Complex{t}, Complex{t}, :(Base.conj), :v_conj, :conj!, :Conj)
    def_unary_op(Complex{t}, t, :(Base.abs), :v_abs, :abs!, :Abs)
    def_unary_op(Complex{t}, t, :(Base.angle), :v_angle, :angle!, :Arg)

    # Binary, complex-only. These are more accurate but performance is
    # either equivalent to Base or slower.
    # def_binary_op(Complex{t}, Complex{t}, :(Base.(:+)), :v_add, :add!, :Add, false)
    # def_binary_op(Complex{t}, Complex{t}, :(Base.(:.+)), :v_add, :add!, :Add, true)
    # def_binary_op(Complex{t}, Complex{t}, :(Base.(:.*)), :v_multiply, :multiply!, :Mul, true)
    # def_binary_op(Complex{t}, Complex{t}, :(Base.(:-)), :v_subtract, :subtract!, :Sub, false)
    # def_binary_op(Complex{t}, Complex{t}, :(Base.(:.-)), :v_subtract, :subtract!, :Sub, true)
    # def_binary_op(Complex{t}, Complex{t}, :multiply_conj, :v_multiply_conj, :multiply_conj!, :Mul, false)
end
for t in (Float32, Float64, ComplexF32, ComplexF64)
    # .^ to scalar power
    mklfn = Base.Meta.quot(Symbol("$(vml_prefix(t))Powx"))
    @eval begin
        export pow!
        function pow!(out::Array{$t,N}, A::Array{$t,N}, b::$t) where N
            size(out) == size(A) || throw(DimensionMismatch())
            ccall(($mklfn, lib), Cvoid, (Int, Ptr{$t}, $t, Ptr{$t}), length(A), A, b, out)
            vml_check_error()
            out
        end
        function (v_pow)(A::Array{$t,N}, b::$t) where N
            out = similar(A)
            ccall(($mklfn, lib), Cvoid, (Int, Ptr{$t}, $t, Ptr{$t}), length(A), A, b, out)
            vml_check_error()
            out
        end
    end

end

export VML_LA, VML_HA, VML_EP, vml_set_accuracy, vml_get_accuracy

function __init__()
    Libdl.dlopen(:libmkl_core, Libdl.RTLD_GLOBAL)
    Libdl.dlopen(:libmkl_rt, Libdl.RTLD_GLOBAL)
    Libdl.dlopen(lib)
    # vml_set_mode((vml_get_mode() & ~0x0000FF00))
end

end
