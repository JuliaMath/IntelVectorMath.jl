# IntelVectorMath.jl (formerly VML.jl)
![](https://github.com/JuliaMath/VML.jl/workflows/julia%201.0/1.3/badge.svg)
![](https://github.com/JuliaMath/VML.jl/workflows/julia%20nightly/badge.svg)

This package provides bindings to the Intel MKL [Vector Mathematics Functions](https://software.intel.com/en-us/node/521751).
This is often substantially faster than broadcasting Julia's built-in functions, especially when applying a transcendental function over a large array. 
Until Julia 0.6 the package was registered as `VML.jl`.

Similar packages are [Yeppp.jl](https://github.com/JuliaMath/Yeppp.jl), which wraps the open source Yeppp library, and [AppleAccelerate.jl](https://github.com/JuliaMath/AppleAccelerate.jl), which provides access to macOS's Accelerate framework.

## Basic install

To use IntelVectorMath.jl, you must have the shared libraries of the Intel Vector Math Library available on your system.
The easiest option is to use [MKL.jl](https://github.com/JuliaComputing/MKL.jl) via
```julia
julia> ] add https://github.com/JuliaComputing/MKL.jl.git
```
Alternatively you can install MKL directly [from intel](https://software.intel.com/en-us/mkl/choose-download).

Note that intel MKL has a separate license, which you may want to check for commercial projects (see [FAQ]( https://software.intel.com/en-us/mkl/license-faq)).

To install IntelVectorMath.jl run
```julia
julia> ] add IntelVectorMath
```
If you used this package prior to its renaming, you may have to run `] rm VML` first. Otherwise there will be a conflict due to the UUID.  

## Using IntelVectorMath
After loading `IntelVectorMath`, you have the supported function listed below, for example `IntelVectorMath.sin(rand(100))`. These should provide a significant speed-up over broadcasting the Base functions.
Since the package name is quite long, an alias `IVM` is also exported to allow `IVM.sin(rand(100))` after `using` the package. 
If you `import` the package, you can add this alias via `const IVM = IntelVectorMath`. Equally, you can replace `IVM` with another alias of your choice. 

#### Example
```julia
julia> using IntelVectorMath, BenchmarkTools

julia> a = randn(10^4);

julia> @btime sin.($a);     # apply Base.sin to each element
  102.128 μs (2 allocations: 78.20 KiB)

julia> @btime IVM.sin($a);  # apply IVM.sin to the whole array
  20.900 μs (2 allocations: 78.20 KiB)

julia> b = similar(a);

julia> @btime IVM.sin!(b, a);  # in-place version
  20.008 μs (0 allocations: 0 bytes)
```

Most Julia functions do not automatically apply to all elements of an array, thus `sin(a)` gives a MethodError.  If you would like to extend the Base function with this functionality, you can add methods to them with the `@overload` macro:
```julia
julia> @overload sin cos tan;

julia> @btime sin($a);
  20.944 μs (2 allocations: 78.20 KiB)

julia> ans ≈ sin.(a)
true
```
Calling `sin` on an array now calls the a IntelVectorMath function, while its action on scalars is unchanged.

#### Note:

Some Julia functions like `exp` and `log` do operate on matrices, and refer to the [matrix exponential](https://en.wikipedia.org/wiki/Matrix_exponential) and logarithm. Using `@overload exp` will overwrite this behaviour with element-wise exponentiation/ logarithm.
```julia
julia> exp(ones(2,2))
2×2 Array{Float64,2}:
 4.19453  3.19453
 3.19453  4.19453

 julia> IVM.exp(ones(2,2))
2×2 Array{Float64,2}:
 2.71828  2.71828
 2.71828  2.71828

julia> ans == exp.(ones(2,2))
true
```
If your code, or any code you call, uses matrix exponentiation, then `@overload exp` may silently lead to incorrect results. This caution applies to all trigonometric functions, too, since they have matrix forms defined by matrix exponentials.

### Accuracy

By default, IntelVectorMath uses `VML_HA` mode, which corresponds to an accuracy of
<1 ulp, matching the accuracy of Julia's built-in openlibm
implementation, although the exact results may be different. To specify
low accuracy, use `vml_set_accuracy(VML_LA)`. To specify enhanced
performance, use `vml_set_accuracy(VML_EP)`. More documentation
regarding these options is available on
[Intel's website](http://software.intel.com/sites/products/documentation/hpc/mkl/IntelVectorMath/vmldata.htm).

## Performance
(These results are currently outdated and will be updated in due course)
![IntelVectorMath Performance Comparison](/benchmark/performance.png)

![IntelVectorMath Complex Performance Comparison](/benchmark/performance_complex.png)

Tests were performed on an Intel(R) Core(TM) i7-3930K CPU. Error bars
are 95% confidence intervals based on 25 repetitions of each test with
a 1,000,000 element vector. The dashed line indicates equivalent
performance for IntelVectorMath versus the implementations in Base. Both Base and
IntelVectorMath use only a single core when performing these benchmarks.

## Supported functions

IntelVectorMath.jl supports the following functions, most for Float32 and
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
* [x] Travis and AppVeyor testing
* [x] Adding CIS function
* [x] Move Testing to GitHub Actions 
* [x] Add test for using standalone MKL
* [ ] Update Benchmarks
* [ ] Add tests for mutating functions



## Advanced
IntelVectorMath.jl works via Libdl which loads the relevant shared libraries. Libdl automatically finds the relevant libraries if the location of the binaries has been added to the system search paths.
This already taken care of if you use MKL.jl, but the stand-alone may require you to source `mklvars.sh` in the shell you are opening the REPL in. The default command on Mac and Ubuntu is `source /opt/intel/mkl/bin/mklvars.sh intel64`. You may want to add this to your `.bashrc`.
Adding a new `*.conf` file in `/etc/ld.so.conf.d` also works, as the `intel-mkl-slim` package in the AUR does automatically.

Further, IntelVectorMath.jl uses [CpuId.jl](https://github.com/m-j-w/CpuId.jl) to detect if your processor supports the newer `avx2` instructions, and if not defaults to `libmkl_vml_avx`. If your system does not have AVX this package will currently not work for you.
If the CPU feature detection does not work for you, please open an issue.
