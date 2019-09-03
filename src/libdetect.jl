using CpuId
using Libdl


### First Option, MKL.jl install
if !(Base.find_package("MKL") === nothing)
    basepath = joinpath(dirname(Base.find_package("MKL")), "../deps/usr/lib")
    println("Found MKL.jl package
    basepath set to $basepath")
    # TODO check whether files are actually there (in case of build error)

## TODO: standard install (mac, linux)

### if nothing else, look into ENV
elseif haskey(ENV, "MKL_SL")
    basepath = ENV["MKL_SL"]
    if !any([occursin("libmkl_rt",x) for x in readdir(basepath)])
        error(""" ENV["MKL_SL"] is set, but does not point to folder containing MKL files """)
    end
    println("""Found MKL via ENV["MKL_SL"]
    basepath set to $basepath""")

else
    error("Could not find VML shared libraries
        Check github.com/.... for details on obtaining them")

end


if cpufeature(:AVX2)
    const lib = joinpath(basepath, "libmkl_vml_avx2")
    println("AVX2 support detected, vml_avx2 selected")
else
    const lib = joinpath(basepath, "libmkl_vml_avx")
    println("AVX2 support missing, vml_avx selected")
end

const rtlib = joinpath(basepath, "libmkl_rt")
const corelib = joinpath(basepath, "libmkl_core")


Libdl.dlopen(rtlib, RTLD_GLOBAL)

ccall((:_vmlGetMode, lib), Cuint, ())


