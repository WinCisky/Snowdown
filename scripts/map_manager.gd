extends Node

const TRESHOLD = -0.7
const SCALE_MULTIPLIER = 2
const SIZE = 400
const HALF_SIZE = SIZE / 2
const ROWS_PER_FRAME = 2
const TILE_SIZE = 8

@export var player: CharacterBody2D
@export var tilesets: Array[TileMapLayer]

var noise := FastNoiseLite.new()
var seed = 0
var latest_map_y = 0
var used_tileset_index = 0

var noise_map = {}

func store_noise(x: int, y: int, value: bool):
	noise_map[Vector2(x, y)] = value

func get_noise(x: int, y: int):
	return noise_map.get(Vector2(x, y), 2)

func retrieve_noise(x: int, y: int) -> bool:
	var result = get_noise(x, y)
	if result is not bool and result == 2:
		var noise_val = noise.get_noise_2d(x, y)
		var new_noise = noise_val > TRESHOLD
		if not new_noise:
			var oke = 2
		result = new_noise
		store_noise(x, y, result)
	return result

# 8-bit Directional Values
func get_terrain_tile_type(x, y):
	var current = retrieve_noise(x, y)
	var north = retrieve_noise(x, y - 1) # 1
	var west = retrieve_noise(x - 1, y) # 2
	var east = retrieve_noise(x + 1, y) # 4
	var south = retrieve_noise(x, y + 1) # 8
	
	var sum = 0
	if current:
		if north:
			sum += 1
		if west:
			sum += 2
		if east:
			sum += 4
		if south:
			sum += 8
		
	var my_dict = {
		0: Vector2(0, 0), 1: Vector2(1, 0), 2: Vector2(2, 0), 3: Vector2(3, 0),
		4: Vector2(0, 1), 5: Vector2(1, 1), 6: Vector2(2, 1), 7: Vector2(3, 1),
		8: Vector2(0, 2), 9: Vector2(1, 2), 10: Vector2(2, 2), 11: Vector2(3, 2),
		12: Vector2(0, 3), 13: Vector2(1, 3), 14: Vector2(2, 3), 15: Vector2(3, 3),
	}

	return my_dict[sum]

func update_terrain(index: int, x_pos: int, y_pos: int, width: int, height: int, progressive = true):
	var tileset = tilesets[index]
	tileset.clear()
	for y in range(height):
		for x in range(width):
			var tile_pos = Vector2i((x - HALF_SIZE) + x_pos, (y - HALF_SIZE) + y_pos)
			var cell_type = get_terrain_tile_type(tile_pos.x, tile_pos.y)
			tileset.set_cell(
				tile_pos,
				1,
				cell_type
			)
		if progressive and y % ROWS_PER_FRAME == 0:
			await get_tree().process_frame 

func create_map(index, pos, progressive = true):
	update_terrain(pos.x, pos.y, SIZE, SIZE, progressive)
	# TODO: create terrain overlay (obstacles)

func _ready() -> void:
	# https://auburn.github.io/FastNoiseLite/
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.frequency = 0.010
	noise.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN_SQUARED
	noise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_SUB
	noise.cellular_jitter = 1.13
	# get random seed
	var rng = RandomNumberGenerator.new()
	seed = rng.randi_range(0, 1000)
	# creates the map
	create_map(used_tileset_index, Vector2(0, 0), false)
	# tilesets[used_tileset_index].create_map(seed, Vector2(0, 0), false)

func _physics_process(delta: float) -> void:
	var player_pos = player.position
	if (player.position.y / TILE_SIZE) >= latest_map_y:
		# place new map portion
		latest_map_y += 400
		used_tileset_index = (used_tileset_index + 1) % len(tilesets)
		create_map(used_tileset_index, Vector2(roundi(player.position.x / TILE_SIZE), latest_map_y))
		# tilesets[used_tileset_index].create_map(seed, Vector2(roundi(player.position.x / TILE_SIZE), latest_map_y))
