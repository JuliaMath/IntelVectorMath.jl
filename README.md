# VML

This package provides bindings to the Intel Vector Math Library for
arithmetic and transcendental functions. It is often substantially
faster than using Julia's built-in functions.

## Using VML.jl

To use VML.jl, you must have the Intel Vector Math Library installed.
This is included in [MKL](http://software.intel.com/en-us/intel-mkl),
which is free for non-commercial use. You must also copy/symlink the
appropriate shared library to a directory known to the linker (e.g.
`/usr/local/lib`) or you must add the location to the `DL_LOAD_PATH`
array.

Currently, VML.jl is configured to use `libmkl_vml_avx2`, which
requires AVX2 support. If your system does not have AVX2, or you wish
to take advantage of AVX512 enhancements, you will need to modify the
`const lib` declaration at the top of `src/VML.jl`. Future versions of
VML.jl may automatically detect CPU architecture.

An earlier version of this package replaced vector methods of some Base
functions with VML calls. That is not done in this version, since it
does not fit into the current broadcasting framework. Exported methods
should not conflict with Base methods.

By default, VML uses `VML_HA` mode, which corresponds to an accuracy of
<1 ulp, matching the accuracy of Julia's built-in openlibm
implementation, although the exact results may be different. To specify
low accuracy, use `vml_set_accuracy(VML_LA)`. To specify enhanced
performance, use `vml_set_accuracy(VML_EP)`. More documentation
regarding these options is available on
[Intel's website](http://software.intel.com/sites/products/documentation/hpc/mkl/vml/vmldata.htm).

## Performance

![VML Performance Comparison](/benchmark/performance.png)

![VML Complex Performance Comparison](/benchmark/performance_complex.png)

Tests were performed on an Intel(R) Xeon(TM) E5-2630 CPU. Error bars
are 95% confidence intervals based on 2-second repetitions of each test with
a 1,000,000 element vector. The dashed line indicates equivalent
performance for VML versus the implementations in Base. Both Base and
VML use only a single core when performing these benchmarks.
The Base methods were run in the pre-allocated `out .= f.(A)` form, and
the `f!(out, A)` mutating versions of VML wrappers were used.

## Supported functions

VML.jl supports the following functions, currently for Float32 and
Float64 only. While VML also offers operators for complex numbers,
only a few are implemented in VML.jl: `acos, asin, acosh, asinh, sqrt, exp,
log, pow, divide, cis, abs, angle`.

### Unary functions

Allocating forms have signature `v_f(A)`. Mutating forms have signatures
`f!(A)` (in place) and `f!(out, A)` (out of place).

Allocating   | Mutating
-------------|---------
`v_acos`     | `acos!`
`v_asin`     | `asin!`
`v_atan`     | `atan!`
`v_cos`      | `cos!`
`v_sin`      | `sin!`
`v_tan`      | `tan!`
`v_acosh`    | `acosh!`
`v_asinh`    | `asinh!`
`v_atanh`    | `atanh!`
`v_cosh`     | `cosh!`
`v_sinh`     | `sinh!`
`v_tanh`     | `tanh!`
`v_cbrt`     | `cbrt!`
`v_sqrt`     | `sqrt!`
`v_exp`      | `expm1!`
`v_log`      | `log!`
`v_log10`    | `log10!`
`v_log1p`    | `log1p!`
`v_abs`      | `abs!`
`v_abs2`     | `abs2!`
`v_ceil`     | `ceil!`
`v_floor`    | `floor!`
`v_round`    | `round!`
`v_trunc`    | `trunc!`
`v_erf`      | `erf!`
`v_erfc`     | `erfc!`
`v_erfinv`   | `erfinv!`
`v_efcinv`   | `efcinv!`
`v_inv_cbrt` | `inv_cbrt!`
`v_inv_sqrt` | `inv_sqrt!`
`v_pow2o3`   | `pow2o3!`
`v_pow3o2`   | `pow3o2!`

### Binary functions

Allocating forms have signature `v_f(A, B)`. Mutating forms have
signature `f!(out, A, B)`.

Allocating | Mutating
-----------|---------
`v_atan2`  | `atan2!`
`v_hypot`  | `hypot!`
`v_pow`    | `pow!`
`v_divide` | `divide!`
