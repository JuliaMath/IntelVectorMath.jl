
function __init__()

    Libdl.dlopen(libmkl_core, Libdl.RTLD_GLOBAL)
    Libdl.dlopen(libmkl_rt, Libdl.RTLD_GLOBAL) # maybe only needed on mac
    Libdl.dlopen(libmkl_vml_avx, Libdl.RTLD_GLOBAL)

end

__init__()

struct VMLAccuracy
    mode::UInt
end

const VML_LA = VMLAccuracy(0x00000001)
const VML_HA = VMLAccuracy(0x00000002)
const VML_EP = VMLAccuracy(0x00000003)

Base.show(io::IO, m::VMLAccuracy) = print(io, m == VML_LA ? "VML_LA" :
                                              m == VML_HA ? "VML_HA" : "VML_EP")
vml_get_mode() = ccall((:_vmlGetMode, libmkl_vml_avx), Cuint, ())
vml_set_mode(mode::Integer) = (ccall((:_vmlSetMode, libmkl_vml_avx), Cuint, (UInt,), mode); nothing)

vml_set_accuracy(m::VMLAccuracy) = vml_set_mode((vml_get_mode() & ~0x03) | m.mode)
vml_get_accuracy() = VMLAccuracy(vml_get_mode() & 0x3)

vml_set_mode((vml_get_mode() & ~0x0000FF00))
function vml_check_error()
    vml_error = ccall((:_vmlClearErrStatus, libmkl_vml_avx), Cint, ())
    if vml_error != 0
        if vml_error == 1
            throw(DomainError(-1, "This function does not support arguments outside its domain"))
        elseif vml_error == 2 || vml_error == 3 || vml_error == 4
            # Singularity, overflow, or underflow
            # I don't think Base throws on these
        elseif vml_error == 1000
            warn("IntelVectorMath does not support $(vml_get_accuracy); lower accuracy used instead")
        else
            error("an unexpected error occurred in IntelVectorMath ($vml_error)")
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

function def_unary_op(tin, tout, jlname, jlname!, mklname;
        vmltype = tin)
    mklfn = Base.Meta.quot(Symbol("$(vml_prefix(vmltype))$mklname"))
    exports = Symbol[]
    (@isdefined jlname) || push!(exports, jlname)
    (@isdefined jlname!) || push!(exports, jlname!)
    @eval begin
        function ($jlname!)(out::Array{$tout,N}, A::Array{$tin,N}) where {N}
            size(out) == size(A) || throw(DimensionMismatch())
            ccall(($mklfn, libmkl_vml_avx), Nothing, (Int, Ptr{$tin}, Ptr{$tout}), length(A), A, out)
            vml_check_error()
            return out
        end
        $(if tin == tout
            quote
                function $(jlname!)(A::Array{$tin})
                    ccall(($mklfn, libmkl_vml_avx), Nothing, (Int, Ptr{$tin}, Ptr{$tout}), length(A), A, A)
                    vml_check_error()
                    return A
                end
            end
        end)
        function ($jlname)(A::Array{$tin})
            out = similar(A, $tout)
            ccall(($mklfn, libmkl_vml_avx), Nothing, (Int, Ptr{$tin}, Ptr{$tout}), length(A), A, out)
            vml_check_error()
            return out
        end
        $(isempty(exports) ? nothing : Expr(:export, exports...))
    end
end

function def_binary_op(tin, tout, jlname, jlname!, mklname, broadcast)
    mklfn = Base.Meta.quot(Symbol("$(vml_prefix(tin))$mklname"))
    exports = Symbol[]
    (@isdefined jlname) || push!(exports, jlname)
    (@isdefined jlname!) || push!(exports, jlname!)
    @eval begin
        $(isempty(exports) ? nothing : Expr(:export, exports...))
        function ($jlname!)(out::Array{$tout,N}, A::Array{$tin,N}, B::Array{$tin,N}) where {N}
            size(out) == size(A) == size(B) || $(broadcast ? :(return broadcast!($jlname, out, A, B)) : :(throw(DimensionMismatch())))
            ccall(($mklfn, libmkl_vml_avx), Nothing, (Int, Ptr{$tin}, Ptr{$tin}, Ptr{$tout}), length(A), A, B, out)
            vml_check_error()
            return out
        end
        function ($jlname)(A::Array{$tout,N}, B::Array{$tin,N}) where {N}
            size(A) == size(B) || $(broadcast ? :(return broadcast($jlname, A, B)) : :(throw(DimensionMismatch())))
            out = similar(A)
            ccall(($mklfn, libmkl_vml_avx), Nothing, (Int, Ptr{$tin}, Ptr{$tin}, Ptr{$tout}), length(A), A, B, out)
            vml_check_error()
            return out
        end
    end
end
