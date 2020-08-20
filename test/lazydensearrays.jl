using LinearAlgebra

@testset "lazy_dense_array" begin
    A = randn(100)
    B = IVM.sin(A)
    A′ = @view A[:,1]
    B′ = IVM.sin(A′)
    @test B == B′
    A′ = @views reshape(A[:],20,5)
    B′ = reshape(IVM.sin(A′),size(B))
    @test B == B′

    @test_throws ArgumentError IVM.sin(view(A,1:2:100))
end
