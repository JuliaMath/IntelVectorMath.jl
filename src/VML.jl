module VML

# TODO detect CPU architecture
const lib = :libmkl_vml_avx

const unary_ops = [(:(Base.acos), :acos!, :Acos),
                   (:(Base.asin), :asin!, :Asin),
                   (:(Base.atan), :atan!, :Atan),
                   (:(Base.cos), :cos!, :Cos),
                   (:(Base.sin), :sin!, :Sin),
                   (:(Base.tan), :tan!, :Tan),
                   (:(Base.acosh), :acosh!, :Acosh),
                   (:(Base.asinh), :asinh!, :Asinh),
                   (:(Base.atanh), :atanh!, :Atanh),
                   (:(Base.cosh), :cosh!, :Cosh),
                   (:(Base.sinh), :sinh!, :Sinh),
                   (:(Base.tanh), :tanh!, :Tanh),
                   (:(Base.cbrt), :cbrt!, :Cbrt),
                   (:(Base.sqrt), :sqrt!, :Sqrt),
                   (:(Base.exp), :exp!, :Exp),
                   (:(Base.expm1), :expm1!, :Expm1),
                   (:(Base.log), :log!, :Ln),
                   (:(Base.log10), :log10!, :Log10),
                   (:(Base.log1p), :log1p, :Log1p),
                   (:(Base.abs), :abs!, :Abs),
                   (:(Base.abs2), :abs2!, :Sqr),
                   (:(Base.ceil), :ceil!, :Ceil),
                   (:(Base.floor), :floor!, :Floor),
                   (:(Base.round), :round!, :Round),
                   (:(Base.trunc), :trunc!, :Trunc),
                   (:(Base.erf), :erf!, :Erf),
                   (:(Base.erfc), :erfc!, :Erfc),
                   (:(Base.erfinv), :erfinv!, :ErfInv),
                   (:(Base.erfcinv), :erfcinv!, :ErfcInv),
                   (:(Base.lgamma), :lgamma!, :LGamma),
                   (:(Base.gamma), :gamma!, :TGamma),
                   # Not in Base
                   (:inv_cbrt, :inv_cbrt!, :InvCbrt),
                   (:inv_sqrt, :inv_sqrt!, :InvSqrt),
                   (:pow2o3, :pow2o3!, :Pow2o3),
                   (:pow3o2, :pow3o2!, :Pow3o2)]

const binary_vector_ops = [(:(Base.atan2), :atan2!, :Atan2, false),
                           (:(Base.hypot), :hypot!, :Hypot, false),
                           (:(Base.(:.^)), :pow!, :Pow, true),
                           (:(Base.(:.+)), :add!, :Add, true),
                           (:(Base.(:./)), :divide!, :Div, true),
                           (:(Base.(:.*)), :multiply!, :Mul, true),
                           (:(Base.(:.-)), :subtract!, :Sub, true)]

for (prefix, t) in ((:_vmls, :Float32), (:_vmld, :Float64))
    # Unary
    for (jlname, jlname!, mklname) in unary_ops
        mklfn = Base.Meta.quot(symbol("$prefix$mklname"))
        exports = Symbol[]
        isa(jlname, Expr) || push!(exports, jlname)
        isa(jlname!, Expr) || push!(exports, jlname!)
        @eval begin
            $(isempty(exports) ? nothing : Expr(:export, exports...))
            function $(jlname!){N}(out::Array{$t,N}, A::Array{$t,N})
                size(out) == size(A) || throw(DimensionMismatch())
                ccall(($mklfn, lib), Void, (Int, Ptr{$t}, Ptr{$t}), length(A), A, out)
                out
            end
            function $(jlname!)(A::Array{$t})
                ccall(($mklfn, lib), Void, (Int, Ptr{$t}, Ptr{$t}), length(A), A, A)
                A
            end
            function $(jlname)(A::Array{$t})
                out = similar(A)
                ccall(($mklfn, lib), Void, (Int, Ptr{$t}, Ptr{$t}), length(A), A, out)
                out
            end
        end
    end

    # Binary, two vectors
    for (jlname, jlname!, mklname, broadcast) in binary_vector_ops
        mklfn = Base.Meta.quot(symbol("$prefix$mklname"))
        exports = Symbol[]
        isa(jlname, Expr) || push!(exports, jlname)
        isa(jlname!, Expr) || push!(exports, jlname!)
        @eval begin
            $(isempty(exports) ? nothing : Expr(:export, exports...))
            function $(jlname!){N}(out::Array{$t,N}, A::Array{$t,N}, B::Array{$t,N})
                size(out) == size(A) == size(B) || $(broadcast ? :(return broadcast!($jlname, out, A, B)) : :(throw(DimensionMismatch())))
                ccall(($mklfn, lib), Void, (Int, Ptr{$t}, Ptr{$t}, Ptr{$t}), length(A), A, B, out)
                out
            end
            function $(jlname){N}(A::Array{$t,N}, B::Array{$t,N})
                size(A) == size(B) || $(broadcast ? :(return broadcast($jlname, A, B)) : :(throw(DimensionMismatch())))
                out = similar(A)
                ccall(($mklfn, lib), Void, (Int, Ptr{$t}, Ptr{$t}, Ptr{$t}), length(A), A, B, out)
                out
            end
        end
    end

    # Binary, vector and scalar
    mklfn = Base.Meta.quot(symbol("$(prefix)Powx"))
    @eval begin
        export pow!
        function pow!{N}(out::Array{$t,N}, A::Array{$t,N}, b::$t)
            size(out) == size(A) || throw(DimensionMismatch())
            ccall(($mklfn, lib), Void, (Int, Ptr{$t}, $t, Ptr{$t}), length(A), A, b, out)
            out
        end
        function Base.(:(.^)){N}(A::Array{$t,N}, b::$t)
            out = similar(A)
            ccall(($mklfn, lib), Void, (Int, Ptr{$t}, $t, Ptr{$t}), length(A), A, b, out)
            out
        end
    end
end

immutable VMLAccuracy
    mode::Uint
end
const VML_LA = VMLAccuracy(0x00000001)
const VML_HA = VMLAccuracy(0x00000002)
const VML_EP = VMLAccuracy(0x00000003)
Base.show(io::IO, m::VMLAccuracy) = print(io, m == VML_LA ? "VML_LA" :
                                              m == VML_HA ? "VML_HA" : "VML_EP")
vml_cur_mode() = ccall((:_vmlGetMode, lib), Cuint, ())
vml_set_accuracy(m::VMLAccuracy) = (ccall((:_vmlSetMode, lib), Cuint, (Uint,),
                                          (vml_cur_mode() & ~0x03) | m.mode); nothing)
vml_get_accuracy() = VMLAccuracy(vml_cur_mode() & 0x3)

export VML_LA, VML_HA, VML_EP, vml_set_accuracy, vml_get_accuracy
end