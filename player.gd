extends CharacterBody2D

enum State { MOVE, ATTACK }

const ACCELERATION = 40
const SPEED = 150.0
const JUMP_VELOCITY = -300.0

var state: State = State.MOVE
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var should_buffer_jump: = false
var is_staggered = false

var direction = 1:
	set(value):
		if value == 1 or value == -1:
			direction = value
		if value < 0:
			scale.y = -1
			rotation_degrees = 180
		elif value > 0:
			scale.y = 1
			rotation_degrees = 0

func _physics_process(delta):
	match state:
		State.MOVE: move_state(delta)
		State.ATTACK: attack_state(delta)

func attack_state(delta):
	apply_gravity(delta)
	
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)
	
	if $AnimatedSprite2D.animation != "attack":
		$AnimatedSprite2D.play("attack")
		$AttackBox.monitoring = true
	elif not $AnimatedSprite2D.is_playing():
		state = State.MOVE
		$AttackBox.monitoring = false
	
	move_and_slide()

func move_state(delta: float):
	if Input.is_action_just_pressed("player_attack") and not is_staggered:
		state = State.ATTACK
	
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")	
	
	apply_gravity(delta)
	
	handle_horizontal_movement(input)
	
	handle_jumping(input)
	
	handle_movement_animation(input)
	
	var was_on_air = not is_on_floor()
	var previous_velocity = velocity
	
	move_and_slide()
	
	handle_just_landed(was_on_air, previous_velocity)

func handle_just_landed(was_on_air: bool, previous_velocity: Vector2):
	if was_on_air and is_on_floor() and previous_velocity.y > 400:
		apply_staggered()

func handle_movement_animation(input: Vector2):
	var current_animation = $AnimatedSprite2D.animation
	
	if input.x != 0:
		direction = input.x
	
	if is_on_floor(): 
		if is_staggered and current_animation != "land":
			$AnimatedSprite2D.play("land")
		
		if not is_staggered:
			if input.x == 0 or is_on_wall():
				$AnimatedSprite2D.play("idle")
			else:
				$AnimatedSprite2D.play("run")
	
	if velocity.y < 0 and current_animation != "jump":
		$AnimatedSprite2D.play("jump")
	
	if velocity.y >= 0 and not is_on_floor():
		$AnimatedSprite2D.play("fall")


func handle_horizontal_movement(input: Vector2):
	if input.x == 0 or is_staggered:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, input.x * SPEED, ACCELERATION)

func handle_jumping(input):
	if is_staggered:
		return
	
	var should_jump = false
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			should_jump = true
		else:
			should_buffer_jump = true
			$BufferJumpTimer.start()
	
	if should_buffer_jump and is_on_floor():
		should_jump = true
	
	if should_jump:
		velocity.y = JUMP_VELOCITY


func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta

func apply_staggered():
	is_staggered = true
	$LandBufferTimer.start()


func _on_buffer_jump_timer_timeout():
	should_buffer_jump = false

func _on_land_buffer_timer_timeout():
	is_staggered = false
	pass # Replace with function body.


func _on_attack_box_body_entered(body):
	if body is Enemy:
		print(direction)
		body.hit(direction)
