class_name MapTileset

extends TileMapLayer

const TRESHOLD = -0.7
const SCALE_MULTIPLIER = 2
const SIZE = 400
const HALF_SIZE = SIZE / 2
const ROWS_PER_FRAME = 2
var noise := FastNoiseLite.new()

# 8-bit Directional Values
func get_tile_type(x, y):	
	var current = noise.get_noise_2d(x, y)
	var north = noise.get_noise_2d(x, y - 1) # 1
	var west = noise.get_noise_2d(x - 1, y) # 2
	var east = noise.get_noise_2d(x + 1, y) # 4
	var south = noise.get_noise_2d(x, y + 1) # 8
	
	var sum = 0
	if current > TRESHOLD:
		if north > TRESHOLD:
			sum += 1
		if west > TRESHOLD:
			sum += 2
		if east > TRESHOLD:
			sum += 4
		if south > TRESHOLD:
			sum += 8
		
	var my_dict = {
		0: Vector2(0, 0), 1: Vector2(1, 0), 2: Vector2(2, 0), 3: Vector2(3, 0),
		4: Vector2(0, 1), 5: Vector2(1, 1), 6: Vector2(2, 1), 7: Vector2(3, 1),
		8: Vector2(0, 2), 9: Vector2(1, 2), 10: Vector2(2, 2), 11: Vector2(3, 2),
		12: Vector2(0, 3), 13: Vector2(1, 3), 14: Vector2(2, 3), 15: Vector2(3, 3),
	}

	return my_dict[sum]

func update_map(x_pos, y_pos, width, height, progressive = true):
	clear()
	for y in range(height):
		for x in range(width):
			var tile_pos = Vector2i((x - HALF_SIZE) + x_pos, (y - HALF_SIZE) + y_pos)
			var cell_type = get_tile_type(tile_pos.x, tile_pos.y)
			set_cell(
				tile_pos,
				1,
				cell_type
			)
		if progressive and y % ROWS_PER_FRAME == 0:
			await get_tree().process_frame 

func create_map(seed, pos, progressive = true):
	noise.seed = seed
	update_map(pos.x, pos.y, SIZE, SIZE, progressive)

func _ready() -> void:
	# https://auburn.github.io/FastNoiseLite/
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.frequency = 0.010
	noise.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN_SQUARED
	noise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_SUB
	noise.cellular_jitter = 1.13
