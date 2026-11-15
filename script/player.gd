extends CharacterBody2D

const SPEED = 200.0
const MIN_JUMP_VELOCITY = -150.0
const MAX_JUMP_VELOCITY = -350.0
const MAX_HOLD_TIME = 0.25

var jump_timer = 0.0
var is_jumping = false

# Reference your AnimatedSprite2D node (adjust the name if yours is different)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		is_jumping = false

	# Handle jump start
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = MIN_JUMP_VELOCITY
		jump_timer = 0.0
		is_jumping = true

	# Handle holding the jump button to jump higher
	if Input.is_action_pressed("ui_accept") and is_jumping:
		jump_timer += delta
		if jump_timer < MAX_HOLD_TIME:
			velocity.y = lerp(MIN_JUMP_VELOCITY, MAX_JUMP_VELOCITY, jump_timer / MAX_HOLD_TIME)
		else:
			is_jumping = false

	# Cut the jump short if the player lets go early
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		is_jumping = false
		velocity.y *= 0.5

	# Get the input direction and handle movement/deceleration
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- ANIMATION LOGIC ---
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump") # Or "bounce"
		else:
			animated_sprite.play("fall")
	elif direction != 0:
		animated_sprite.play("run")
		# Flip the sprite depending on which way they are moving
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.play("idle")

	move_and_slide()
