const base_unary = (
    (Base.acos, (-1, 1)),
    (Base.asin, (-1, 1)),
    # (Base.atan, (-50, 50)),
    # (Base.cos, (-10, 10)),
    # (Base.sin, (-10, 10)),
    # (Base.tan, (-10, 10)),
    (Base.acosh, (1, 1000)),
    (Base.asinh, (-1000, 1000)),
    # (Base.atanh, (-1, 1)),
    # (Base.cosh, (0, 89.415985f0)),
    # (Base.sinh, (-89.415985f0, 89.415985f0)),
    # (Base.tanh, (-8.66434f0, 8.66434f0)),
    (Base.sqrt, (0, 1000)),
    (Base.exp, (-88.72284f0, 88.72284f0)),
    (Base.log, (0, 1000)),
    # (Base.log10, (0, 1000)),
    (Base.abs, (-1000, 1000)),
    (Base.angle, (-1000, 1000))
    # (Base.conj, (-1000, 1000))
)

const base_binary = (
    (Base.(:./), (-1000, 1000), (-1000, 1000)),
    # (Base.(:.^), (0, 100), (-2, 10))
)

function randindomain{T<:Real}(t::Type{Complex{T}}, n, domain)
    d1 = convert(t, domain[1])
    d2 = convert(t, domain[2])
    ddiff = d2 - d1
    @assert isfinite(ddiff)
    v = rand(T, 2 * n)
    for i = 1:length(v)
        v[i] = v[i] * ddiff + d1
    end
    reinterpret(t, v)
end

const datatypes = (Complex64, Complex128)

include("common.jl")
