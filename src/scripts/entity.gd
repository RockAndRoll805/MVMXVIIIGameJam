class_name EntityBase
extends KinematicBody2D

enum States { IDLE, FLOOR, AIR, WALL }

const GRAVITY = 26.0
const TERMINAL_VELOCITY = 600
const FLOOR_NORMAL = Vector2.UP

export var speed = 350.0
export var jump_force = -800
export var left_direction = false
var velocity = Vector2(0.0,0.0)
var state = States.AIR
var animation: String = "fall"

onready var _entity_body = get_node("AnimatedSprite")

func _physics_process(delta):
	apply_speed_to_input()
	move_and_fall()
	sprite_direction()
	_entity_body.play(animation)

func take_x_input():
	pass

func apply_speed_to_input() -> Vector2:
	velocity.x = take_x_input()
	velocity.x *= speed
	velocity.y += GRAVITY
	return velocity

func move_and_fall():
	match state:
		States.IDLE:
			animation = "idle"
			if not is_zero_approx(velocity.x) and velocity.y >= 0:
				state = States.FLOOR
				continue
			if not is_on_floor():
				state = States.AIR
				continue
			velocity.x = 0.0
		States.FLOOR:
			animation = "run"
			if is_zero_approx(velocity.x) and velocity.y >= 0:
				state = States.IDLE
				continue
			if velocity.y != 0 and not is_on_floor():
				state = States.AIR
				continue
		States.AIR:
			animation = "fall" if velocity.y >= 0 else "jump"
			if is_on_floor():
				state = States.FLOOR
				continue
	if velocity.x > 0:
		left_direction = false
	elif velocity.x < 0:
		left_direction = true
	velocity.y = clamp(velocity.y, jump_force, TERMINAL_VELOCITY)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)

func sprite_direction():
	_entity_body.flip_h = left_direction

# interpolation for refresh rates higher than 60 fps
#func _process(delta):
#	var fps = Engine.get_frames_per_second()
#	var lerp_interval = velocity / fps
#	var lerp_position = global_transform.origin + lerp_interval
#
#	if fps > 60:
#		_entity_body.set_as_toplevel(true)
#		_entity_body.global_transform.origin = _entity_body.global_transform.origin.linear_interpolate(lerp_position, 50 * delta)
#	else:
#		_entity_body.global_transform = global_transform
#		_entity_body.set_as_toplevel(false)
