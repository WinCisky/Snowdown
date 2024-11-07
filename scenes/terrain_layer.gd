extends TileMapLayer

const TRESHOLD = -0.7
const SCALE_MULTIPLIER = 2
const SIZE = 500
const HALF_SIZE = SIZE / 2
var pos = Vector2(0, 0)
var noise := FastNoiseLite.new()

# 8-bit Directional Values
func get_tile_type(x, y):
	#var north_west = noise.get_noise_2d(x - 1, y - 1) # 1
	#var north = noise.get_noise_2d(x, y - 1) # 2
	#var north_east = noise.get_noise_2d(x + 1, y - 1) # 4
	#var west = noise.get_noise_2d(x - 1, y) # 8
	#var east = noise.get_noise_2d(x + 1, y) # 16
	#var south_west = noise.get_noise_2d(x - 1, y + 1) # 32
	#var south = noise.get_noise_2d(x, y + 1) # 64
	#var south_east = noise.get_noise_2d(x + 1, y + 1) # 128
	#
	#var sum = 0
	#if north > TRESHOLD:
		#sum += 2
	#if west > TRESHOLD:
		#sum += 8
	#if east > TRESHOLD:
		#sum += 16
	#if south > TRESHOLD:
		#sum += 64
	## needs to check if 
	## - north_west
	## - north_east
	## - south_west
	## - south_east
	## are neighbored by existing tiles
	#if north_west > TRESHOLD and north > TRESHOLD and west > TRESHOLD:
		#sum += 1
	#if north_east > TRESHOLD and north > TRESHOLD and east > TRESHOLD:
		#sum += 4
	#if south_west > TRESHOLD and south > TRESHOLD and west > TRESHOLD:
		#sum += 32
	#if south_east > TRESHOLD and south > TRESHOLD and east > TRESHOLD:
		#sum += 128
	#
	#var my_dict = {
		#2: Vector2(0,0), 8: Vector2(1,0), 10: Vector2(2,0), 11: Vector2(3,0), 16: Vector2(4,0), 18: Vector2(5,0), 22: Vector2(6,0), 24: Vector2(7,0),
		#26: Vector2(0,1), 27: Vector2(1,1), 30: Vector2(2,1), 31: Vector2(3,1), 64: Vector2(4,1), 66: Vector2(5,1), 72: Vector2(6,1), 74: Vector2(7,1),
		#75: Vector2(0,2), 80: Vector2(1,2), 82: Vector2(2,2), 86: Vector2(3,2), 88: Vector2(4,2), 90: Vector2(5,2), 91: Vector2(6,2), 94: Vector2(7,2),
		#95: Vector2(0,3), 104: Vector2(1,3), 106: Vector2(2,3), 107: Vector2(3,3), 120: Vector2(4,3), 122: Vector2(5,3), 123: Vector2(6,3), 126: Vector2(7,3),
		#127: Vector2(0,4), 208: Vector2(1,4), 210: Vector2(2,4), 214: Vector2(3,4), 216: Vector2(4,4), 218: Vector2(5,4), 219: Vector2(6,4), 222: Vector2(7,4),
		#223: Vector2(0,5), 248: Vector2(1,5), 250: Vector2(2,5), 251: Vector2(3,5), 254: Vector2(4,5), 255: Vector2(6,5), 0: Vector2(7,5)
	#}
	
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

func create_noise(x_pos, y_pos, width, height):
	var bitmap = []
	for x in range(width):
		var bitmap_row = []
		for y in range(height):
			var cell_type = get_tile_type(x, y)
			set_cell(
				Vector2(x - HALF_SIZE, y - HALF_SIZE),
				1,
				cell_type
			)

func _ready() -> void:
	# https://auburn.github.io/FastNoiseLite/
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.frequency = 0.010
	noise.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN_SQUARED
	noise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_SUB
	noise.cellular_jitter = 1.13
	create_noise(-HALF_SIZE + pos.x, -HALF_SIZE + pos.y, SIZE, SIZE)

func _process(delta: float) -> void:
	pos += Vector2(0, delta * 5)
	#create_noise(-HALF_SIZE + pos.x, -HALF_SIZE + pos.y, SIZE, SIZE)
	position -= Vector2(0, delta * 100)
