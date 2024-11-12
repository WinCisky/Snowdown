extends CharacterBody2D


var ACCELERATION = 90.0
var DECELERATION = 30.0
var MAX_SPEED = 500.0
var MIN_SPEED = 50.0
var ROTATION_SPEED = 1.0

var direction = Vector2.DOWN
var speed = MIN_SPEED

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input := Input.get_axis("ui_left", "ui_right")
	
	# Check if input is close to zero (no direction change)
	if abs(input) < 0.01:
		# Accelerate if going in the same direction
		speed += ACCELERATION * delta
	else:
		# Update direction based on input
		direction = direction.rotated(input * ROTATION_SPEED * delta * -1).normalized()

		# Decelerate if direction changes
		speed -= ACCELERATION * delta

	# Clamp the speed to stay within min and max limits
	speed = clamp(speed, MIN_SPEED, MAX_SPEED)

	# Move the player in the current direction with the calculated speed
	velocity = direction * speed

	move_and_slide()
	
	animated_sprite.rotation = direction.angle() - (PI / 2)
