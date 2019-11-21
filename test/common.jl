using SpecialFunctions
const base_unary_real = (
    (acos, (-1, 1)),
    (asin, (-1, 1)),
    (atan, (-50, 50)),
    (cos, (-1000, 1000)),
    (sin, (-1000, 1000)),
    (tan, (-1000, 1000)),
    (acosh, (1, 1000)),
    (asinh, (-1000, 1000)),
    (atanh, (-1, 1)),
    (cosh, (0, 89.415985f0)),
    (sinh, (-89.415985f0, 89.415985f0)),
    (tanh, (-8.66434f0, 8.66434f0)),
    (cbrt, (-1000, 1000)),
    (sqrt, (0, 1000)),
    (exp, (-88.72284f0, 88.72284f0)),
    (expm1, (-88.72284f0, 88.72284f0)),
    (log, (0, 1000)),
    (log10, (0, 1000)),
    (log1p, (-1, 1000)),
    (abs, (-1000, 1000)),
    (abs2, (-1000, 1000)),
    (ceil, (-1000, 1000)),
    (floor, (-1000, 1000)),
    (round, (-1000, 1000)),
    (trunc, (-1000, 1000)),
    (erf, (-3.8325067f0, 3.8325067f0)),
    (erfc, (-3.7439213f0, 10.019834f0)),
    (erfinv, (-1, 1)),
    (erfcinv, (0, 2)),
    (lgamma, (0, 1000)),
    (gamma, (0, 36))
)

const base_binary_real = (
    (atan, (-1, 1), (-1, 1)),
    (hypot, (-1000, 1000), (-1000, 1000)),
    # (getfield(Base, :./), (-1000, 1000), (-1000, 1000)),
    # (getfield(Base, :.^), (0, 100), (-5, 20))
)

const base_unary_complex = (
    (acos, (-1, 1)),
    (asin, (-1, 1)),
    # (atan, (-50, 50)),
    # (cos, (-10, 10)),
    # (sin, (-10, 10)),
    # (tan, (-10, 10)),
    (acosh, (1, 1000)),
    (asinh, (-1000, 1000)),
    # (atanh, (-1, 1)),
    # (cosh, (0, 89.415985f0)),
    # (sinh, (-89.415985f0, 89.415985f0)),
    # (tanh, (-8.66434f0, 8.66434f0)),
    (sqrt, (0, 1000)),
    (exp, (-88.72284f0, 88.72284f0)),
    (log, (0, 1000)),
    # (log10, (0, 1000)),
    (abs, (-1000, 1000)),
    (angle, (-1000, 1000)),
    (conj, (-1000, 1000)),
    # (cis, (-1000, 1000))
)

# const base_binary_complex = (
#     # (getfield(Base, :./), (-1000, 1000), (-1000, 1000)),
#     # ((:.^), (0, 100), (-2, 10))
# )

function randindomain(t::Type{T}, n, domain) where {T<:Real}
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

function randindomain(t::Type{T}, n, domain) where {T<:Complex}
    d1 = convert(t, domain[1])
    d2 = convert(t, domain[2])
    ddiff = d2 - d1
    @assert isfinite(ddiff)
    v = rand(t, 2*n)
    for i = 1:length(v)
        v[i] = v[i]*ddiff+d1
    end
    v
    # reinterpret(t, v)
end
