using VML
using Distributions, Statistics, BenchmarkTools # for benchmark
using Plots # for plotting
using JLD2, FileIO # to save file

cd(dirname(@__FILE__))
include(joinpath(dirname(dirname(@__FILE__)), "test", "common.jl"))

################################################################
complex = !isempty(ARGS) && ARGS[1] == "complex"
complex = false

# First generate some random data and test functions in Base on it
const NVALS = 10_000
base_unary = complex ? base_unary_complex : base_unary_real
base_binary = complex ? base_binary_complex : base_binary_real
types = complex ? (Complex64, Complex128) : (Float32, Float64)

# arrays of inputs are stored in a Tuple. So later for calling use inp... to get the content of the Tuple
input = Dict( t =>
[
 [(randindomain(t, NVALS, domain),) for (_, _, domain) in base_unary];
 [(randindomain(t, NVALS, domain1), randindomain(t, NVALS, domain2)) for (_, _, domain1, domain2) in base_binary];
 # (randindomain(t, NVALS, (0, 100)), randindomain(t, 1, (-1, 20))[1])
]
    for t in types)

fns = [[x[1:2] for x in base_unary_real];
       [x[1:2] for x in base_binary_real]]
################################################################

"""
    bench(fns, input)

benchmark function for VML.jl. Calls both Base and VML functions and stores the benchmarks in two nested Dict. First layer specifies type, and second layer specifies the function name. The result is a Tuple, 1st element being benchmark for Base/SpecialFunctions and 2nd element being for VML.

# Examples
```julia
fns = [(:Base, :acos); (:Base, :atan); (:SpecialFunctions, :ref)] # array of tuples
input = Dict( Float64 => [(rand(1000)); (rand(1000), rand(1000)); (rand(1000))]) # Dict of array of tuples
times = bench(fns, input)

times[Float64][:acos][1] # Base.acos benchmark for Float64
times[Float64][:acos][2] # VML.acos benchmark for Float64
```
"""
function bench(fns, input)
    Dict(t => begin
        Dict( fn[2] => begin
            base_fn = eval(:($(fn[1]).$(fn[2])))
            vml_fn = eval(:(VML.$(fn[2])))
            println("benchmarking $vml_fn for type $t")
            timesBase = @benchmark $base_fn.($inp...)
            timesVML = @benchmark $vml_fn($inp...)

            [timesBase, timesVML]
        end for (fn, inp) in zip(fns, input[t]) )
    end for t in types)
end
################################################################

# do benchmark
benches = bench(fns, input)

@save "benchmarkData.jld" benches
# @save "benchmarkData-complex.jld" benches

# benches = load("benchmarkData.jld2", "benches")


# something is wrong with these
deleteat!(fns, [18, 31])
delete!(benches[Float32], :lgamma)
delete!(benches[Float64], :lgamma)
delete!(benches[Float32], :log10)
delete!(benches[Float64], :log10)

################################################################

"""
benchmark analysis function
"""
function ratioci(y, x, alpha = 0.05)
    tq² = abs2(quantile(TDist(length(x) + length(y) - 2), alpha))
    μx = mean(x)
    σx² = varm(x, μx)
    μy = mean(y)
    σy² = varm(y, μy)
    a = sqrt((μx * μy)^2 - (μx^2 - tq² * σx²) * (μy^2 - tq² * σy²))
    b = μx^2 - tq² * σx²
    return (((μx * μy) - a) / b, ((μx * μy) + a) / b)
end

################################################################

"""
Does analysis of the benchmark data and plots them as bars.
"""
function plotBench()

# Print ratio
    colors = [:blue, :red]
    for itype = 1:length(types)

        # creating arrays of times from benchmarks
        benchVals = collect(values(benches[types[itype]]))
        builtint = [x[1].times for x in benchVals]
        vmlt = [x[2].times for x in benchVals]

        # calculating mean of run times
        μ = vec(map(mean, builtint) ./ map(mean, vmlt))

        # error bar disabled because benchmark tools takes care of errors

        # # calculating error bars
        # ci = zeros(Float64, 2, length(fns))
        # for ifn = 1:length(builtint)
        #     lower, upper = ratioci(builtint[ifn], vmlt[ifn])
        #     ci[1, ifn] = μ[ifn] - lower
        #     ci[2, ifn] = upper - μ[ifn]
        # end

        # adding bar
        plt = bar!(
            0.2+(0.4*itype):length(fns),
            μ,
            # yerror = ci,
            fillcolor = colors[itype],
            labels = [string(x) for x in types],
            dpi = 600
        )
    end
    fname = [string(fn[2]) for fn in fns]
    # if !complex
    #     fname[end-1] = "A.^B"
    #     fname[end] = "A.^b"
    # end
    xlims!(0, length(fns) + 1)
    xticks!(1:length(fns)+1, fname, rotation = 70, fontsize = 10)
    title!("VML Performance for array of size $NVALS")
    ylabel!("Relative Speed (VML/Base)")
    hline!([1], line=(4, :dash, 0.6, [:green]), labels = 1)
    savefig("performance$(complex ? "_complex" : "").png")

end

################################################################

# do plotting
plotBench()
