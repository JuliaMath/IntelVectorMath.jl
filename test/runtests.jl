include("common.jl")

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

vml_set_accuracy(VML_LA)
@assert vml_get_accuracy() == VML_LA
vml_set_accuracy(VML_EP)
@assert vml_get_accuracy() == VML_EP
