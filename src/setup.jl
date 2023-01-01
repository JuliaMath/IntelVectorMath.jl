import MKL_jll

"""
    struct VMLAccuracy

See [`VML_LA`](@ref), [`VML_HA`](@ref), [`VML_EP`](@ref).
"""
struct VMLAccuracy
    mode::UInt
end
Base.show(io::IO, m::VMLAccuracy) = print(io, m == VML_LA ? "VML_LA" :
                                              m == VML_HA ? "VML_HA" : "VML_EP")
# mkl\include\mkl_vml_defines.h
# VML_HA - when VML_HA is set, high accuracy VML functions are called
# VML_LA - when VML_LA is set, low accuracy VML functions are called
# VML_EP - when VML_EP is set, enhanced performance VML functions are called
# NOTE: VML_HA, VML_LA and VML_EP must not be used in combination
"""
    VML_LA :: VMLAccuracy

Low Accuracy (LA), which improves performance by reducing accuracy of the two least significant bits.
"""
const VML_LA = VMLAccuracy(0x00000001)
"""
    VML_HA :: VMLAccuracy

High Accuracy (HA), the default mode. Precision to 1 ulp.
"""
const VML_HA = VMLAccuracy(0x00000002)
"""
    VML_EP :: VMLAccuracy

Enhanced Performance (EP), which provides better performance at the cost of significantly reduced accuracy.
Approximately half of the bits in the mantissa are correct.
"""
const VML_EP = VMLAccuracy(0x00000003)


"""
    struct VMLAccuracy

See [`VML_DENORMAL_FAST`](@ref), [`VML_DENORMAL_ACCURATE`](@ref).
"""
struct VMLFastDenormal
    mode::UInt
end
Base.show(io::IO, m::VMLFastDenormal) = print(io, m == VML_DENORMAL_FAST ? "VML_DENORMAL_FAST" : "VML_DENORMAL_ACCURATE")
# mkl\include\mkl_vml_defines.h
#  FTZ & DAZ mode macros
#  VML_FTZDAZ_ON   - FTZ & DAZ MXCSR mode enabled
#                    for faster (sub)denormal values processing
#  VML_FTZDAZ_OFF  - FTZ & DAZ MXCSR mode disabled
#                    for accurate (sub)denormal values processing
"""
    VML_DENORMAL_FAST :: VMLFastDenormal

Designed to improve the performance of computations that involve denormalized numbers at the cost of reasonable accuracy loss.
This mode changes the numeric behavior of the functions: denormalized input values are treated as zeros and denormalized results
are flushed to zero. Accuracy loss may occur if input and/or output values are close to denormal range.
"""
const VML_DENORMAL_FAST      = VMLFastDenormal(0x00280000)
"""
    VML_DENORMAL_ACCURATE :: VMLFastDenormal

Standard handling of computations that involve denormalized numbers.
"""
const VML_DENORMAL_ACCURATE  = VMLFastDenormal(0x00140000)


struct VMLFpuMode
    mode::UInt
end
Base.show(io::IO, m::VMLFpuMode) = print(io,  m == VML_FPU_DEFAULT ? "VML_FPU_DEFAULT" :
                                              m == VML_FPU_FLOAT32 ? "VML_FPU_FLOAT32" : 
                                              m == VML_FPU_FLOAT64 ? "VML_FPU_FLOAT64" : "VML_FPU_RESTORE")
# mkl\include\mkl_vml_defines.h
#  SETTING OPTIMAL FLOATING-POINT PRECISION AND ROUNDING MODE
#  Definitions below are to set optimal floating-point control word
#  (precision and rounding mode).
#
#  For their correct work, VML functions change floating-point precision and
#  rounding mode (if necessary). Since control word changing is typically
#  expensive operation, it is recommended to set precision and rounding mode
#  to optimal values before VML function calls.
#
#  VML_FLOAT_CONSISTENT  - use this value if the calls are typically to single
#                          precision VML functions
#  VML_DOUBLE_CONSISTENT - use this value if the calls are typically to double
#                          precision VML functions
#  VML_RESTORE           - restore original floating-point precision and
#                          rounding mode
#  VML_DEFAULT_PRECISION - use default (current) floating-point precision and
#                          rounding mode
#  NOTE: VML_FLOAT_CONSISTENT, VML_DOUBLE_CONSISTENT, VML_RESTORE and
#        VML_DEFAULT_PRECISION must not be used in combination
const VML_FPU_DEFAULT = VMLFpuMode(0x00000000) # VML_DEFAULT_PRECISION
const VML_FPU_FLOAT32 = VMLFpuMode(0x00000010) # VML_FLOAT_CONSISTENT
const VML_FPU_FLOAT64 = VMLFpuMode(0x00000020) # VML_DOUBLE_CONSISTENT
const VML_FPU_RESTORE = VMLFpuMode(0x00000030) # VML_RESTORE

# mkl\include\mkl_vml_defines.h
#  ACCURACY, FLOATING-POINT CONTROL, FTZDAZ AND ERROR HANDLING MASKS
#  Accuracy, floating-point and error handling control are packed in
#  the VML mode variable. Macros below are useful to extract accuracy and/or
#  floating-point control and/or error handling control settings.
#
#  VML_ACCURACY_MASK           - extract accuracy bits
#  VML_FPUMODE_MASK            - extract floating-point control bits
#  VML_ERRMODE_MASK            - extract error handling control bits
#                                (including error callback bits)
#  VML_ERRMODE_STDHANDLER_MASK - extract error handling control bits
#                                (not including error callback bits)
#  VML_ERRMODE_CALLBACK_MASK   - extract error callback bits
#  VML_NUM_THREADS_OMP_MASK    - extract OpenMP(R) number of threads mode bits
#  VML_FTZDAZ_MASK             - extract FTZ & DAZ bits
#  VML_TRAP_EXCEPTIONS_MASK    - extract exception trap bits
const VML_ACCURACY_MASK           = 0x0000000F
const VML_FPUMODE_MASK            = 0x000000F0
const VML_ERRMODE_MASK            = 0x0000FF00
const VML_ERRMODE_STDHANDLER_MASK = 0x00002F00
const VML_ERRMODE_CALLBACK_MASK   = 0x00001000
const VML_NUM_THREADS_OMP_MASK    = 0x00030000
const VML_FTZDAZ_MASK             = 0x003C0000
const VML_TRAP_EXCEPTIONS_MASK    = 0x0F000000

# https://www.intel.com/content/www/us/en/develop/documentation/onemkl-developer-reference-c/top/vector-mathematical-functions/vm-service-functions.html
vml_get_mode() = ccall((:vmlGetMode, MKL_jll.libmkl_rt), Cuint, ())
vml_set_mode(mode::Integer) = (ccall((:vmlSetMode, MKL_jll.libmkl_rt), Cuint, (UInt,), mode); nothing)

"""
    vml_set_accuracy([VML_HA | VML_LA | VML_EP]])

Set the current accuracy mode. See [`VML_LA`](@ref), [`VML_HA`](@ref), [`VML_EP`](@ref).
"""
vml_set_accuracy(m::VMLAccuracy) = vml_set_mode((vml_get_mode() & ~VML_ACCURACY_MASK) | m.mode)
"""
    vml_get_accuracy() :: VMLAccuracy

Get the current accuracy mode. See [`VML_LA`](@ref), [`VML_HA`](@ref), [`VML_EP`](@ref).
"""
vml_get_accuracy() = VMLAccuracy(vml_get_mode() & VML_ACCURACY_MASK)

"""
    vml_set_denormalmode([VML_DENORMAL_FAST | VML_DENORMAL_ACCURATE]])

Set the current mode of denormal handling. See [`VML_DENORMAL_FAST`](@ref), [`VML_DENORMAL_ACCURATE`](@ref).
"""
vml_set_denormalmode(m::VMLFastDenormal) = vml_set_mode((vml_get_mode() & ~VML_FTZDAZ_MASK) | m.mode)
"""
    vml_get_denormalmode() :: VMLFastDenormal

Get the current mode of denormal handling. See [`VML_DENORMAL_FAST`](@ref), [`VML_DENORMAL_ACCURATE`](@ref).
"""
vml_get_denormalmode() = VMLFastDenormal(vml_get_mode() & VML_FTZDAZ_MASK)

# Ignored with MKL 2022 on i7-5930k, was usefull once upton a time.
vml_set_fpumode(m::VMLFpuMode) = vml_set_mode((vml_get_mode() & ~VML_FPUMODE_MASK) | m.mode)
vml_get_fpumode() = VMLFpuMode(vml_get_mode() & VML_FPUMODE_MASK)

# -----------------------------------------------------------------------------------------------

# https://www.intel.com/content/www/us/en/develop/documentation/onemkl-developer-reference-c/top/support-functions/threading-control.html
#
# See: mkl\include\mkl_service.h
# _Mkl_Api(int,MKL_Domain_Set_Num_Threads,(int nth, int MKL_DOMAIN))
# _Mkl_Api(int,MKL_Domain_Get_Max_Threads,(int MKL_DOMAIN))
#  #define mkl_domain_set_num_threads  MKL_Domain_Set_Num_Threads
#  #define mkl_domain_get_max_threads  MKL_Domain_Get_Max_Threads
#
# See: mkl\include\mkl_types.h
#  define MKL_DOMAIN_ALL      0
#  define MKL_DOMAIN_BLAS     1
#  define MKL_DOMAIN_FFT      2
const     MKL_DOMAIN_VML  = 0x3
#  define MKL_DOMAIN_PARDISO  4

"""
    vml_get_max_threads() :: Int

Maximum number of threads that VML may use. By default, or after a call to `vml_set_num_threads(0)`,
should return the number of cores available to VML.
"""
vml_get_max_threads() = Int(ccall((:MKL_Domain_Get_Max_Threads, MKL_jll.libmkl_rt), Cint, (Cint,), MKL_DOMAIN_VML))
"""
    vml_set_num_threads(numthreads::Int) :: Bool

Set the maximum number of threads that VML may use. Use `numthreads=0` to restore the default.
Return `true` if the operation completed successfully.
"""
vml_set_num_threads(numthreads::Int) = Bool(ccall((:MKL_Domain_Set_Num_Threads, MKL_jll.libmkl_rt), Cuint, (Cint,Cint), numthreads, MKL_DOMAIN_VML))

# See: mkl\include\mkl_service.h
# _Mkl_Api(double,MKL_Get_Cpu_Frequency,(void))            /* Gets CPU frequency in GHz */
# _Mkl_Api(double,MKL_Get_Max_Cpu_Frequency,(void))        /* Gets max CPU frequency in GHz */
# #define mkl_get_cpu_frequency       MKL_Get_Cpu_Frequency
# #define mkl_get_max_cpu_frequency   MKL_Get_Max_Cpu_Frequency
#
# _Mkl_Api(void,MKL_Get_Cpu_Clocks,(unsigned MKL_INT64 *)) /* Gets CPU clocks */
# _Mkl_Api(double,MKL_Get_Clocks_Frequency,(void))         /* Gets clocks frequency in GHz */
# #define mkl_get_cpu_clocks          MKL_Get_Cpu_Clocks
# #define mkl_get_clocks_frequency    MKL_Get_Clocks_Frequency

"""
    vml_get_cpu_frequency() :: Float64

Current CPU frequency in GHz, maybe less or more than [`vml_get_max_cpu_frequency`](@ref).
"""
vml_get_cpu_frequency()     = ccall((:MKL_Get_Cpu_Frequency,     MKL_jll.libmkl_rt), Cdouble, ())
"""
    vml_get_max_cpu_frequency() :: Float64

Official CPU frequency in GHz, as per package specification. See also [`vml_get_cpu_frequency`](@ref).
"""
vml_get_max_cpu_frequency() = ccall((:MKL_Get_Max_Cpu_Frequency, MKL_jll.libmkl_rt), Cdouble, ())

# -----------------------------------------------------------------------------------------------

# mkl\include\mkl_vml_defines.h
#  ERROR STATUS MACROS
#  VML_STATUS_OK        - no errors
#  VML_STATUS_BADSIZE   - array dimension is not positive
#  VML_STATUS_BADMEM    - invalid pointer passed
#  VML_STATUS_ERRDOM    - at least one of arguments is out of function domain
#  VML_STATUS_SING      - at least one of arguments caused singularity
#  VML_STATUS_OVERFLOW  - at least one of arguments caused overflow
#  VML_STATUS_UNDERFLOW - at least one of arguments caused underflow
#  VML_STATUS_ACCURACYWARNING - function doesn't support set accuracy mode,
#                               lower accuracy mode was used instead
const VML_STATUS_OK                  =  0
const VML_STATUS_BADSIZE             = -1
const VML_STATUS_BADMEM              = -2
const VML_STATUS_ERRDOM              =  1
const VML_STATUS_SING                =  2
const VML_STATUS_OVERFLOW            =  3
const VML_STATUS_UNDERFLOW           =  4
const VML_STATUS_ACCURACYWARNING     =  1000

function vml_check_error()
    vml_error = ccall((:vmlClearErrStatus, MKL_jll.libmkl_rt), Cint, ())
    if vml_error != VML_STATUS_OK
        if vml_error == VML_STATUS_ERRDOM
            throw(DomainError(-1, "This function does not support arguments outside its domain"))
        elseif vml_error == VML_STATUS_SING || vml_error == VML_STATUS_OVERFLOW || vml_error == VML_STATUS_UNDERFLOW
            # Singularity, overflow, or underflow
            # I don't think Base throws on these
        elseif vml_error == VML_STATUS_ACCURACYWARNING
            warn("IntelVectorMath does not support $(vml_get_accuracy); lower accuracy used instead")
        else # VML_STATUS_BADSIZE or VML_STATUS_BADMEM
            error("an unexpected error occurred in IntelVectorMath ($vml_error)")
        end
    end
end

function vml_prefix(t::DataType)
    if t == Float32
        return "vs"
    elseif t == Float64
        return "vd"
    elseif t == Complex{Float32}
        return "vc"
    elseif t == Complex{Float64}
        return "vz"
    end
    error("unknown type $t")
end

if isdefined(Base, :_checkcontiguous)
    alldense(@nospecialize(x)) = Base._checkcontiguous(Bool, x)
else
    alldense(x) = x isa DenseArray
    alldense(x::Base.ReshapedArray) = alldense(parent(x))
    alldense(x::Base.FastContiguousSubArray) = alldense(parent(x))
    alldense(x::Base.ReinterpretArray) = alldense(parent(x))
end
alldense(x, y, z...) = alldense(x) && alldense(y, z...)

if isdefined(Base, :merge_adjacent_dim)
    const merge_adjacent_dim = Base.merge_adjacent_dim
else
    merge_adjacent_dim(::Dims{0}, ::Dims{0}) = 1, 1, 0
    merge_adjacent_dim(apsz::Dims{1}, apst::Dims{1}) = apsz[1], apst[1], 1
    function merge_adjacent_dim(apsz::Dims{N}, apst::Dims{N}, n::Int = 1) where {N}
        sz, st = apsz[n], apst[n]
        while n < N
            szₙ, stₙ = apsz[n+1], apst[n+1]
            if sz == 1
                sz, st = szₙ, stₙ
            elseif stₙ == st * sz || szₙ == 1
                sz *= szₙ
            else
                break
            end
            n += 1
        end
        return sz, st, n
    end
end

getstrides(x...) = map(stride1, x)
function stride1(x::AbstractArray)
    alldense(x) && return 1
    ndims(x) == 1 && return stride(x, 1)
    szs::Dims = size(x)
    sts::Dims = strides(x)
    _, st, n = merge_adjacent_dim(szs, sts)
    n === ndims(x) && return st
    throw(ArgumentError("only support vector like inputs"))
end

function def_unary_op(tin, tout, jlname, jlname!, mklname;
        vmltype = tin)
    mklfn = Base.Meta.quot(Symbol("$(vml_prefix(vmltype))$(mklname)I"))
    mklfndense = Base.Meta.quot(Symbol("$(vml_prefix(vmltype))$mklname"))
    exports = Symbol[]
    (@isdefined jlname) || push!(exports, jlname)
    (@isdefined jlname!) || push!(exports, jlname!)
    @eval begin
        function ($jlname!)(out::AbstractArray{$tout}, A::AbstractArray{$tin})
            size(out) == size(A) || throw(DimensionMismatch())
            if alldense(out, A)
                ccall(($mklfndense, MKL_jll.libmkl_rt), Nothing, (Int, Ptr{$tin}, Ptr{$tout}), length(A), A, out)
            else
                stᵒ, stᴬ = getstrides(out, A)
                ccall(($mklfn, MKL_jll.libmkl_rt), Nothing, (Int, Ptr{$tin}, Int, Ptr{$tout}, Int), length(A), A, stᴬ, out, stᵒ)
            end
            vml_check_error()
            return out
        end
        $(if tin == tout
            quote
                function $(jlname!)(A::AbstractArray{$tin})
                    if alldense(A)
                        ccall(($mklfndense, MKL_jll.libmkl_rt), Nothing, (Int, Ptr{$tin}, Ptr{$tout}), length(A), A, A)
                    else
                        (stᴬ,) = getstrides(A)
                        ccall(($mklfn, MKL_jll.libmkl_rt), Nothing, (Int, Ptr{$tin}, Int, Ptr{$tout}, Int), length(A), A, stᴬ, A, stᴬ)
                    end
                    vml_check_error()
                    return A
                end
            end
        end)
        ($jlname)(A::AbstractArray{$tin}) = $(jlname!)(similar(A, $tout), A)
        $(isempty(exports) ? nothing : Expr(:export, exports...))
    end
end

function def_binary_op(tin, tout, jlname, jlname!, mklname, broadcast)
    mklfndense = Base.Meta.quot(Symbol("$(vml_prefix(tin))$mklname"))
    mklfn = Base.Meta.quot(Symbol("$(vml_prefix(tin))$(mklname)I"))
    exports = Symbol[]
    (@isdefined jlname) || push!(exports, jlname)
    (@isdefined jlname!) || push!(exports, jlname!)
    @eval begin
        $(isempty(exports) ? nothing : Expr(:export, exports...))
        function ($jlname!)(out::AbstractArray{$tout}, A::AbstractArray{$tin}, B::AbstractArray{$tin})
            size(A) == size(B) || throw(DimensionMismatch("Input arrays need to have the same size"))
            size(out) == size(A) || throw(DimensionMismatch("Output array need to have the same size with input"))
            if alldense(out, A, B)
                ccall(($mklfndense, MKL_jll.libmkl_rt), Nothing, (Int, Ptr{$tin}, Ptr{$tin}, Ptr{$tout}), length(A), A, B, out)
            else
                stᵒ, stᴬ, stᴮ = getstrides(out, A, B)
                ccall(($mklfn, MKL_jll.libmkl_rt), Nothing, (Int, Ptr{$tin}, Int, Ptr{$tin}, Int, Ptr{$tout}, Int), length(A), A, stᴬ, B, stᴮ, out, stᵒ)
            end
            vml_check_error()
            return out
        end
        ($jlname)(A::AbstractArray{$tin}, B::AbstractArray{$tin}) = ($jlname!)(similar(A, $tout), A, B)
    end
end
