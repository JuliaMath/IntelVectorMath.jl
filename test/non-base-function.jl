# Test functions that are neither in base nor in SpecialFunctions
# avilable via Main.
cdfnorm(x) = 0.5 * (1 + SpecialFunctions.erf(x / sqrt(2)))