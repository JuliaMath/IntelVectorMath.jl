# First generate some random data and test functions in Base on it
const NVALS = 1000
input = Dict(t=>[[(randindomain(t, NVALS, domain),) for (fn, domain) in base_unary_real];
             [(randindomain(t, NVALS, domain1), randindomain(t, NVALS, domain2))
              for (fn, domain1, domain2) in base_binary_real];
             (randindomain(t, NVALS, (0, 100)), randindomain(t, 1, (-5, 20))[1])]
            for t in (Float32, Float64))
fns = [[x[1] for x in base_unary_real]; [x[1] for x in base_binary_real]; .^]
output = Dict(t=>[fns[i](input[t][i]...) for i = 1:length(fns)] for t in (Float32, Float64))

# Now test the same data with VML
using VML
for t in (Float32, Float64), i = 1:length(fns)
    fn = fns[i]
    Base.Test.test_approx_eq(output[t][i], fn(input[t][i]...), "Base $t $fn", "VML $t $fn")
end

# Verify that we still throw DomainErrors
Base.Test.@test_throws DomainError sqrt([-1.0])

# Setting accuracy
vml_set_accuracy(VML_LA)
@assert vml_get_accuracy() == VML_LA
vml_set_accuracy(VML_EP)
@assert vml_get_accuracy() == VML_EP
