# First generate some random data and test functions in Base on it
const NVALS = 1000

input = Dict(
    t=>[ (randindomain(t, NVALS, domain),) for (_, _, domain) in base_unary_complex ]
        for t in (ComplexF32, ComplexF64)
)

fns = [x[1:2] for x in base_unary_complex]

# output = Dict(
#     t=>[ fns[i](input[t][i]...) for i = 1:length(fns) ]
#         for t in (ComplexF32, ComplexF64)
# )

@testset "Definitions and Comparison with Base for Complex" begin

  for t in (ComplexF32, ComplexF64), i = 1:length(fns)

    base_fn = eval(:($(fns[i][1]).$(fns[i][2]))) 
    vml_fn = eval(:(VML.$(fns[i][2])))

    Test.@test which(vml_fn, typeof(input[t][i])).module == VML

    # Test.test_approx_eq(output[t][i], fn(input[t][i]...), "Base $t $fn", "VML $t $fn")
    Test.@test vml_fn(input[t][i]...) ≈ base_fn.(input[t][i]...)

  end

end
