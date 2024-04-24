extends CharacterBody2D
@onready var animated_sprite = $AnimatedSprite2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0
@export var jump_buffer_time: int = 15
@export var cayote_time : int = 15

var jump_buffer_counter: int = 0
var cayote_counter : int = 0
var run_momentum: float = 0
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
	handle_run()

func handle_jump():
	if Input.is_action_just_pressed("jump"):
		jump_buffer_counter = jump_buffer_time
	if jump_buffer_counter > 0:
		jump_buffer_counter -= 1
	if jump_buffer_counter > 0 and is_on_floor():
		print(current_state == States.Run)
		velocity.y = JUMP_VELOCITY + (JUMP_VELOCITY/3)*(run_momentum/10)
		current_state = States.Jump
		run_momentum = 0
		jump_buffer_counter = 0
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
	if is_on_floor() and current_state != States.Jump and !Input.is_action_pressed("run"):
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x += direction * (SPEED/10)
			animated_sprite.flip_h = !(direction > 0)
			current_state = States.Walk
		else:
			velocity.x = lerp(velocity.x, 0.0, 0.2)
			current_state = States.Idle
			run_momentum = 0
		velocity.x = clamp(velocity.x, -SPEED, (SPEED))

func handle_run():
	if Input.is_action_pressed("run") and is_on_floor() and current_state != States.Jump:
			var direction = Input.get_axis("move_left", "move_right")
			if direction:
				velocity.x += direction * SPEED
				animated_sprite.flip_h = !(direction > 0)
				current_state = States.Run
				run_momentum += 0.08
				run_momentum = clamp(run_momentum, 0, 8)
				print(run_momentum)
			else:
				velocity.x = lerp(velocity.x, 0.0, 1)
				current_state = States.Idle
				run_momentum = 0
			velocity.x = clamp(velocity.x, -SPEED*1.75, SPEED*1.95)
			return
	
func anim_update():
	match current_state:
		States.Jump:
			animated_sprite.play("jump")
		States.Walk:
			animated_sprite.play("walk")
		States.Idle:
			animated_sprite.play("idle")
		States.Run:
			animated_sprite.play("run")
