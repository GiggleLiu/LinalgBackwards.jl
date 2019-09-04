using Test
using BackwardsLinalg
using Random, LinearAlgebra

@testset "svd grad U" begin
    function loss(A)
        M, N = size(A)
        U, S, V = svd(A)
        psi = U[:,1]
        Random.seed!(2)
        H = randn(ComplexF64, M, M)
        H+=H'
        real(psi'*H*psi)[]
    end

    for (M, N) in [(6, 3), (3, 6), (3,3)]
        K = min(M, N)
        a = randn(ComplexF64, M, N)
        @test gradient_check(loss, a)
    end
end

@testset "svd grad V" begin
    function loss_v(A)
        M, N = size(A)
        U, S, V = svd(A)
        Random.seed!(2)
        H = randn(ComplexF64, N, N)
        H+=H'
        psi = V[:,1]
        real(psi'*H*psi)[]
    end

    for (M, N) in [(6, 3), (3, 6), (3,3)]
        K = min(M, N)
        a = randn(ComplexF64, M,N)
        @show loss_v(a)
        @test gradient_check(loss_v, a)
    end
end

@testset "svd grad U,V" begin
    function loss_uv(A)
        M, N = size(A)
        U, S, V = svd(A)
        psi = V[1,1]
        psi_l = U[1,1]
        real(conj(psi_l)*psi)[]
    end

    for (M, N) in [(6, 3), (3, 6), (3,3)]
        K = min(M, N)
        a = randn(ComplexF64, M,N)
        @show loss_uv(a)
        @test gradient_check(loss_uv, a)
    end
end

@testset "svd grad U,V imag diag" begin
    function loss_uv(A)
        M, N = size(A)
        U, S, V = svd(A)
        psi = V[1,1]
        psi_l = U[1,1]
        real(conj(psi_l)*psi)[]
    end

    A = [-1+1im 2+1im;1-2im 3+0.8im]
    @show loss_uv(A)
    da = [0 0; 1 0im]
    ndiff = (loss_uv(A .+ 1e-4*da) - loss_uv(A .- 1e-4*da)) ./ 2e-4 + im*(loss_uv(A .+ 1e-4im*da) - loss_uv(A .- 1e-4im*da)) ./ 2e-4
    grad = loss_uv'(A)
    @show grad[2,1], ndiff
    @test gradient_check(loss_uv, A)
    @test isapprox(grad[2,1], ndiff, atol=1e-3)
    end
end

@testset "svd grad S" begin
    function loss(A)
        U, S, V = svd(A)
        S |> sum
    end

    for (M, N) in [(6, 3), (3, 6), (3,3)]
        K = min(M, N)
        H1 = randn(ComplexF64, M, M)
        H1 += H1'
        a = randn(ComplexF64, M, N)
        @test gradient_check(loss, a)
    end
end

@testset "rsvd" begin
    for shape in [(100, 30), (30, 30), (30, 100)]
        A = randn(ComplexF64, shape...)
        U, S, V = rsvd(A, 30)
        @test U*Diagonal(S)*V' ≈ A
    end

    A = randn(100, 30) * randn(30, 70)
    U, S, V = rsvd(A, 30)
    @test U*Diagonal(S)*V' ≈ A
end

@testset "rsvd grad U" begin
    function loss(A)
        M, N = size(A)
        U, S, V = rsvd(A)
        psi = U[:,1]
        Random.seed!(2)
        H = randn(ComplexF64, M, M)
        H+=H'
        real(psi'*H*psi)[]
    end

    for (M, N) in [(6, 3), (3, 6), (3,3)]
        K = min(M, N)
        a = randn(ComplexF64, M, N)
        @test gradient_check(loss, a)
    end
end


@testset "rsvd grad V" begin
    function loss_v(A)
        M, N = size(A)
        U, S, V = rsvd(A)
        Random.seed!(2)
        H = randn(ComplexF64, N, N)
        H+=H'
        psi = V[:,1]
        real(psi'*H*psi)[]
    end

    for (M, N) in [(6, 3), (3, 6), (3,3)]
        K = min(M, N)
        a = randn(ComplexF64, M,N)
        @test gradient_check(loss_v, a)
    end
end

@testset "rsvd grad S" begin
    function loss(A)
        U, S, V = rsvd(A)
        S |> sum
    end

    for (M, N) in [(6, 3), (3, 6), (3,3)]
        K = min(M, N)
        H1 = randn(ComplexF64, M, M)
        H1 += H1'
        a = randn(ComplexF64, M, N)
        @test gradient_check(loss, a)
    end
end
