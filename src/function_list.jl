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
    (:cdfnorm, :cdfnorm!, :CdfNorm),
)

binary_real = (
    (:atan, :atan!, :Atan2, false),
    (:hypot, :hypot!, :Hypot, false),
    # Not in Base
    (:atanpi, :atanpi!, :Atan2pi, false),
)

unary_complex_in = (
    (:abs, :abs!, :Abs),
    (:angle, :angle!, :Arg),
)

unary_complex_inout = (
    (:conj, :conj!, :Conj),
)
