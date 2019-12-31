using IntelVectorMath
using AcuteBenchmark
################################################################
# Dimensions
oneArgDims = [10]

twoArgDims = [10; # arg1
              10] # arg2

################################################################
## Real Functions

typesReal=[Float32, Float64]

configsRealBase = FunbArray([
    # oneArgDims
    Funb(acos, [(-1, 1)], typesReal, oneArgDims),
    Funb(asin, [(-1, 1)], typesReal, oneArgDims),
    Funb(atan, [(-50, 50)], typesReal, oneArgDims),
    Funb(cos, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(sin, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(tan, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(acosh, [(1, 1000)], typesReal, oneArgDims),
    Funb(asinh, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(atanh, [(-1, 1)], typesReal, oneArgDims),
    Funb(cosh, [(0, 89.415985f0)], typesReal, oneArgDims),
    Funb(sinh, [(-89.415985f0, 89.415985f0)], typesReal, oneArgDims),
    Funb(tanh, [(-8.66434f0, 8.66434f0)], typesReal, oneArgDims),
    Funb(cbrt, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(sqrt, [(0, 1000)], typesReal, oneArgDims),
    Funb(exp, [(-88.72284f0, 88.72284f0)], typesReal, oneArgDims),
    Funb(expm1, [(-88.72284f0, 88.72284f0)], typesReal, oneArgDims),
    Funb(log, [(0, 1000)], typesReal, oneArgDims),
    # Funb(log10, [(0, 1000)], typesReal, oneArgDims), # faulty
    Funb(abs, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(abs2, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(ceil, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(floor, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(round, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(trunc, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(cis, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(SpecialFunctions.erf, [(-3.8325067f0, 3.8325067f0)], typesReal, oneArgDims),
    Funb(SpecialFunctions.erfc, [(-3.7439213f0, 10.019834f0)], typesReal, oneArgDims),
    Funb(SpecialFunctions.erfinv, [(-1, 1)], typesReal, oneArgDims),
    Funb(SpecialFunctions.erfcinv, [(0, 2)], typesReal, oneArgDims),
    # Funb(SpecialFunctions.lgamma, [(0, 1000)], typesReal, oneArgDims),
    Funb(SpecialFunctions.gamma, [(0, 36)], typesReal, oneArgDims),
    # twoArgDims
    Funb(atan, [(-1, 1), (-1, 1)], typesReal, twoArgDims),
    Funb(hypot, [(-1000, 1000), (-1000, 1000)], typesReal, twoArgDims),
    # Funb(/, [(-1000, 1000), (-1000, 1000)], typesReal, twoArgDims),
    # Funb(^, [(0, 100), (-5, 20)], typesReal, twoArgDims),
])

configsRealIVM = FunbArray([
    # oneArgDims
    Funb(IVM.acos, [(-1, 1)], typesReal, oneArgDims),
    Funb(IVM.asin, [(-1, 1)], typesReal, oneArgDims),
    Funb(IVM.atan, [(-50, 50)], typesReal, oneArgDims),
    Funb(IVM.cos, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.sin, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.tan, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.acosh, [(1, 1000)], typesReal, oneArgDims),
    Funb(IVM.asinh, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.atanh, [(-1, 1)], typesReal, oneArgDims),
    Funb(IVM.cosh, [(0, 89.415985f0)], typesReal, oneArgDims),
    Funb(IVM.sinh, [(-89.415985f0, 89.415985f0)], typesReal, oneArgDims),
    Funb(IVM.tanh, [(-8.66434f0, 8.66434f0)], typesReal, oneArgDims),
    Funb(IVM.cbrt, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.sqrt, [(0, 1000)], typesReal, oneArgDims),
    Funb(IVM.exp, [(-88.72284f0, 88.72284f0)], typesReal, oneArgDims),
    Funb(IVM.expm1, [(-88.72284f0, 88.72284f0)], typesReal, oneArgDims),
    Funb(IVM.log, [(0, 1000)], typesReal, oneArgDims),
    # Funb(IVM.log10, [(0, 1000)], typesReal, oneArgDims), # faulty
    Funb(IVM.abs, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.abs2, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.ceil, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.floor, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.round, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.trunc, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.cis, [(-1000, 1000)], typesReal, oneArgDims),
    Funb(IVM.erf, [(-3.8325067f0, 3.8325067f0)], typesReal, oneArgDims),
    Funb(IVM.erfc, [(-3.7439213f0, 10.019834f0)], typesReal, oneArgDims),
    Funb(IVM.erfinv, [(-1, 1)], typesReal, oneArgDims),
    Funb(IVM.erfcinv, [(0, 2)], typesReal, oneArgDims),
    # Funb(IVM.lgamma, [(0, 1000)], typesReal, oneArgDims), # faulty
    Funb(IVM.gamma, [(0, 36)], typesReal, oneArgDims),
    # twoArgDims
    Funb(IVM.atan, [(-1, 1), (-1, 1)], typesReal, twoArgDims),
    Funb(IVM.hypot, [(-1000, 1000), (-1000, 1000)], typesReal, twoArgDims),
    # Funb(IVM.(/), [(-1000, 1000), (-1000, 1000)], typesReal, twoArgDims),
    # Funb(IVM.(^), [(0, 100), (-5, 20)], typesReal, twoArgDims),
])

################################################################

################################################################

# do plotting
plotBench()
