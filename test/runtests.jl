
#= 
When a package is tested the file test/runtests.jl is executed
Test with the `test` command in the pkg repl (use ] to enter)
=#
using InteropExample
using Test

@testset "Test InteropExample module" begin
    @testset "Ensure Tests Work" begin
        @test true
        @test π ≈ 3.14 atol=0.01
    end
    include("test_c_interop.jl")
end