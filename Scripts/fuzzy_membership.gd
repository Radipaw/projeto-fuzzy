
class_name FuzzyMembership
extends RefCounted

# a = início
# b = pico
# c = fim

static func triangular(x: float, a: float, b: float, c: float) -> float:

	if x <= a or x >= c:
		return 0.0

	if x == b:
		return 1.0

	if x < b:
		return (x - a) / (b - a)

	return (c - x) / (c - b)


# a = início
# b = início do pico
# c = fim do pico
# d = fim

static func trapezoidal(x: float, a: float, b: float, c: float, d: float) -> float:

	if x < a or x > d:
		return 0.0

	if x >= b and x <= c:
		return 1.0

	if x < b:
		if a == b:
			return 1.0
		return (x - a) / (b - a)

	if x > c:
		if c == d:
			return 1.0
		return (d - x) / (d - c)

	return 0.0
