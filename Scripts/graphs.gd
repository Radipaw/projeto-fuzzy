
extends Control
class_name Graphs

@export var graph_title: String = "Gráfico"
@export var min_value: float = 0.0
@export var max_value: float = 100.0
@export var line_color: Color = Color.GREEN

var points: Array[Vector2] = []

const MAX_POINTS = 120

const LEFT_MARGIN = 42.0
const RIGHT_MARGIN = 12.0
const TOP_MARGIN = 30.0
const BOTTOM_MARGIN = 25.0


func _ready() -> void:
	custom_minimum_size = Vector2(280, 180)
	queue_redraw()


func add_point(time: float, value: float) -> void:

	points.append(Vector2(time, value))

	if points.size() > MAX_POINTS:
		points.pop_front()

	queue_redraw()


func clear_graph() -> void:

	points.clear()
	queue_redraw()


func _draw() -> void:

	var w = size.x
	var h = size.y

	var graph_width = w - LEFT_MARGIN - RIGHT_MARGIN
	var graph_height = h - TOP_MARGIN - BOTTOM_MARGIN

	if graph_width <= 0 or graph_height <= 0:
		return

	var left = LEFT_MARGIN
	var top = TOP_MARGIN
	var bottom = top + graph_height

	# Fundo

	draw_rect(
		Rect2(Vector2.ZERO, size),
		Color("#202936")
	)

	# Título

	draw_string(
		ThemeDB.fallback_font,
		Vector2(left, 20),
		graph_title,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		Color.WHITE
	)

	# Grade

	for i in range(5):

		var y = top + graph_height * i / 4.0

		draw_line(
			Vector2(left, y),
			Vector2(left + graph_width, y),
			Color("#526071"),
			1.0
		)

		var value = max_value - (
			(max_value - min_value) * i / 4.0
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(2, y + 4),
			"%.0f" % value,
			HORIZONTAL_ALIGNMENT_LEFT,
			35,
			10,
			Color.LIGHT_GRAY
		)

	draw_line(
		Vector2(left, top),
		Vector2(left, bottom),
		Color.WHITE,
		1.5
	)

	draw_line(
		Vector2(left, bottom),
		Vector2(left + graph_width, bottom),
		Color.WHITE,
		1.5
	)

	if points.is_empty():
		return

	var first_time = points[0].x
	var last_time = points[-1].x

	var time_range = maxf(last_time - first_time, 1.0)

	var line_points = PackedVector2Array()

	for point in points:

		var normalized_x = (
			(point.x - first_time) / time_range
		)

		var normalized_y = (
			(point.y - min_value) /
			maxf(max_value - min_value, 0.001)
		)

		var px = left + normalized_x * graph_width

		var py = bottom - normalized_y * graph_height

		line_points.append(Vector2(px, py))

	if line_points.size() >= 2:

		draw_polyline(
			line_points,
			line_color,
			2.5,
			true
		)


	var last_point = line_points[-1]

	draw_circle(
		last_point,
		4.0,
		line_color
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(left, h - 5),
		"Tempo: %.1f s" % last_time,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		10,
		Color.LIGHT_GRAY
	)
