using Distributions, PyCall, PyPlot
@pyimport matplotlib.gridspec as gridspec

include(joinpath(dirname(dirname(@__FILE__)), "test", "common.jl"))

function bench(fns, input, nrep)
    [t=>begin
        times = Array(Float64, nrep, length(fns))
        for ifn = 1:length(fns)
            fn = fns[ifn]
            inp = input[t][ifn]
            for irep = 1:nrep
                gc_disable()
                times[irep, ifn] = @elapsed fn(inp...)
                gc_enable()
            end
            gc()
        end
        times
    end for t in (Float32, Float64)]
end

function ratioci(y, x, alpha=0.05)
    tq2 = abs2(quantile(TDist(length(x) + length(y) - 2), alpha))
    μx = mean(x)
    σx2 = varm(x, μx)
    μy = mean(y)
    σy2 = varm(y, μy)
    a = sqrt((μx*μy)^2 - (μx^2 - tq2*σx2)*(μy^2 - tq2*σy2))
    b = μx^2 - tq2*σx2
    (((μx*μy) - a)/b, ((μx*μy) + a)/b)
end

# First generate some random data and test functions in Base on it
const NVALS = 1000000
input = [t=>[[(randindomain(t, NVALS, domain),) for (fn, domain) in base_unary];
             [(randindomain(t, NVALS, domain1), randindomain(t, NVALS, domain2))
              for (fn, domain1, domain2) in base_binary]]
            for t in (Float32, Float64)]
fns = [[x[1] for x in base_unary]; [x[1] for x in base_binary]]

bench(fns, input, 1)
builtin = bench(fns, input, 10)

# Now with VML
using VML
#vml_set_accuracy(VML_LA)

bench(fns, input, 1)
vml = bench(fns, input, 10)

# Print ratio
clf()
types = (Float32, Float64)
colors = ["r", "y"]
for itype = 1:length(types)
    builtint = builtin[types[itype]]
    vmlt = vml[types[itype]]
    μ = vec(mean(builtint, 1)./mean(vmlt, 1))
    ci = zeros(Float64, 2, length(fns))
    for ifn = 1:size(builtint, 2)
        lower, upper = ratioci(builtint[:, ifn], vmlt[:, ifn])
        ci[1, ifn] = μ[ifn] - lower
        ci[2, ifn] = upper - μ[ifn]
    end
    bar(0.2+(0.4*itype):length(fns), μ, 0.4, yerr=ci, color=colors[itype], ecolor="k")
end
ax = gca()
ax[:set_xlim](0, length(fns)+1)
xticks(1:length(fns), [string(fn.env.name) for fn in fns], rotation=70, fontsize=10)
title("VML Performance")
ylabel("Relative Speed (Base/VML)")
legend(("Float32", "Float64"))
ax[:axhline](1; color="black", linestyle="--")
savefig("performance.png")
