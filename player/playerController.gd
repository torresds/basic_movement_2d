extends CharacterBody2D
@onready var animated_sprite = $AnimatedSprite2D


const SPEED = 150.0
const JUMP_VELOCITY = -400.0


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum States {
	Idle,
	Walk,
	Run,
	Jump
}
var current_state

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 2000:
			velocity.y = 2000

	update_states()
	anim_update()
	move_and_slide()

func update_states():
	player_idle()
	handle_jump()
	handle_walk()

func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		current_state = States.Jump
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("jump"):
		if velocity.y < 0:
			velocity.y += -(JUMP_VELOCITY/3)
	if !is_on_floor():
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x += direction * (SPEED/20)
			animated_sprite.flip_h = !(direction > 0)
		else:
			velocity.x = lerp(velocity.x, 0.0, 0.05)
		velocity.x = clamp(velocity.x, -SPEED, SPEED)



func player_idle():
	if is_on_floor():
		current_state = States.Idle
	
func handle_walk():
	if is_on_floor() and current_state != States.Jump:
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x += direction * (SPEED/10)
			animated_sprite.flip_h = !(direction > 0)
			current_state = States.Walk
		else:
			velocity.x = lerp(velocity.x, 0.0, 0.2)
			current_state = States.Idle
		velocity.x = clamp(velocity.x, -SPEED, SPEED)

func anim_update():
	if current_state == States.Jump:
		animated_sprite.play("jump")
	if current_state == States.Walk:
		animated_sprite.play("walk")
	if current_state == States.Idle:
		animated_sprite.play("idle")


