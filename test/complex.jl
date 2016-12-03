# First generate some random data and test functions in Base on it
const NVALS = 1000
input = Dict(t=>[[(randindomain(t, NVALS, domain),) for (fn, domain) in base_unary_complex];
             [(randindomain(t, NVALS, domain1), randindomain(t, NVALS, domain2))
              for (fn, domain1, domain2) in base_binary_complex];
             (randindomain(t, NVALS, (0, 100)), randindomain(t, 1, (-2, 10))[1])]
            for t in (Complex64, Complex128))
fns = [[x[1] for x in base_unary_complex]; [x[1] for x in base_binary_complex]; .^]
output = Dict(t=>[fns[i](input[t][i]...) for i = 1:length(fns)] for t in (Complex64, Complex128))

# Now test the same data with VML
using VML
for t in (Complex64, Complex128), i = 1:length(fns)
    fn = fns[i]
    Base.Test.test_approx_eq(output[t][i], fn(input[t][i]...), "Base $t $fn", "VML $t $fn")
end
