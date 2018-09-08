module ComplexTests
using SpecialFunctions, Test
import ..TestStuff:base_unary_complex, base_binary_complex, randindomain
using VML

# First generate some random data and test functions in Base on it
const NVALS = 1000
input = Dict(t=>[[(randindomain(t, NVALS, domain),) for (fn, vfn, vfn!, domain) in base_unary_complex];
             [(randindomain(t, NVALS, domain1), randindomain(t, NVALS, domain2))
              for (fn, vfn, vnf!, domain1, domain2) in base_binary_complex];
             (randindomain(t, NVALS, (0, 100)), randindomain(t, 1, (-2, 10))[1])]
            for t in (ComplexF32, ComplexF64))
fns = [[x[1] for x in base_unary_complex]; [x[1] for x in base_binary_complex]; ^]
vfns = [[x[2] for x in base_unary_complex]; [x[2] for x in base_binary_complex]; v_pow]
output = Dict(t=>[fns[i].(input[t][i]...) for i = 1:length(fns)] for t in (ComplexF32, ComplexF64))

@info "Baseline values loaded."

@testset "complex" begin
# Now test the same data with VML
for t in (ComplexF32, ComplexF64)
  @testset "$(string(t))" begin
  for i = 1:length(fns)
    fn = vfns[i]
    @testset "$(string(fn))" begin
        @test fn(input[t][i]...) ≈ output[t][i]
    end
    # Base.Test.test_approx_eq(output[t][i], fn(input[t][i]...), "Base $t $fn", "VML $t $fn")
  end
  end
end
end
end
