# First generate some random data and test functions in Base on it
const NVALS_complex = 1000

const input_complex = Dict(
    t=>[ (randindomain(t, NVALS_complex, domain),) for (_, _, domain) in base_unary_complex ]
        for t in (ComplexF32, ComplexF64)
)

const fns_complex = [x[1:2] for x in base_unary_complex]

# output = Dict(
#     t=>[ fns[i](input[t][i]...) for i = 1:length(fns) ]
#         for t in (ComplexF32, ComplexF64)
# )

@testset "Definitions and Comparison with Base for Complex" begin
  for t in (ComplexF32, ComplexF64), i = 1:length(fns_complex)
    inp = input_complex[t][i]
    mod, fn = fns_complex[i]
    base_fn = getproperty(mod, fn)
    vml_fn = getproperty(IntelVectorMath, fn)
    vml_fn! = getproperty(IntelVectorMath, Symbol(fn, "!"))

    Test.@test parentmodule(vml_fn) == IntelVectorMath

    # Test.test_approx_eq(output[t][i], fn(input[t][i]...), "Base $t $fn", "IntelVectorMath $t $fn")
    baseres = base_fn.(inp...)
    Test.@test vml_fn(inp...) ≈ base_fn.(inp...)

    if inp == 1
      if fn != :abs && fn != :angle
        vml_fn!(inp[1])
        Test.@test inp[1] ≈ baseres
      end
    elseif length(inp) == 2
      out = similar(inp[1])
      vml_fn!(out, inp...)
      Test.@test out ≈ baseres
    end

  end

end
