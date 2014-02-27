# VML

This package provides bindings to the Intel Vector Math Library for
arithmetic and transcendental functions. It is often substantially
faster than using Julia's built-in operations.

## Using VML.jl

Currently, VML.jl is configured to use `libmkl_vml_avx`, which requires
AVX support. If your system does not have AVX (e.g., most pre-Sandy
Bridge systems), you will need to modify the `const lib` declaration at
the top of `src/VML.jl`. Future versions of VML.jl may automatically
detect CPU architecture.

After loading VML.jl, vector calls to functions listed below will
automatically use VML instead of openlibm when possible.

By default, VML uses `VML_HA` mode, which corresponds to an accuracy of
<1 ulp. To specify low accuracy, use `vml_set_accuracy(VML_LA)`. To
specify enhanced performance, use `vml_set_accuracy(VML_EP)`. More
documentation regarding these options is available on
[Intel's website](http://software.intel.com/sites/products/documentation/hpc/mkl/vml/vmldata.htm).

## Supported functions

VML.jl supports the following functions, currently for Float32 and
Float64 only. While VML also implements operations on complex numbers,
these are not yet implemented in VML.jl.

### Unary functions

Allocating forms have signature `f(A)`. Mutating forms have signatures
`f!(A)` (in place) and `f!(out, A)` (out of place).

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
`.^`       | `pow!`
`.+`       | `add!`
`./`       | `divide!`
`.*`       | `multiply!`
`.-`       | `subtract!`

## Performance

![VML Performance Comparison](/benchmark/performance.png)

Tests were performed on an Intel(R) Core(TM) i7-3930K CPU. Error bars
are 95% confidence intervals based on 10 repetitions of each test with
a 1,000,000 element vector. The dashed line indicates equivalent
performance for VML versus the implementations in Base.
