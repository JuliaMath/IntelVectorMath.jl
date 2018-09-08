module TestStuff
using SpecialFunctions
using VML

const base_unary_real = (
    (Base.acos, v_acos, acos!, (-1, 1)),
    (Base.asin, v_asin, asin!, (-1, 1)),
    (Base.atan, v_atan, atan!, (-50, 50)),
    (Base.cos, v_cos, cos!, (-1000, 1000)),
    (Base.sin, v_sin, sin!, (-1000, 1000)),
    (Base.tan, v_tan, tan!, (-1000, 1000)),
    (Base.acosh, v_acosh, acosh!, (1, 1000)),
    (Base.asinh, v_asinh, asinh!, (-1000, 1000)),
    (Base.atanh, v_atanh, atanh!, (-1, 1)),
    (Base.cosh, v_cosh, cosh!, (0, 89.415985f0)),
    (Base.sinh, v_sinh, sinh!, (-89.415985f0, 89.415985f0)),
    (Base.tanh, v_tanh, tanh!, (-8.66434f0, 8.66434f0)),
    (Base.cbrt, v_cbrt, cbrt!, (-1000, 1000)),
    (Base.sqrt, v_sqrt, sqrt!, (0, 1000)),
    (Base.exp, v_exp, exp!, (-88.72284f0, 88.72284f0)),
    (Base.expm1, v_expm1, expm1!, (-88.72284f0, 88.72284f0)),
    (Base.log, v_log, log!, (0, 1000)),
    (Base.log10, v_log10, log10!, (0, 1000)),
    (Base.log1p, v_log1p, log1p!, (-1, 1000)),
    (Base.abs, v_abs, abs!, (-1000, 1000)),
    (Base.abs2, v_abs2, abs2!, (-1000, 1000)),
    (Base.ceil, v_ceil, ceil!, (-1000, 1000)),
    (Base.floor, v_floor, floor!, (-1000, 1000)),
    (Base.round, v_round, round!, (-1000, 1000)),
    (Base.trunc, v_trunc, trunc!, (-1000, 1000)),
    (SpecialFunctions.erf, v_erf, erf!, (-3.8325067f0, 3.8325067f0)),
    (SpecialFunctions.erfc, v_erfc, erfc!, (-3.7439213f0, 10.019834f0)),
    (SpecialFunctions.erfinv, v_erfinv, erfinv!, (-1, 1)),
    (SpecialFunctions.erfcinv, v_erfcinv, erfcinv!, (0, 2)),
    (SpecialFunctions.lgamma, v_lgamma, lgamma!, (0, 1000)),
    (SpecialFunctions.gamma, v_gamma, gamma!, (0, 36))
)

const base_binary_real = (
#    (Base.atan2, v_atan2, atan2!, (-1, 1), (-1, 1)),
    (Base.hypot, v_hypot, hypot!, (-1000, 1000), (-1000, 1000)),
#    (getfield(Base, :/), (-1000, 1000), (-1000, 1000)),
#    (getfield(Base, :^), (0, 100), (-5, 20))
)

const base_unary_complex = (
    (Base.acos, v_acos, acos!, (-1, 1)),
    (Base.asin, v_asin, asin!, (-1, 1)),
    # (Base.atan, v_atan, atan!, (-50, 50)),
    # (Base.cos, v_cos, cos!, (-10, 10)),
    # (Base.sin, v_sin, sin!, (-10, 10)),
    # (Base.tan, v_tan, tan!, (-10, 10)),
    (Base.acosh, v_acosh, acosh!, (1, 1000)),
    (Base.asinh, v_asinh, asinh!, (-1000, 1000)),
    # (Base.atanh, v_atanh, atanh!, (-1, 1)),
    # (Base.cosh, v_cosh, cosh!, (0, 89.415985f0)),
    # (Base.sinh, v_sinh, sinh!, (-89.415985f0, 89.415985f0)),
    # (Base.tanh, v_tanh, tanh!, (-8.66434f0, 8.66434f0)),
    (Base.sqrt, v_sqrt, sqrt!, (0, 1000)),
    (Base.exp, v_exp, exp!, (-88.72284f0, 88.72284f0)),
    (Base.log, v_log, log!, (0, 1000)),
    # (Base.log10, v_log10, log10!, (0, 1000)),
    (Base.abs, v_abs, abs!, (-1000, 1000)),
    (Base.angle, v_angle, angle!, (-1000, 1000))
    # (Base.conj, v_conj, conj!, (-1000, 1000))
)

const base_binary_complex = (
#    (getfield(Base, :/), (-1000, 1000), (-1000, 1000)),
    # (Base.(:.^), (0, 100), (-2, 10))
)

function randindomain(t::Type{T}, n, domain) where T<:Real
    d1 = convert(t, domain[1])
    d2 = convert(t, domain[2])
    ddiff = d2 - d1
    @assert isfinite(ddiff)
    v = rand(t, n)
    for i = 1:length(v)
        v[i] = v[i]*ddiff+d1
    end
    v
end

function randindomain(t::Type{T}, n, domain) where T<:Complex
    d1 = convert(t, domain[1])
    d2 = convert(t, domain[2])
    ddiff = d2 - d1
    @assert isfinite(ddiff)
    v = rand(t, 2*n)
    for i = 1:length(v)
        v[i] = v[i]*ddiff+d1
    end
    copy(reinterpret(t, v))
end
end
