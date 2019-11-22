# VML 
[![Build Status](https://travis-ci.com/Crown421/VML.jl.svg?branch=master)](https://travis-ci.com/Crown421/VML.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/btdduqfsxux8fhsr?svg=true)](https://ci.appveyor.com/project/Crown421/vml-jl)

This package provides bindings to the Intel Vector Math Library for
arithmetic and transcendental functions. Especially for large vectors it is often substantially faster than broadcasting Julia's built-in functions.

## Basic install

To use VML.jl, you must have the shared libraries of the Intel Vector Math Library avilable on your system.
The easiest option is to use [MKL.jl](https://github.com/JuliaComputing/MKL.jl) via 
```
julia> ] add https://github.com/JuliaComputing/MKL.jl.git
```
Alternatively you can install MKL directly [from intel](https://software.intel.com/en-us/mkl/choose-download).

Note that intel MKL has a separate license, which you may want to check for commercial projects (see [FAQ]( https://software.intel.com/en-us/mkl/license-faq)).

To install VML.jl run 
```
julia> ] add https://github.com/Crown421/VML.jl
```

## Using VML
After loading `VML`, you have the supported function listed below available to call, i.e. `VML.sin(rand(100))`. This should provide a significant speed-up over broadcasting the Base functions.
```
julia> using VML
julia> a = rand(10000);
julia>@time  sin.(a);                 
0.159878 seconds (583.25 k allocations: 30.720 MiB, 2.78% gc time)
julia> @time VML.sin(a);                                                                                
0.000465 seconds (6 allocations: 781.484 KiB) 
```

Most function do currently (julia 1.x) not have a vectorized form, meaning that i.e. `sin(rand(10))` will not work.  If you would like to extend the Base function with this functionality you can overload them with the `@overload` macro:
```
julia> @overload sin
julia> @time sin(a);                                                                                
0.000485 seconds (6 allocations: 781.484 KiB) 
```
Note the lack of the broadcasting dot`.` Now calling i.e. `sin` with an array as input will call the VML functions. 

#### Note:
Some functions like `exp` and `log` do operate on matrices from Base and refer to the [matrix exponential](https://en.wikipedia.org/wiki/Matrix_exponential) and logarithm. Using `@overload exp` will overwrite this behaviour with element-wise exponentiation/ logarithm. 
```
julia> exp([1 1; 1 1.0])
2×2 Array{Float64,2}:
 4.19453  3.19453
 3.19453  4.19453

julia> VML.exp([1 1; 1 1.0])
2×2 Array{Float64,2}:
 2.71828  2.71828
 2.71828  2.71828
```

### Accuracy

By default, VML uses `VML_HA` mode, which corresponds to an accuracy of
<1 ulp, matching the accuracy of Julia's built-in openlibm
implementation, although the exact results may be different. To specify
low accuracy, use `vml_set_accuracy(VML_LA)`. To specify enhanced
performance, use `vml_set_accuracy(VML_EP)`. More documentation
regarding these options is available on
[Intel's website](http://software.intel.com/sites/products/documentation/hpc/mkl/vml/vmldata.htm).

## Performance
(These results are currently outdated and will be updated in due course)
![VML Performance Comparison](/benchmark/performance.png)

![VML Complex Performance Comparison](/benchmark/performance_complex.png)

Tests were performed on an Intel(R) Core(TM) i7-3930K CPU. Error bars
are 95% confidence intervals based on 25 repetitions of each test with
a 1,000,000 element vector. The dashed line indicates equivalent
performance for VML versus the implementations in Base. Both Base and
VML use only a single core when performing these benchmarks.

## Supported functions

VML.jl supports the following functions, most for Float32 and
Float64, while some also take complex numbers.

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
signature `f!(out, A, B)`. 

Allocating | Mutating
-----------|---------
`atan`    | `atan!`
`hypot`    | `hypot!`
`pow`       | `pow!`
`divide`       | `divide!`


## Next steps
Next steps for this package 
* [x] Windows support
* [x] Basic Testing
* [x] Avoiding overloading base and optional overload function
* [ ] Updating Benchmarks
* [x] Travis and AppVeyor testing
* [x] Adding CIS function
* [ ] Add tests for mutating functions



## Advanced 
VML.jl works via Libdl which loads the relevant shared libraries. Libdl automatically finds the relevant libraries if the location of the binaries has been added to the system search paths. 
This already taken care of if you use MKL.jl, but the stand-alone may require you to source `mklvars.sh`. The default command on Mac and Ubuntu is `source /opt/intel/mkl/bin/mklvars.sh intel64`. You may want to add this to your `.bashrc`. 
Adding a new `*.conf` file in `/etc/ld.so.conf.d` also works, as the `intel-mkl-slim` package in the AUR does automatically. 

Further, VML.jl uses [CpuId.jl](https://github.com/m-j-w/CpuId.jl) to detect if your processor supports the newer `avx2` instructions, and if not defaults to `libmkl_vml_avx`. If your system does not have AVX this package will currently not work for you.
If the CPU feature detection does not work for you, please open an issue. 
