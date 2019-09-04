# VML

This package provides bindings to the Intel Vector Math Library for
arithmetic and transcendental functions. Especially for large vectors it is often substantially faster than broadcasting Julia's built-in functions.

## Setting up VML.jl

To use VML.jl, you must have the Intel Vector Math Library installed.
For this you have two options. First, you can install (and build) [MKL.jl](https://github.com/JuliaComputing/MKL.jl), which will add the necessary libraries to your Julia install. This will change your Julia system image however, so if you would prefer not to do that you can get the stand-alone [MKL](http://software.intel.com/en-us/intel-mkl),
which is free for non-commercial use. The default install location will be detected automatically (currently only `opt/intel/mkl/lib` on Unix). If you have chosen a different location or have multiple versions of MKL, you can also specify the environmental variable 
```
    ENV["MKL_SL"] = <.../lib>
```
The specified folder should contain `libmkl_rt`, `libmkl_core` and `libmkl_vml_avx` or `libmkl_vml_avx2`, with file endings appropriate for your operating system. 
The definition of `ENV["MKL_SL"]` will take precedence even if `MKL.jl` or default standalone MKL are installed. 

Using [CpuId.jl](https://github.com/m-j-w/CpuId.jl), VML.jl detects if your processor supports the newer `avx2` instructions, and if not default to `libmkl_vml_avx`. If your system does not have AVX this package will currently not work for you.

If the CPU feature detection does not work for you, please open an issue. 

## Using VML.jl

After loading VML.jl, vector calls to functions listed below will
automatically use VML instead of openlibm when possible. Note that most function currently do not have a vectorized version (e.g. you call `sin.(rand(300))`), so there should be no conflict. If there is let me know. Updated and conflict tested exported functions are planned for the future.

By default, VML uses `VML_HA` mode, which corresponds to an accuracy of
<1 ulp, matching the accuracy of Julia's built-in openlibm
implementation, although the exact results may be different. To specify
low accuracy, use `vml_set_accuracy(VML_LA)`. To specify enhanced
performance, use `vml_set_accuracy(VML_EP)`. More documentation
regarding these options is available on
[Intel's website](http://software.intel.com/sites/products/documentation/hpc/mkl/vml/vmldata.htm).

## Performance
(These results are currently outdated will be updated in due course)
![VML Performance Comparison](/benchmark/performance.png)

![VML Complex Performance Comparison](/benchmark/performance_complex.png)

Tests were performed on an Intel(R) Core(TM) i7-3930K CPU. Error bars
are 95% confidence intervals based on 25 repetitions of each test with
a 1,000,000 element vector. The dashed line indicates equivalent
performance for VML versus the implementations in Base. Both Base and
VML use only a single core when performing these benchmarks.

## Supported functions

VML.jl supports the following functions, currently for Float32 and
Float64 only. While VML also offers operators for complex numbers,
these are not yet implemented in VML.jl.

### Unary functions

Allocating forms have signature `f(A)`. Mutating forms have signatures
`f!(A)` (in place) and `f!(out, A)` (out of place). The last 9 functions have been moved from Base to `SpecialFunctions.jl` or have no Base equivalent. 

Allocating | Mutating
-----------|---------
`acos`     | `acos!`
`asin`     | `asin!`
`atan`     | `atan!`
`cos`      | `cos!`
`sin`      | `sin!`
`tan`      | `tan!`
`acosh`    | `acosh!`
`asinh`    | `asinh!`
`atanh`    | `atanh!`
`cosh`     | `cosh!`
`sinh`     | `sinh!`
`tanh`     | `tanh!`
`cbrt`     | `cbrt!`
`sqrt`     | `sqrt!`
`exp`      | `expm1!`
`log`      | `log!`
`log10`    | `log10!`
`log1p`    | `log1p!`
`abs`      | `abs!`
`abs2`     | `abs2!`
`ceil`     | `ceil!`
`floor`    | `floor!`
`round`    | `round!`
`trunc`    | `trunc!`
`erf`      | `erf!`
`erfc`     | `erfc!`
`erfinv`   | `erfinv!`
`efcinv`   | `efcinv!`
`gamma`    | `gamma!`
`lgamma`   | `lgamma!`
`inv_cbrt` | `inv_cbrt!`
`inv_sqrt` | `inv_sqrt!`
`pow2o3`   | `pow2o3!`
`pow3o2`   | `pow3o2!`

### Binary functions

Allocating forms have signature `f(A, B)`. Mutating forms have
signature `f!(out, A, B)`. These functions fall back on broadcasting
when

Allocating | Mutating
-----------|---------
`atan2`    | `atan2!`
`hypot`    | `hypot!`
`pow`       | `pow!`
`divide`       | `divide!`


### Next steps
Next steps for this package are proper Windows support, writing up proper testing to make sure each advertised function actually works as expected and build testing on travis.
