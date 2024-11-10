extends CharacterBody2D


const MAX_SPEED = 150.0
const MOVE_SPEED = 50.0
const SLOWDOWN_MULTIPLIER = 2
const VELOCITY_STEERING_MULTIPLIER = 2

# you either go fast or you steer
var velocity_steering_coefficient = Vector2.ZERO


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		if (direction > 0 and velocity.x <= 0) or (direction < 0 and velocity.x >= 0):
			velocity_steering_coefficient = velocity_steering_coefficient.lerp(
				Vector2.RIGHT, delta * VELOCITY_STEERING_MULTIPLIER
			)
		
		# accelerate linearly towards the pressed direction
		velocity.x = velocity.lerp(
			Vector2(direction * MAX_SPEED, 0), 
			delta * MOVE_SPEED * velocity_steering_coefficient.x
		).x
	else:
		# accelerate and decrease steering
		velocity_steering_coefficient = velocity_steering_coefficient.lerp(
			Vector2.DOWN, delta * VELOCITY_STEERING_MULTIPLIER
		)
		
		# decelerate towards going straight down
		velocity.x = velocity.lerp(
			Vector2.ZERO,
			delta * SLOWDOWN_MULTIPLIER * velocity_steering_coefficient.x
		).x
		
	velocity.y = delta * 15000 * velocity_steering_coefficient.y

	move_and_slide()
