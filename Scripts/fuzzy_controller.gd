
class_name FuzzyController
extends RefCounted


const OUTPUT_MIN = 0.0
const OUTPUT_MAX = 100.0
const OUTPUT_STEP = 1.0


# Base de regras fuzzy

var rules = [
	{"name": "R1", "moisture": "seco", "temperature": "fria", "output": "alta"},
	{"name": "R2", "moisture": "seco", "temperature": "agradavel", "output": "alta"},
	{"name": "R3", "moisture": "seco", "temperature": "quente", "output": "maxima"},

	{"name": "R4", "moisture": "adequado", "temperature": "fria", "output": "desligada"},
	{"name": "R5", "moisture": "adequado", "temperature": "agradavel", "output": "baixa"},
	{"name": "R6", "moisture": "adequado", "temperature": "quente", "output": "media"},

	{"name": "R7", "moisture": "umido", "temperature": "fria", "output": "desligada"},
	{"name": "R8", "moisture": "umido", "temperature": "agradavel", "output": "desligada"},
	{"name": "R9", "moisture": "umido", "temperature": "quente", "output": "desligada"}
]

# Fuzzificação

func fuzzify_moisture(value: float) -> Dictionary:

	return {
		"seco": FuzzyMembership.trapezoidal(
			value, 0, 0, 20, 40
		),

		"adequado": FuzzyMembership.triangular(
			value, 25, 50, 75
		),

		"umido": FuzzyMembership.trapezoidal(
			value, 60, 80, 100, 100
		)
	}


func fuzzify_temperature(value: float) -> Dictionary:

	return {
		"fria": FuzzyMembership.trapezoidal(
			value, 0, 0, 10, 20
		),

		"agradavel": FuzzyMembership.triangular(
			value, 15, 25, 35
		),

		"quente": FuzzyMembership.trapezoidal(
			value, 30, 40, 50, 50
		)
	}


# Output

func output_membership(name: String, value: float) -> float:

	match name:

		"desligada":
			return FuzzyMembership.trapezoidal(
				value, 0, 0, 5, 20
			)

		"baixa":
			return FuzzyMembership.triangular(
				value, 10, 25, 40
			)

		"media":
			return FuzzyMembership.triangular(
				value, 30, 50, 70
			)

		"alta":
			return FuzzyMembership.triangular(
				value, 60, 75, 90
			)

		"maxima":
			return FuzzyMembership.trapezoidal(
				value, 80, 95, 100, 100
			)

	return 0.0

# Mandani

func calculate(moisture: float, temperature: float) -> Dictionary:

	var moisture_values = fuzzify_moisture(moisture)
	var temperature_values = fuzzify_temperature(temperature)

	var activations = []

	for rule in rules:

		var moisture_degree = moisture_values[rule["moisture"]]
		var temperature_degree = temperature_values[rule["temperature"]]

		var activation = min(
			moisture_degree,
			temperature_degree
		)

		activations.append({
			"name": rule["name"],
			"moisture": rule["moisture"],
			"temperature": rule["temperature"],
			"output": rule["output"],
			"activation": activation
		})

	var aggregated = []

	var numerator = 0.0
	var denominator = 0.0

	var sample_count = int(
		(OUTPUT_MAX - OUTPUT_MIN) / OUTPUT_STEP
	)

	for i in range(sample_count + 1):

		var z = OUTPUT_MIN + i * OUTPUT_STEP
		var aggregated_degree = 0.0

		for rule_result in activations:

			var activation = rule_result["activation"]
			var output_name = rule_result["output"]

			var clipped = min(
				activation,
				output_membership(output_name, z)
			)

			aggregated_degree = max(
				aggregated_degree,
				clipped
			)

		aggregated.append({
			"x": z,
			"membership": aggregated_degree
		})

		numerator += z * aggregated_degree
		denominator += aggregated_degree

	var crisp_output = 0.0

	if denominator > 0.0:
		crisp_output = numerator / denominator

	return {
		"moisture_input": moisture,
		"temperature_input": temperature,
		"moisture_memberships": moisture_values,
		"temperature_memberships": temperature_values,
		"rule_activations": activations,
		"aggregated_output": aggregated,
		"irrigation": crisp_output
	}
