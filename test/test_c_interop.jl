using InteropExample
using Test
using Logging

function test_int_variables(c_funcs)
    x::Int32 = 1
    y::Int32 = c_funcs.dummy_inc(x)
    @test y == (x + 1)
end

function test_float_array(c_funcs)
    x_list::Array{Cfloat} = convert(Array{Cfloat}, [1, 2, 3, 4, 5])
    y = c_funcs.dummy_vec_inc(x_list)
    @debug("x_list = $x_list")
    @debug("y = $y")
    @test x_list ≈ [2, 3, 4, 5, 6] atol=0.1
    @test y == size(x_list, 1)
end

function test_struct(c_funcs)
    v1::Cint = 6
    v2::Cint = 8
    c_funcs.dummy_make_struct(v1, v2) do d
        d_loaded = unsafe_load(d)
        loaded_variable_arr = unsafe_wrap(Array, Ptr{Cint}(d) + sizeof(InteropExample.dummy_struct), 2)
        @test d_loaded.val1 == v1
        @test d_loaded.val2 == v2
        @test d_loaded.val3 == 0
        @test d_loaded.arr_val1 == (10, 11)
        @test d_loaded.arr_val2 == (20, 21)
        @test d_loaded.inner.inner_val1 == 100
        @test d_loaded.inner.inner_val2 == 200
        @test loaded_variable_arr == [30, 31]

        x::Cint = 2
        c_funcs.dummy_use_struct(d, x, x)

        d_loaded = unsafe_load(d)
        loaded_variable_arr = unsafe_wrap(Array, Ptr{Cint}(d) + sizeof(InteropExample.dummy_struct), 2)
        @test d_loaded.val1 == v1+x
        @test d_loaded.val2 == v2*x
        @test d_loaded.val3 == 0+1
        @test d_loaded.arr_val1 == map(x -> x+1, (10, 11))
        @test d_loaded.arr_val2 == map(x -> x+2, (20, 21))
        @test d_loaded.inner.inner_val1 == 100
        @test d_loaded.inner.inner_val2 == 200
        @test loaded_variable_arr == [30, 31]
    end
end

@testset "Ensure C Interop works as expected" begin
    lib_path = normpath(joinpath(@__DIR__, "..", "builddir", "src", "dummy", "libdummy.so"))
    @test isfile(lib_path)
    InteropExample.DummyFunctions(lib_path) do c_funcs
        test_int_variables(c_funcs)
        test_float_array(c_funcs)
        test_struct(c_funcs)
    end
end