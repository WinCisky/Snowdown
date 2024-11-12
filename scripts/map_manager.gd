extends Node

const TILE_SIZE = 8

@export var player: CharacterBody2D
@export var tilesets: Array[MapTileset]

var seed = 0
var latest_map_y = 0
var used_tileset_index = 0

func _ready() -> void:
	# get random seed
	var rng = RandomNumberGenerator.new()
	seed = rng.randi_range(0, 1000)
	# creates the map
	tilesets[used_tileset_index].create_map(seed, Vector2(0, 0), false)

func _physics_process(delta: float) -> void:
	var player_pos = player.position
	if (player.position.y / TILE_SIZE) >= latest_map_y:
		# place new map portion
		latest_map_y += 400
		used_tileset_index = (used_tileset_index + 1) % len(tilesets)
		tilesets[used_tileset_index].create_map(seed, Vector2(roundi(player.position.x / TILE_SIZE), latest_map_y))
