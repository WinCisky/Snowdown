extends CharacterBody2D


const SPEED = 300.0
const SLOWDOWN_MULTIPLIER = 1.4


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		# accelerate linearly towards the pressed direction
		velocity.x = velocity.lerp(Vector2(direction * SPEED, 0), delta).x
	else:
		# decelerate to gowards going straight down
		velocity.x = velocity.lerp(Vector2(0, 0), delta * SLOWDOWN_MULTIPLIER).x

	# TODO: calculate y velocity
	# go faster if going straight
	# dlow down if it's changing the direction

	move_and_slide()
