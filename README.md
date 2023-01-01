# IntelVectorMath.jl (formerly VML.jl)

[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/IntelVectorMath.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html

[![PkgEval][pkgeval-img]][pkgeval-url]
![](https://github.com/JuliaMath/VML.jl/workflows/julia%201.6/badge.svg)
![](https://github.com/JuliaMath/VML.jl/workflows/julia%20nightly/badge.svg)

This package provides bindings to the Intel MKL [Vector Mathematics Functions](https://www.intel.com/content/www/us/en/develop/documentation/onemkl-developer-reference-c/top/vector-mathematical-functions.html).
This is often substantially faster than broadcasting Julia's built-in functions, especially when applying a transcendental function over a large array.
Until Julia 0.6 the package was registered as `VML.jl`.

Similar packages are [Yeppp.jl](https://github.com/JuliaMath/Yeppp.jl), which wraps the open-source Yeppp library, and [AppleAccelerate.jl](https://github.com/JuliaMath/AppleAccelerate.jl), which provides access to macOS's Accelerate framework.

### Warning for macOS
There is currently [the following](https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/700) issue between the `CompilerSupportLibraries_jll` artifact, which is used for example by `SpecialFunctions.jl`, and `MKL_jll`. Unless `MKL_jll` is loaded first, there might be wrong results coming from a small number of function for particular input array lengths. If you are unsure which, if any, your used packages might load this artifact, loading `IntelVectorMath` as the very first package should be fine. 

## Basic install

To install IntelVectorMath.jl run
```julia
julia> ] add IntelVectorMath
```
Since version 0.4 `IntelVectorMath` uses the `MKL_jll` artifact, which is shared with other packages uses MKL, removing several other dependencies. This has the side effect that from version 0.4 onwards this package requires at least Julia 1.3. 

For older versions of Julia `IntelVectorMath v0.3` downloads its own version of MKL and keeps only the required files in its own directory. As such installing MKL.jl or MKL via intel are no longer required, and may mean some duplicate files if they are present. However, this package will adopt the new artifact system in the next minor version update and fix this issue. 
In the event that MKL was not installed properly you will get an error when first `using` it. Please try running 
```julia
julia> ] build IntelVectorMath
```
If this does not work, please open an issue and include the output of `<packagedir>/deps/build.log`.

#### Renaming from VML
If you used this package prior to its renaming, you may have to run `] rm VML` first. Otherwise, there will be a conflict due to the UUID.  

## Using IntelVectorMath
After loading `IntelVectorMath`, you have the supported function listed below, for example `IntelVectorMath.sin(rand(100))`. These should provide a significant speed-up over broadcasting the Base functions.
As the package name is quite long, the alias `IVM` is also exported to allow `IVM.sin(rand(100))` after `using` the package.
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

### Accuracy

By default, IntelVectorMath uses `VML_HA` mode, which corresponds to an accuracy of
<1 ulp, matching the accuracy of Julia's built-in openlibm
implementation, although the exact results may be different. To specify
low accuracy, use `vml_set_accuracy(VML_LA)`. To specify enhanced
performance, use `vml_set_accuracy(VML_EP)`. More documentation
regarding these options is available on
[Intel's website](https://www.intel.com/content/www/us/en/develop/documentation/onemkl-developer-reference-c/top/vector-mathematical-functions.html).

### Denormalized numbers 

On some CPU, operations on denormalized numbers are extremely slow. You case use `vml_set_denormalmode(VML_DENORMAL_FAST)`
to handle denormalized numbers as zero. See the `?VML_DENORMAL_FAST` for more information. You can get the
current mode by `vml_get_denormalmode()`. The default is `VML_DENORMAL_ACCURATE`.

### Threads

By default, IntelVectorMath uses multithreading. The maximum number of threads that a call may use
is given by `vml_get_max_threads()`. On most environment this will default to the number of physical
cores available to IntelVectorMath. This behavior can be changed using `vml_set_num_threads(numthreads)`.

## Performance
Summary of Results:

**Relative speed of IntelVectorMath/Base:** The height of the bars is how fast IntelVectorMath is compared to using broadcasting for functions in Base

![IntelVectorMath Performance Comparison](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set6-relative.png)

![IntelVectorMath Complex Performance Comparison](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Complex/bar/bench-dims-set6-relative.png)


Full Results:

<details>
  <summary>Real Functions - Full Benchmark Results</summary>

  ![Dimension set 1](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set1-relative.png)
  ![Dimension set 2](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set2-relative.png)
  ![Dimension set 3](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set3-relative.png)
  ![Dimension set 4](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set4-relative.png)
  ![Dimension set 5](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set5-relative.png)
  ![Dimension set 6](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set6-relative.png)
  ![Dimension set 7](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set7-relative.png)
  ![Dimension set 8](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set8-relative.png)
  ![Dimension set 9](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set9-relative.png)
  ![Dimension set 10](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set10-relative.png)

</details>

<details>
  <summary>Complex Functions - Full Benchmark Results</summary>

  ![Dimension set 1](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Complex/bar/bench-dims-set1-relative.png)
  ![Dimension set 2](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Complex/bar/bench-dims-set2-relative.png)
  ![Dimension set 3](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Complex/bar/bench-dims-set3-relative.png)
  ![Dimension set 4](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Complex/bar/bench-dims-set4-relative.png)
  ![Dimension set 5](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Complex/bar/bench-dims-set5-relative.png)
  ![Dimension set 6](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Complex/bar/bench-dims-set6-relative.png)
  ![Dimension set 7](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Complex/bar/bench-dims-set7-relative.png)
  ![Dimension set 8](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Complex/bar/bench-dims-set8-relative.png)
  ![Dimension set 9](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Complex/bar/bench-dims-set9-relative.png)
  ![Dimension set 10](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Complex/bar/bench-dims-set10-relative.png)

</details>

<details>
  <summary>Real Functions - Performance over dimensions</summary>

  ![abs](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-abs-Type-Float64.png)
  ![abs2](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-abs2-Type-Float64.png)
  ![acos](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-acos-Type-Float64.png)
  ![acosh](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-acosh-Type-Float64.png)
  ![asin](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-asin-Type-Float64.png)
  ![asinh](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-asinh-Type-Float64.png)
  ![atan](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-atan-Type-Float64.png)
  ![atanh](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-atanh-Type-Float64.png)
  ![cbrt](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-cbrt-Type-Float64.png)
  ![ceil](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-ceil-Type-Float64.png)
  ![cis](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-cis-Type-Float64.png)
  ![cos](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-cos-Type-Float64.png)
  ![cosh](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-cosh-Type-Float64.png)
  ![erf](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-erf-Type-Float64.png)
  ![erfc](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-erfc-Type-Float64.png)
  ![erfcinv](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-erfcinv-Type-Float64.png)
  ![erfcinv](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-erfcinv-Type-Float64.png)
  ![exp](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-exp-Type-Float64.png)
  ![expm1](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-expm1-Type-Float64.png)
  ![floor](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-floor-Type-Float64.png)
  ![gamma](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-gamma-Type-Float64.png)
  ![hypot](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-hypot-Type-Float64.png)
  ![log](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-log-Type-Float64.png)
  ![round](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-round-Type-Float64.png)
  ![sin](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-sin-Type-Float64.png)
  ![sinh](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-sinh-Type-Float64.png)
  ![sqrt](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-sqrt-Type-Float64.png)
  ![tan](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-tan-Type-Float64.png)
  ![tanh](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-tanh-Type-Float64.png)
  ![trunc](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/dimplot/bench-trunc-Type-Float64.png)

</details>

<br/>

Tests were performed on an Intel(R) Core(TM) i5-8250U @ 1.6 [GHz] 1800 Mhz. The dashed line indicates equivalent performance for IntelVectorMath versus the implementations in Base.

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

Allocating forms have signature `f(A, B)`. Mutating forms have the
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
* [x] Update Benchmarks
* [x] Add tests for mutating functions
* [x] Add own dependency management via BinaryProvider
* [ ] Update function list in README
* [x] Adopt Julia 1.3 artifact system, breaking backwards compatibility



## Advanced

<!-- This does not seems to be true anymore ? No reference to CpuId.jl in the Manifest ?

IntelVectorMath.jl uses [CpuId.jl](https://github.com/m-j-w/CpuId.jl) to detect if your processor supports the newer `avx2` instructions, and if not defaults to `libmkl_vml_avx`. If your system does not have AVX this package will currently not work for you.
If the CPU feature detection does not work for you, please open an issue. -->

As a quick help to convert benchmark timings into operations-per-cycle, IntelVectorMath.jl
provides `vml_get_cpu_frequency()` which will return the *actual* current frequency of the
CPU in GHz.
