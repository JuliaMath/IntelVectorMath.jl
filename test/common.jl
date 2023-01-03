# unary functions that accept floats as inputs
const base_unary_real = (
    (Base, :acos, (-1, 1)),
    (Main, :acospi, (-1, 1)),
    (Base, :asin, (-1, 1)),
    (Main, :asinpi, (-1, 1)),
    (Base, :atan, (-50, 50)),
    (Main, :atanpi, (-50, 50)),
    (Base, :cos, (-1000, 1000)),
    (Base, :cosd, (-10000, 10000)),
    (Base, :cospi, (-300, 300)),
    (Base, :sin, (-1000, 1000)),
    (Base, :sind, (-10000, 10000)),
    (Base, :sinpi, (-300, 300)),
    (Base, :tan, (-1000, 1000)),
    (Base, :tand, (-10000, 10000)),
    (Main, :tanpi, (-300, 300)),
    (Base, :acosh, (1, 1000)),
    (Base, :asinh, (-1000, 1000)),
    (Base, :atanh, (-1, 1)),
    (Base, :cosh, (0, 89.415985f0)),
    (Base, :sinh, (-89.415985f0, 89.415985f0)),
    (Base, :tanh, (-8.66434f0, 8.66434f0)),
    (Base, :cbrt, (-1000, 1000)),
    (Base, :sqrt, (0, 1000)),
    (Base, :exp, (-88.72284f0, 88.72284f0)),
    (Base, :expm1, (-88.72284f0, 88.72284f0)),
    (Base, :log, (0, 1000)),
    (Base, :log2, (0, 1000)),
    (Base, :log10, (0, 1000)),
    (Base, :log1p, (-1, 1000)),
    (Base, :abs, (-1000, 1000)),
    (Base, :abs2, (-1000, 1000)),
    (Base, :ceil, (-1000, 1000)),
    (Base, :floor, (-1000, 1000)),
    (Base, :round, (-1000, 1000)),
    (Base, :trunc, (-1000, 1000)),
    (Base, :cis, (-1000, 1000)),
    (SpecialFunctions, :erf, (-3.8325067f0, 3.8325067f0)),
    (SpecialFunctions, :erfc, (-3.7439213f0, 10.019834f0)),
    (SpecialFunctions, :erfinv, (-1, 1)),
    (SpecialFunctions, :erfcinv, (0, 2)),
    (SpecialFunctions, :lgamma, (0, 1000)),
    (SpecialFunctions, :gamma, (0, 36)),
    (Main, :inv_sqrt, (0, 1000)),
    (Main, :inv_cbrt, (0, 1000)),
    (Main, :pow2o3, (-1000, 1000)),
    (Main, :pow3o2, (0, 1000)),
)

const base_binary_real = (
    (Base, :atan, (-1, 1), (-1, 1)),
    (Base, :hypot, (-1000, 1000), (-1000, 1000)),
    (Main, :divide, (-1000, 1000), (-1000, 1000)),
    (Main, :pow, (0, 100), (-5, 20)),
    (Main, :atanpi, (-1, 1), (-1, 1)),
    # (getfield(Base, :./), (-1000, 1000), (-1000, 1000)),
    # (getfield(Base, :.^), (0, 100), (-5, 20))
)

const base_unary_complex = (
    (Base, :acos, (-1, 1)),
    (Base, :asin, (-1, 1)),
    (Base, :acosh, (1, 1000)),
    (Base, :asinh, (-1000, 1000)),
    (Base, :sqrt, (0, 1000)),
    (Base, :exp, (-88.72284f0, 88.72284f0)),
    (Base, :log, (0, 1000)),
    (Base, :abs, (-1000, 1000)),
    (Base, :angle, (-1000, 1000)),
    (Base, :conj, (-1000, 1000)),
    # (atan, (-50, 50)),
    # (cos, (-10, 10)),
    # (sin, (-10, 10)),
    # (tan, (-10, 10)),
    # (atanh, (-1, 1)),
    # (cosh, (0, 89.415985f0)),
    # (sinh, (-89.415985f0, 89.415985f0)),
    # (tanh, (-8.66434f0, 8.66434f0)),
    # (log10, (0, 1000)),
    # (cis, (-1000, 1000))
)

const base_binary_complex = (
    (Main, :divide, (-1000, 1000), (-1000, 1000)),
    (Main, :pow, (0, 100), (-2, 10)),
)

@testset "Check completeness of tests" begin
    @testset "Unary real input" begin
        have_test_domains = getfield.(base_unary_real, 2)
        # :cis is a special case
        defined_functions = (getfield.(IVM.unary_real, 1)..., getfield.(IVM.unary_real_complex, 1)..., :cis)

        @test isempty(symdiff(have_test_domains, defined_functions))
    end

    @testset "Binary real input" begin
        have_test_domains = getfield.(base_binary_real, 2)
        defined_functions = (getfield.(IVM.binary_real, 1)..., getfield.(IVM.binary_real_complex, 1)...)
        @test isempty(symdiff(have_test_domains, defined_functions))
    end

    @testset "Unary complex input" begin
        have_test_domains = getfield.(base_unary_complex, 2)
        defined_functions = (getfield.(IVM.unary_complex_in, 1)..., getfield.(IVM.unary_complex_inout, 1)..., getfield.(IVM.unary_real_complex, 1)...)
        @test isempty(symdiff(have_test_domains, defined_functions))
    end

    @testset "Binary complex input" begin
        have_test_domains = getfield.(base_binary_complex, 2)
        defined_functions = getfield.(IVM.binary_real_complex, 1)
        @test isempty(symdiff(have_test_domains, defined_functions))
    end

end

function randindomain(t::Type{T}, n, domain) where {T<:Real}
    d1 = convert(t, domain[1])
    d2 = convert(t, domain[2])
    ddiff = d2 - d1
    @assert isfinite(ddiff)
    return rand(t, n) .* ddiff .+ d1
end

function randindomain(t::Type{T}, n, domain) where {T<:Complex}
    d1 = convert(t, domain[1])
    d2 = convert(t, domain[2])
    ddiff = d2 - d1
    @assert isfinite(ddiff)
    return rand(t, 2 * n) .* ddiff .+ d1
end
