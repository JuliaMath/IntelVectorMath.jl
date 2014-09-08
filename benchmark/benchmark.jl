using Distributions, PyCall, PyPlot
@pyimport matplotlib.gridspec as gridspec

include(joinpath(dirname(dirname(@__FILE__)), "test", "common.jl"))
complex = !isempty(ARGS) && ARGS[1] == "complex"

function bench(fns, input)
    [t=>begin
        times = Array(Vector{Float64}, length(fns))
        for ifn = 1:length(fns)
            fn = fns[ifn]
            inp = input[t][ifn]
            fn(inp...)
            gc()
            nrep = max(iceil(2/(@elapsed (gc_disable(); fn(inp...); gc_enable(); gc()))), 3)
            println("Running $nrep reps of $fn($t)")
            @time times[ifn] = [begin
                gc()
                gc_disable()
                time = @elapsed fn(inp...)
                gc_enable()
                time
            end for i = 1:nrep]
            # println((mean(times[ifn]), std(times[ifn])))
        end
        times
    end for t in types]
end

function ratioci(y, x, alpha=0.05)
    tq² = abs2(quantile(TDist(length(x) + length(y) - 2), alpha))
    μx = mean(x)
    σx² = varm(x, μx)
    μy = mean(y)
    σy² = varm(y, μy)
    a = sqrt((μx*μy)^2 - (μx^2 - tq²*σx²)*(μy^2 - tq²*σy²))
    b = μx^2 - tq²*σx²
    (((μx*μy) - a)/b, ((μx*μy) + a)/b)
end

# First generate some random data and test functions in Base on it
const NVALS = 1_000_000
base_unary = complex ? base_unary_complex : base_unary_real
base_binary = complex ? base_binary_complex : base_binary_real
types = complex ? (Complex64, Complex128) : (Float32, Float64)
input = [t=>[[(randindomain(t, NVALS, domain),) for (fn, domain) in base_unary];
             [(randindomain(t, NVALS, domain1), randindomain(t, NVALS, domain2))
              for (fn, domain1, domain2) in base_binary];
             (randindomain(t, NVALS, (0, 100)), randindomain(t, 1, (-1, 20))[1])]
            for t in types]
fns = [[x[1] for x in base_unary]; [x[1] for x in base_binary]; (complex ? [] : .^)]

builtin = bench(fns, input)

# Now with VML
using VML

vml = bench(fns, input)

# Print ratio
clf()
colors = ["r", "y"]
for itype = 1:length(types)
    builtint = builtin[types[itype]]
    vmlt = vml[types[itype]]
    μ = vec(map(mean, builtint)./map(mean, vmlt))
    ci = zeros(Float64, 2, length(fns))
    for ifn = 1:length(builtint)
        lower, upper = ratioci(builtint[ifn], vmlt[ifn])
        ci[1, ifn] = μ[ifn] - lower
        ci[2, ifn] = upper - μ[ifn]
    end
    bar(0.2+(0.4*itype):length(fns), μ, 0.4, yerr=ci, color=colors[itype], ecolor="k")
end
ax = gca()
ax[:set_xlim](0, length(fns)+1)
fname = [string(fn.env.name) for fn in fns]
if !complex
    fname[end-1] = "A.^B"
    fname[end] = "A.^b"
end
xticks(1:length(fns)+1, fname, rotation=70, fontsize=10)
title("VML Performance")
ylabel("Relative Speed (Base/VML)")
legend([string(x) for x in types])
ax[:axhline](1; color="black", linestyle="--")
savefig("performance$(complex ? "_complex" : "").png")
