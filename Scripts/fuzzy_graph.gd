
extends Control
class_name FuzzyGraph

enum GraphType {
	MOISTURE,
	TEMPERATURE,
	IRRIGATION
}

@export var graph_type: GraphType = GraphType.MOISTURE

var definitions: Array[Dictionary] = []

const LEFT = 45.0
const RIGHT = 15.0
const TOP = 55.0
const BOTTOM = 35.0

const COLORS = [
	Color("#38BDF8"),
	Color("#22C55E"),
	Color("#F59E0B"),
	Color("#A78BFA"),
	Color("#F87171")
]


func _ready() -> void:

	custom_minimum_size = Vector2(380, 250)

	load_definitions()

	queue_redraw()

func load_definitions() -> void:

	match graph_type:

		GraphType.MOISTURE:

			definitions = [
				{
					"name": "Seco",
					"shape": "trapezoidal",
					"params": [0.0, 0.0, 20.0, 40.0]
				},
				{
					"name": "Adequado",
					"shape": "triangular",
					"params": [25.0, 50.0, 75.0]
				},
				{
					"name": "Úmido",
					"shape": "trapezoidal",
					"params": [60.0, 80.0, 100.0, 100.0]
				}
			]

		GraphType.TEMPERATURE:

			definitions = [
				{
					"name": "Fria",
					"shape": "trapezoidal",
					"params": [0.0, 0.0, 10.0, 20.0]
				},
				{
					"name": "Agradável",
					"shape": "triangular",
					"params": [15.0, 25.0, 35.0]
				},
				{
					"name": "Quente",
					"shape": "trapezoidal",
					"params": [30.0, 40.0, 50.0, 50.0]
				}
			]

		GraphType.IRRIGATION:

			definitions = [
				{
					"name": "Desligada",
					"shape": "trapezoidal",
					"params": [0.0, 0.0, 5.0, 20.0]
				},
				{
					"name": "Baixa",
					"shape": "triangular",
					"params": [10.0, 25.0, 40.0]
				},
				{
					"name": "Média",
					"shape": "triangular",
					"params": [30.0, 50.0, 70.0]
				},
				{
					"name": "Alta",
					"shape": "triangular",
					"params": [60.0, 75.0, 90.0]
				},
				{
					"name": "Máxima",
					"shape": "trapezoidal",
					"params": [80.0, 95.0, 100.0, 100.0]
				}
			]



func evaluate_membership(
	definition: Dictionary,
	x: float
) -> float:

	var p = definition["params"]

	if definition["shape"] == "triangular":

		return FuzzyMembership.triangular(
			x, p[0], p[1], p[2]
		)

	return FuzzyMembership.trapezoidal(
		x, p[0], p[1], p[2], p[3]
	)


# Limites do eixo X

func get_max_x() -> float:

	if graph_type == GraphType.TEMPERATURE:
		return 50.0

	return 100.0


# Título

func get_graph_title() -> String:

	match graph_type:

		GraphType.MOISTURE:
			return "Umidade do Solo (%)"

		GraphType.TEMPERATURE:
			return "Temperatura (°C)"

		GraphType.IRRIGATION:
			return "Saída de Irrigação (%)"

	return "Funções Fuzzy"


# Desenho do gráfico

func _draw() -> void:

	var graph_width = size.x - LEFT - RIGHT
	var graph_height = size.y - TOP - BOTTOM

	if graph_width <= 0 or graph_height <= 0:
		return

	var bottom_y = TOP + graph_height
	var max_x = get_max_x()

	# Fundo

	draw_rect(
		Rect2(Vector2.ZERO, size),
		Color("#202936")
	)

	# Título

	draw_string(
		ThemeDB.fallback_font,
		Vector2(LEFT, 20),
		get_graph_title(),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		Color.WHITE
	)

	# Legenda

	var legend_x = LEFT

	for i in range(definitions.size()):

		draw_line(
			Vector2(legend_x, 39),
			Vector2(legend_x + 12, 39),
			COLORS[i],
			3.0
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(legend_x + 16, 43),
			definitions[i]["name"],
			HORIZONTAL_ALIGNMENT_LEFT,
			85,
			10,
			Color.WHITE
		)

		legend_x += 95

	# Grade e valores do eixo Y

	for i in range(5):

		var normalized = i / 4.0

		var y = bottom_y - normalized * graph_height

		draw_line(
			Vector2(LEFT, y),
			Vector2(LEFT + graph_width, y),
			Color("#526071"),
			1.0
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(5, y + 4),
			"%.2f" % normalized,
			HORIZONTAL_ALIGNMENT_LEFT,
			35,
			10,
			Color.LIGHT_GRAY
		)

	# Eixo X

	for i in range(5):

		var normalized = i / 4.0

		var x = LEFT + normalized * graph_width

		draw_line(
			Vector2(x, TOP),
			Vector2(x, bottom_y),
			Color("#344255"),
			1.0
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(x - 12, bottom_y + 17),
			"%.0f" % (normalized * max_x),
			HORIZONTAL_ALIGNMENT_CENTER,
			30,
			10,
			Color.LIGHT_GRAY
		)

	# Desenhar eixos

	draw_line(
		Vector2(LEFT, TOP),
		Vector2(LEFT, bottom_y),
		Color.WHITE,
		1.5
	)

	draw_line(
		Vector2(LEFT, bottom_y),
		Vector2(LEFT + graph_width, bottom_y),
		Color.WHITE,
		1.5
	)

	# Desenhar curvas fuzzy

	for i in range(definitions.size()):

		var curve = PackedVector2Array()

		var samples = 200

		for j in range(samples + 1):

			var x = max_x * j / float(samples)

			var membership = evaluate_membership(
				definitions[i],
				x
			)

			var px = LEFT + (x / max_x) * graph_width

			var py = bottom_y - membership * graph_height

			curve.append(Vector2(px, py))

		draw_polyline(
			curve,
			COLORS[i % COLORS.size()],
			2.5,
			true
		)
