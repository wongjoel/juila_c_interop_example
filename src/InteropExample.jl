
#= 
Code for c interop, see the tests for more comprehensive use
=#

module InteropExample
using Logging
import Libdl
import Parquet
import DataFrames
import Dates
import TimeZones

# To set Log Level to debug, you set an environment variable: JULIA_DEBUG=InteropExample
# ENV["JULIA_DEBUG"] = "InteropExample"
# ----------------------------------------------------------------------

function pandas_ms_dt_to_zoneddatetime(pandas_ms_dt)
    TimeZones.ZonedDateTime((Dates.Microsecond(pandas_ms_dt) + Dates.DateTime(1970)), TimeZones.tz"UTC")
end

function parse_as_utc10dt(pandas_ms_dt)
    TimeZones.astimezone(pandas_ms_dt_to_zoneddatetime(pandas_ms_dt), TimeZones.tz"UTC+10")
end

struct DummyFunctions
    dummy_inc::Function
    dummy_vec_inc::Function
    dummy_make_struct::Function
    dummy_use_struct::Function
end

"""
Set up the library functions with nicer wrappers by capturing the library symbols in closures
"""
function DummyFunctions(lib::Ptr{Nothing})
    dummy_delete_struct_internal = (d) -> dummy_delete_struct(Libdl.dlsym(lib, :dummy_delete_struct), d)
    dummy_make_struct_internal = function(f,v1,v2)
        s = dummy_make_struct(Libdl.dlsym(lib, :dummy_make_struct), v1, v2)
        try
            f(s)
        finally
            dummy_delete_struct_internal(s)
        end
    end
    DummyFunctions(
        (x) -> dummy_inc(Libdl.dlsym(lib, :dummy_inc), x),
        (x) -> dummy_vec_inc(Libdl.dlsym(lib, :dummy_vec_inc), x),
        dummy_make_struct_internal,
        (d,v1,v2) -> dummy_use_struct(Libdl.dlsym(lib, :dummy_use_struct), d, v1, v2),
    )
end

struct inner_struct
    inner_val1::Cint
    inner_val2::Cint
end

struct dummy_struct
    val1::Cint
    val2::Cint
    val3::Cint
    arr_val1::NTuple{2, Cint}
    arr_val2::NTuple{2, Cint}
    inner::inner_struct
    variable_array::Cvoid # Variable Length Array using a zero-size type
end

"""
Load the library and pass it in to the given function (use the `do` keyword)
    Closes the library when done
"""
function DummyFunctions(f::Function, lib_path::AbstractString)
    lib = Libdl.dlopen(lib_path)
    try
        funcs = DummyFunctions(lib)
        f(funcs)
    finally
        Libdl.dlclose(lib)
    end
end

function dummy_inc(lib_sym::Ptr{Nothing}, x::Integer)
    ccall(lib_sym, Cint, (Cint, ), x)
end

function dummy_vec_inc(lib_sym::Ptr{Nothing}, x::Vector{Cfloat})
    ccall(lib_sym, Cint, (Ptr{Cfloat}, Cint), x, size(x, 1))
end

function dummy_make_struct(lib_sym::Ptr{Nothing}, val1::Integer, val2::Integer)
    ccall(lib_sym, Ptr{dummy_struct}, (Cint, Cint), val1, val2)
end

function dummy_use_struct(lib_sym::Ptr{Nothing}, d::Ptr{dummy_struct}, val1::Integer, val2::Integer)
    ccall(lib_sym, Cvoid, (Ptr{dummy_struct}, Cint, Cint), d, val1, val2)
end

function dummy_delete_struct(lib_sym::Ptr{Nothing}, d::Ptr{dummy_struct})
    ccall(lib_sym, Cvoid, (Ptr{Nothing}, ), d)
end


function main()
    lib_path = normpath(joinpath(@__DIR__, "..", "builddir", "src", "dummy", "libdummy.so"))
    DummyFunctions(lib_path) do c_funcs
        @info("---------------- Testing Parquet ----------------")
        parquet_path = normpath(joinpath(@__DIR__, "..", "data", "2023-02-10T10-00-00.parquet"))
        df = DataFrames.DataFrame(Parquet.read_parquet(parquet_path))
        @debug("propertynames(df) = $(propertynames(df))")
        @debug("df[1:5, :CH1_V1] = $(df[1:5, :CH1_V1])")

        @debug("df[1:5, :] = $(df[1:5, :])")

        df_parsed_dt = DataFrames.transform(df, "timestamp_utc+10" => DataFrames.ByRow(x -> parse_as_utc10dt(x)) => :parsed)
        @debug("df_parsed_dt[1:5, :parsed] = $(df_parsed_dt[1:5, :parsed])")

        @info("---------------- Testing Parquet with C Function ----------------")
        in_data = convert(Array{Cfloat}, df[1:5, :CH1_V1])
        @debug("in_data = $in_data")
        y = c_funcs.dummy_vec_inc(in_data)
        @debug("in_data = $in_data")
        @debug("y = $y")
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    @debug("Starting")
    main()
end

end # module InteropExample
