
extends Control

@onready var manager: SimulationManager = $SimulationManager

@onready var moisture_label: Label = $MoistureLabel
@onready var moisture_bar: ProgressBar = $MoistureBar
@onready var accelerate_button: Button = $AcelerateButton
@onready var temperature_label: Label = $TemperatureLabel

@onready var irrigation_label: Label = $IrrigationLabel
@onready var irrigation_bar: ProgressBar = $IrrigationBar

@onready var fuzzy_info: RichTextLabel = $FuzzyInfo

@onready var start_button: Button = $StartButton
@onready var pause_button: Button = $PauseButton
@onready var reset_button: Button = $ResetButton

@onready var temperature_slider: HSlider = $TemperatureSlider
@onready var water_particles: GPUParticles2D = $WaterParticle
@onready var moisture_graph: Graphs = $PainelBase/MoistureGraph
@onready var temperature_graph: Graphs = $PainelBase/TemperatureGraph
@onready var irrigation_graph: Graphs = $PainelBase/IrrigationGraph


func _ready() -> void:
	$PainelBase.visible = false
	$FuzzyGraphs.visible = false
	water_particles.emitting = false
	moisture_graph.graph_title = "Umidade (%)"
	temperature_graph.graph_title = "Temperatura (C°)"
	irrigation_graph.graph_title = "Irrigação (% Fuzzy)"
	
	manager.simulation_updated.connect(_on_simulation_updated)

	start_button.pressed.connect(manager.start_simulation)
	pause_button.pressed.connect(manager.pause_simulation)
	reset_button.pressed.connect(manager.reset_simulation)

	temperature_slider.min_value = 0
	temperature_slider.max_value = 50
	temperature_slider.value = manager.initial_temperature

	accelerate_button.button_down.connect(
	manager.accelerate_simulation
)
	accelerate_button.button_up.connect(
	manager.normal_simulation_speed
)
	temperature_slider.value_changed.connect(
		manager.change_temperature
	)

	update_interface_initial()


func update_interface_initial() -> void:

	moisture_bar.value = manager.environment.moisture

	temperature_label.text = "Temperatura: %.1f °C" % manager.environment.temperature


func _on_simulation_updated(data: Dictionary) -> void:
	var moisture = data["moisture"]
	var temperature = data["temperature"]
	var irrigation = data["irrigation"]
	
	water_particles.emitting = irrigation > 1.0
	water_particles.amount_ratio = clampf(
		irrigation / 100.0,
		0.0,
		1.0
	)

	

	moisture_label.text = "Umidade: %.2f%%" % moisture
	moisture_bar.value = moisture

	temperature_label.text = "Temperatura: %.1f °C" % temperature



	irrigation_label.text = "Irrigação: %.2f%%" % irrigation
	irrigation_bar.value = irrigation



	var fuzzy = data["fuzzy_result"]

	var moisture_values = fuzzy["moisture_memberships"]
	var temperature_values = fuzzy["temperature_memberships"]
	var activations = fuzzy["rule_activations"]

	var info = ""

	info += "Entradas Fuzzy:\n\n"

	info += "Umidade:\n"

	for key in moisture_values:
		info += "%s: %.2f\n" % [
			key,
			moisture_values[key]
		]

	info += "\nTemperatura:\n"

	for key in temperature_values:
		info += "%s: %.2f\n" % [
			key,
			temperature_values[key]
		]

	info += "\nRegras Ativas\n\n"

	for rule in activations:

		if rule["activation"] > 0.0:

			info += "%s: %.2f | %s\n" % [
				rule["name"],
				rule["activation"],
				rule["output"]
			]

	info += "\nDefuzzificação\n\n"

	info += "Centroide: %.2f%%\n" % irrigation

	info += "\nTempo: %.1f s" % data["time"]

	fuzzy_info.text = info
	
# Gráficos

	var time = data["time"]

	if time == 0.0:
		moisture_graph.clear_graph()
		temperature_graph.clear_graph()
		irrigation_graph.clear_graph()


	moisture_graph.add_point(
		time,
		data["moisture"]
	)

	temperature_graph.add_point(
		time,
		data["temperature"]
	)

	irrigation_graph.add_point(
		time,
		data["irrigation"]
	)


func _on_panel_button_pressed() -> void:
	$PainelBase.visible = !$PainelBase.visible


func _on_fuzzy_panel_button_pressed() -> void:
	$FuzzyGraphs.visible = !$FuzzyGraphs.visible
