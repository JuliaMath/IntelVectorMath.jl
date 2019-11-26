# First generate some random data and test functions in Base on it
const NVALS = 1000

input = Dict(
    t=>[
        [ (randindomain(t, NVALS, domain),) for (_, _, domain) in base_unary_real ];
        [ (randindomain(t, NVALS, domain1), randindomain(t, NVALS, domain2))
            for (_, _, domain1, domain2) in base_binary_real ]
    ]
    for t in (Float32, Float64)
)

fns = [[x[1:2] for x in base_unary_real]; [x[1:2] for x in base_binary_real]]

# output = Dict(t=>[fns[i](input[t][i]...) for i = 1:length(fns)] for t in (Float32, Float64))

@testset "Definitions and Comparison with Base for Reals" begin

  for t in (Float32, Float64), i = 1:length(fns)

    base_fn = eval(:($(fns[i][1]).$(fns[i][2]))) 
    vml_fn = eval(:(VML.$(fns[i][2])))
    # vml_fn! = eval(:(VML.$(fns[i][2])!))

    Test.@test which(vml_fn, typeof(input[t][i])).module == VML

    # Test.test_approx_eq(output[t][i], fn(input[t][i]...), "Base $t $fn", "VML $t $fn")
    Test.@test vml_fn(input[t][i]...) ≈ base_fn.(input[t][i]...)

  end

end

@testset "Error Handling and Settings" begin

  # Verify that we still throw DomainErrors
  Test.@test_throws DomainError VML.sqrt([-1.0])
  Test.@test_throws DomainError VML.log([-1.0])

  # Setting accuracy
  vml_set_accuracy(VML_LA)
  Test.@test vml_get_accuracy() == VML_LA

  vml_set_accuracy(VML_EP)
  Test.@test vml_get_accuracy() == VML_EP

end

@testset "@overload macro" begin

    @test VML.exp([1.0]) ≈ exp.([1.0])
    @test_throws MethodError Base.exp([1.0])
    @test (@overload log exp) isa String
    @test Base.exp([1.0]) ≈ exp.([1.0])

    @test_throws MethodError Base.atan([1.0], [2.0])
    @test (@overload atan) isa String
    @test Base.atan([1.0], [2.0]) ≈ atan.([1.0], [2.0])

end
