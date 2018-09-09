module TestStuff
using SpecialFunctions
using VML

const base_unary_real = (
    (Base.acos, VML.acos, VML.acos!, (-1, 1)),
    (Base.asin, VML.asin, VML.asin!, (-1, 1)),
    (Base.atan, VML.atan, VML.atan!, (-50, 50)),
    (Base.cos, VML.cos, VML.cos!, (-1000, 1000)),
    (Base.sin, VML.sin, VML.sin!, (-1000, 1000)),
    (Base.tan, VML.tan, VML.tan!, (-1000, 1000)),
    (Base.acosh, VML.acosh, VML.acosh!, (1, 1000)),
    (Base.asinh, VML.asinh, VML.asinh!, (-1000, 1000)),
    (Base.atanh, VML.atanh, VML.atanh!, (-1, 1)),
    (Base.cosh, VML.cosh, VML.cosh!, (0, 89.415985f0)),
    (Base.sinh, VML.sinh, VML.sinh!, (-89.415985f0, 89.415985f0)),
    (Base.tanh, VML.tanh, VML.tanh!, (-8.66434f0, 8.66434f0)),
    (Base.cbrt, VML.cbrt, VML.cbrt!, (-1000, 1000)),
    (Base.sqrt, VML.sqrt, VML.sqrt!, (0, 1000)),
    (Base.exp, VML.exp, VML.exp!, (-88.72284f0, 88.72284f0)),
    (Base.expm1, VML.expm1, VML.expm1!, (-88.72284f0, 88.72284f0)),
    (Base.log, VML.log, VML.log!, (0, 1000)),
    (Base.log10, VML.log10, VML.log10!, (0, 1000)),
    (Base.log1p, VML.log1p, VML.log1p!, (-1, 1000)),
    (Base.abs, VML.abs, VML.abs!, (-1000, 1000)),
    (Base.abs2, VML.abs2, VML.abs2!, (-1000, 1000)),
    (Base.ceil, VML.ceil, VML.ceil!, (-1000, 1000)),
    (Base.floor, VML.floor, VML.floor!, (-1000, 1000)),
    (Base.round, VML.round, VML.round!, (-1000, 1000)),
    (Base.trunc, VML.trunc, VML.trunc!, (-1000, 1000)),
    (SpecialFunctions.erf, VML.erf, VML.erf!, (-3.8325067f0, 3.8325067f0)),
    (SpecialFunctions.erfc, VML.erfc, VML.erfc!, (-3.7439213f0, 10.019834f0)),
    (SpecialFunctions.erfinv, VML.erfinv, VML.erfinv!, (-1, 1)),
    (SpecialFunctions.erfcinv, VML.erfcinv, VML.erfcinv!, (0, 2)),
    (SpecialFunctions.lgamma, VML.lgamma, VML.lgamma!, (0, 1000)),
    (SpecialFunctions.gamma, VML.gamma, VML.gamma!, (0, 36))
)

const base_binary_real = (
#    (Base.atan2, VML.atan2, VML.atan2!, (-1, 1), (-1, 1)),
    (Base.hypot, VML.hypot, VML.hypot!, (-1000, 1000), (-1000, 1000)),
#    (getfield(Base, :/), VML.divide, VML.divide!, (-1000, 1000), (-1000, 1000)),
#    (getfield(Base, :^), VML.pow, VML.pow!, (0, 100), (-5, 20))
)

const base_unary_complex = (
    (Base.acos, VML.acos, VML.acos!, (-1, 1)),
    (Base.asin, VML.asin, VML.asin!, (-1, 1)),
    # (Base.atan, VML.atan, VML.atan!, (-50, 50)),
    # (Base.cos, VML.cos, VML.cos!, (-10, 10)),
    # (Base.sin, VML.sin, VML.sin!, (-10, 10)),
    # (Base.tan, VML.tan, VML.tan!, (-10, 10)),
    (Base.acosh, VML.acosh, VML.acosh!, (1, 1000)),
    (Base.asinh, VML.asinh, VML.asinh!, (-1000, 1000)),
    # (Base.atanh, VML.atanh, VML.atanh!, (-1, 1)),
    # (Base.cosh, VML.cosh, VML.cosh!, (0, 89.415985f0)),
    # (Base.sinh, VML.sinh, VML.sinh!, (-89.415985f0, 89.415985f0)),
    # (Base.tanh, VML.tanh, VML.tanh!, (-8.66434f0, 8.66434f0)),
    (Base.sqrt, VML.sqrt, VML.sqrt!, (0, 1000)),
    (Base.exp, VML.exp, VML.exp!, (-88.72284f0, 88.72284f0)),
    (Base.log, VML.log, VML.log!, (0, 1000)),
    # (Base.log10, VML.log10, VML.log10!, (0, 1000)),
    (Base.abs, VML.abs, VML.abs!, (-1000, 1000)),
    (Base.angle, VML.angle, VML.angle!, (-1000, 1000))
    # (Base.conj, VML.conj, VML.conj!, (-1000, 1000))
)

const base_binary_complex = (
    # (getfield(Base, :/), VML.divide, VML.divide!, (-1000, 1000), (-1000, 1000)),
    # (getfield(Base,:^, VML.pow, VML.pow!, (0, 100), (-2, 10))
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
