class_name SimulationManager
extends Node


signal simulation_updated(data: Dictionary)


@export var simulation_interval: float = 1.0
@export var initial_moisture: float = 15.0
@export var initial_temperature: float = 35.0
var simulation_speed: float = 1.0

const NORMAL_SPEED: float = 1.0
const FAST_SPEED: float = 5.0

var controller: FuzzyController
var environment: IrrigationEnvironment

var running: bool = false
var accumulator: float = 0.0
var elapsed_time: float = 0.0

var last_result: Dictionary = {}


func _ready() -> void:

	controller = FuzzyController.new()
	environment = IrrigationEnvironment.new()

	reset_simulation()


func _process(delta: float) -> void:

	if not running:
		return

	accumulator += delta * simulation_speed

	while accumulator >= simulation_interval:

		accumulator -= simulation_interval

		simulate_step(simulation_interval)


func simulate_step(delta_time: float) -> void:

	var current_moisture = environment.moisture
	var current_temperature = environment.temperature

	last_result = controller.calculate(
		current_moisture,
		current_temperature
	)

	var irrigation = last_result["irrigation"]
	if irrigation < 10.0:
		irrigation = 0.0


	environment.update_environment(
		irrigation,
		delta_time
	)

	elapsed_time += delta_time


	var data = {
		"time": elapsed_time,
		"moisture": environment.moisture,
		"temperature": environment.temperature,
		"irrigation": irrigation,
		"pump_on": irrigation > 1.0,
		"fuzzy_result": last_result
	}



	simulation_updated.emit(data)


# Simulação 

func start_simulation() -> void:

	running = true


func pause_simulation() -> void:

	running = false


func reset_simulation() -> void:

	running = false

	accumulator = 0.0
	elapsed_time = 0.0

	environment.set_initial_conditions(
		initial_moisture,
		initial_temperature
	)

	last_result = controller.calculate(
		environment.moisture,
		environment.temperature
	)

	simulation_updated.emit({
		"time": 0.0,
		"moisture": environment.moisture,
		"temperature": environment.temperature,
		"irrigation": 0.0,
		"pump_on": false,
		"fuzzy_result": last_result
	})


# Mudar temperatura

func change_temperature(new_temperature: float) -> void:

	environment.set_temperature(new_temperature)


func set_initial_moisture(value: float) -> void:

	initial_moisture = clampf(value, 0.0, 100.0)


func set_initial_temperature(value: float) -> void:

	initial_temperature = clampf(value, 0.0, 50.0)

func accelerate_simulation() -> void:
	simulation_speed = FAST_SPEED


func normal_simulation_speed() -> void:
	simulation_speed = NORMAL_SPEED
