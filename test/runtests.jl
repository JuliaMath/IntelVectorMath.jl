const base_unary = ((Base.acos, (-1, 1)),
                    (Base.asin, (-1, 1)),
                    (Base.atan, (-50, 50)),
                    (Base.cos, (-Inf, Inf)),
                    (Base.sin, (-Inf, Inf)),
                    (Base.tan, (-Inf, Inf)),
                    (Base.acosh, (1, Inf)),
                    (Base.asinh, (-Inf, Inf)),
                    (Base.cosh, (0, 89.415985f0)),
                    (Base.sinh, (-89.415985f0, 89.415985f0)),
                    (Base.tanh, (-8.66434f0, 8.66434f0)),
                    (Base.cbrt, (-Inf, Inf)),
                    (Base.sqrt, (0, Inf)),
                    (Base.exp, (-88.72284f0, 88.72284f0)),
                    (Base.expm1, (-88.72284f0, 88.72284f0)),
                    (Base.log, (0, Inf)),
                    (Base.log10, (0, Inf)),
                    (Base.log1p, (-1, Inf)),
                    (Base.abs, (-Inf, Inf)),
                    (Base.abs2, (-Inf, Inf)),
                    (Base.ceil, (-Inf, Inf)),
                    (Base.floor, (-Inf, Inf)),
                    (Base.round, (-Inf, Inf)),
                    (Base.trunc, (-Inf, Inf)),
                    (Base.erf, (-3.8325067f0, 3.8325067f0)),
                    (Base.erfc, (-3.7439213f0, 10.019834f0)),
                    (Base.erfinv, (-1, 1)),
                    (Base.erfcinv, (0, 2)),
                    (Base.lgamma, (0, 1f37)),
                    (Base.gamma, (0, 36)))

const base_binary = ((Base.atan2, (-1, 1), (-1, 1)),
                     (Base.hypot, (-Inf, Inf), (-Inf, Inf)),
                     (Base.(:.^), (0, 100), (-0.8590604f0, 19.265919f0)),
                     (Base.(:.+), (-Inf, Inf), (-Inf, Inf)),
                     (Base.(:./), (-Inf, Inf), (-Inf, Inf)),
                     (Base.(:.*), (-1.8446743f19, 1.8446743f19), (-1.8446743f19, 1.8446743f19)),
                     (Base.(:.-), (-Inf, Inf), (-Inf, Inf)))

fixinf(t, x) = oftype(t, ifelse(x == -Inf, nextfloat(typemin(t))/2,
                                ifelse(x == Inf, prevfloat(typemax(t))/2, x)))
function randindomain(t, n, domain)
    d1 = fixinf(t, domain[1])
    d2 = fixinf(t, domain[2])
    ddiff = d2 - d1
    @assert isfinite(ddiff)
    v = rand(t, n)
    for i = 1:length(v)
        v[i] = v[i]*ddiff+d1
    end
    v
end

# First generate some random data and test functions in Base on it
const NVALS = 1000
input = [t=>[[(randindomain(t, NVALS, domain),) for (fn, domain) in base_unary];
             [(randindomain(t, NVALS, domain1), randindomain(t, NVALS, domain2))
              for (fn, domain1, domain2) in base_binary]]
            for t in (Float32, Float64)]
fns = [[x[1] for x in base_unary]; [x[1] for x in base_binary]]
output = [t=>[fns[i](input[t][i]...) for i = 1:length(fns)] for t in (Float32, Float64)]

# Now test the same data with VML
using VML
for t in (Float32, Float64), i = 1:length(fns)
    fn = fns[i]
    Base.Test.test_approx_eq(output[t][i], fn(input[t][i]...), "Base $t $fn", "VML $t $fn")
end
