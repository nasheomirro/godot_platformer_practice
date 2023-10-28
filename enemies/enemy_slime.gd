extends Enemy

const SPEED = 50.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = -1

func _physics_process(delta):
	apply_gravity(delta)
	
	if was_hit_in_direction != 0:
		velocity.x = KNOCKBACK * was_hit_in_direction
		was_hit_in_direction = 0
	
	velocity.x = move_toward(velocity.x, direction * SPEED, SPEED)
	
	if not $GroundCheckLeft.is_colliding() or is_on_wall():
		direction *= -1
		scale.x *= -1

	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
