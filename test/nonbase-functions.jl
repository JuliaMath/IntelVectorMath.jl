#  :inv_sqrt
inv_sqrt(x) = 1 / sqrt(x)
# inv_cbrt
inv_cbrt(x) = 1 / cbrt(x)

#  :pow2o3
pow2o3(x) = cbrt(x^2)
# x^(2 / 3) also doable but not as fast, and different accuracy
#  :pow3o2
pow3o2(x) = sqrt(x^3)

# pow
pow(x, y) = x^y
# divide
divide(x, y) = x / y

# :lgamma
# Redefining for testing to avoid deprecation warning
SpecialFunctions.lgamma(x::Union{Float64,Float32}) = (logabsgamma(x))[1]

atanpi(x, y) = atan(x, y) / pi
atanpi(x) = atan(x) / pi

acospi(x) = acos(x) / pi
asinpi(x) = asin(x) / pi

# MKL has higher accuracy on Float32s
tanpi(x) = oftype(x, Base.tan(widen(x) * pi))
