extends Node2D

class Line:
	var start: Vector2
	var end: Vector2
	
	static func create(start: Vector2, end: Vector2) -> Line:
		var instance = Line.new()
		instance.start = start
		instance.end = end
		return instance

var random_points = []
var lines = []
var tilemap: TileMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_random_points(100)  # Generate 100 points
	connect_points()
	create_background()
	pass # Replace with function body.

func generate_random_points(count: int):
	for i in range(count):
		var point = Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
		random_points.append(point)

func connect_points():
	for i in range(random_points.size()):
		for j in range(i + 1, random_points.size()):
			var point_a = random_points[i]
			var point_b = random_points[j]
			if point_a.distance_to(point_b) < 100 and abs(point_a.y - point_b.y) < 500:
				var line = Line.create(point_a, point_b)
				lines.append(line)

func distance_from_point_to_line(point: Vector2, line_start: Vector2, line_end: Vector2) -> float:
	var line_vector = line_end - line_start
	var point_vector = point - line_start

	# Calculate the length squared of the line segment
	var line_length_squared = line_vector.length_squared()

	if line_length_squared == 0:  # Prevent division by zero if line_start and line_end are the same point
		return point.distance_to(line_start)

	# Calculate the projection factor
	var t = clamp(point_vector.dot(line_vector) / line_length_squared, 0, 1)

	# Find the closest point on the line segment
	var closest_point = line_start + line_vector * t

	# Return the distance from the point to the closest point on the line
	return point.distance_to(closest_point)

func create_background():
	tilemap = TileMap.new()
	tilemap.set_tileset(load("res://assets/tilemap.png"))
	add_child(tilemap)

	for x in range(-100, 101):
		for y in range(-100, 101):
			var position = Vector2(x, y)
			var is_near_line = false
			
			# Check proximity to lines
			for line in lines:
				var closest_point = distance_from_point_to_line(position, line.start, line.end)
				if closest_point < 10:
					is_near_line = true
					break
			
			# Set tile based on proximity
			if is_near_line:
				tilemap.set_cell(
					0,
					position,
					0,
					Vector2i(0, 0)
				)
			else:
				tilemap.set_cell(
					0,
					position,
					0,
					Vector2i(2, 0)
				)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _draw():
	for line in lines:
		draw_line(line.start, line.end, Color(1, 0, 0), 2)  # Red lines, thickness 2
