# First generate some random data and test functions in Base on it
const NVALS = 1000

const input = Dict(
  t => [
    [(randindomain(t, NVALS, domain),) for (_, _, domain) in base_unary_real]
    [(randindomain(t, NVALS, domain1), randindomain(t, NVALS, domain2))
     for (_, _, domain1, domain2) in base_binary_real]
  ]
  for t in (Float32, Float64)
)

const fns = [[x[1:2] for x in base_unary_real]; [x[1:2] for x in base_binary_real]]

# output = Dict(t=>[fns[i](input[t][i]...) for i = 1:length(fns)] for t in (Float32, Float64))

@testset "Definitions and Comparison with Base for Reals" begin

  for t in (Float32, Float64), i = 1:length(fns)
    inp = input[t][i]
    mod, fn = fns[i]
    base_fn = getproperty(mod, fn)
    vml_fn = getproperty(IntelVectorMath, fn)
    vml_fn! = getproperty(IntelVectorMath, Symbol(fn, "!"))

    Test.@test parentmodule(vml_fn) == IntelVectorMath

    # Test.test_approx_eq(output[t][i], fn(input[t][i]...), "Base $t $fn", "IntelVectorMath $t $fn")
    baseres = base_fn.(inp...)
    Test.@test vml_fn(inp...) ≈ base_fn.(inp...)

    # cis changes type (float to complex, does not have mutating function)
    if length(inp) == 1
      if fn != :cis
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

@testset "Error Handling and Settings" begin

  # Verify that we still throw DomainErrors
  Test.@test_throws DomainError IntelVectorMath.sqrt([-1.0])
  Test.@test_throws DomainError IntelVectorMath.log([-1.0])

  # Setting accuracy
  vml_set_accuracy(VML_LA)
  Test.@test vml_get_accuracy() == VML_LA

  vml_set_accuracy(VML_EP)
  Test.@test vml_get_accuracy() == VML_EP

end
