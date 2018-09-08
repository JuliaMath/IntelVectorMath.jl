module RealTests
using SpecialFunctions, Test
import ..TestStuff:base_unary_real, base_binary_real, randindomain
using VML

# First generate some random data and test functions in Base on it
const NVALS = 1000
input = Dict(t=>[[(randindomain(t, NVALS, domain),) for (fn, vfn, vfn!, domain) in base_unary_real];
             [(randindomain(t, NVALS, domain1), randindomain(t, NVALS, domain2))
              for (fn, vfn, vfn!, domain1, domain2) in base_binary_real];
             (randindomain(t, NVALS, (0, 100)), randindomain(t, 1, (-5, 20))[1])]
            for t in (Float32, Float64))
fns = [[x[1] for x in base_unary_real]; [x[1] for x in base_binary_real]; ^]
vfns = [[x[2] for x in base_unary_real]; [x[2] for x in base_binary_real]; v_pow]
output = Dict(t=>[fns[i].(input[t][i]...) for i = 1:length(fns)] for t in (Float32, Float64))

@info "Baseline values loaded."

# Now test the same data with VML
@testset "real" begin
for t in (Float32, Float64)
  @testset "$(string(t))" begin
  for i = 1:length(fns)
    fn = vfns[i]
    @testset "$(string(fn))" begin
        @test fn(input[t][i]...) ≈ output[t][i]
    end
    # test_approx_eq(output[t][i], fn(input[t][i]...), "Base $t $fn", "VML $t $fn")
  end
  end
end
end

@testset "real domainerrors" begin
# Verify that we still throw DomainErrors
    @test_throws DomainError v_sqrt([-1.0])
end

@testset "set/get accuracy" begin
# Setting accuracy
vml_set_accuracy(VML_LA)
@test vml_get_accuracy() == VML_LA
vml_set_accuracy(VML_EP)
@test vml_get_accuracy() == VML_EP
end

end
