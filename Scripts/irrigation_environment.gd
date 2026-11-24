class_name IrrigationEnvironment
extends RefCounted

var moisture: float = 15.0
var temperature: float = 35.0

# Variáveis da simulação

const WATER_GAIN = 0.08
const EVAPORATION_BASE = 0.02
const EVAPORATION_FACTOR = 0.01


func update_environment(irrigation: float, delta_time: float) -> void:

	# Irrigação

	var water_added = WATER_GAIN * irrigation

	# Evaporação

	var water_lost = (
		EVAPORATION_BASE +
		EVAPORATION_FACTOR * temperature
	)

	# Atualizar umidade

	moisture += (
		water_added - water_lost
	) * delta_time

	

	moisture = clampf(moisture, 0.0, 100.0)


func set_initial_conditions(
	initial_moisture: float,
	initial_temperature: float
) -> void:

	moisture = clampf(initial_moisture, 0.0, 100.0)
	temperature = clampf(initial_temperature, 0.0, 50.0)


func set_temperature(new_temperature: float) -> void:

	temperature = clampf(new_temperature, 0.0, 50.0)
