extends KinematicBody2D

enum States { FLOOR, AIR, WALL }

const SPEED = 350.0
const JUMP_FORCE = -800.0
const GRAVITY = 26.0
const FLOOR_NORMAL = Vector2.UP
const TERMINAL_VELOCITY = 600
const BUFFER_WINDOW = 6

var state = States.AIR
var _direction = 1
var _velocity = Vector2(0.0,0.0)
var _frames_in_air = 0
var _frames_since_jump_input = 0
var _jump_interrupted = false

onready var _player_body = $AnimatedSprite
onready var _player_weapon = $Weapon/Sprite
onready var _weapon_hitbox = $Weapon/Hitbox/Location

func _physics_process(delta):
	apply_speed_to_input()
	set_sprite_direction()
	move_and_fall()
	_frames_since_jump_input += 1
	transition_action_state()
	if Input.is_action_just_pressed("attack_melee"):
		print("Attack!")

func take_x_input() -> float:
	return float(
		1 if Input.is_action_pressed("move_right") else -1 if Input.is_action_pressed("move_left") else 0
	)

func apply_speed_to_input() -> Vector2:
	_velocity.x = take_x_input()
	_direction = _velocity.x if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left") else _direction
	_velocity.x *= SPEED
	if Input.is_action_just_pressed("jump") and state == States.FLOOR:
		_velocity.y = JUMP_FORCE
		_frames_since_jump_input = 0
	else:
		_velocity.y += GRAVITY
	return _velocity

func set_sprite_direction():
	_player_body.flip_h = bool(clamp(- _direction, 0, 1))
	_player_weapon.flip_h = _player_body.flip_h
	_weapon_hitbox.position.x = 40 * _direction

func move_and_fall():
	match state:
		States.FLOOR:
			_player_body.play("run") if _velocity.x != 0 else _player_body.play("idle")
			_velocity = move_and_slide(_velocity, FLOOR_NORMAL)
			if not is_on_floor():
				_frames_in_air += 1
			else:
				_frames_in_air = 0
			if _frames_since_jump_input < BUFFER_WINDOW and not is_on_floor():
				state = States.AIR
			if Input.is_action_just_pressed("jump"):
				_velocity.y = JUMP_FORCE
				state = States.AIR
			_jump_interrupted = false
		States.AIR:
			_player_body.play("jump") if _velocity.y < 0 else _player_body.play("fall")
			if Input.is_action_just_released("jump"):
				_velocity.y += GRAVITY
				_jump_interrupted = true
			_velocity.y = clamp(_velocity.y, JUMP_FORCE, TERMINAL_VELOCITY) if _jump_interrupted == false else clamp(_velocity.y, 0.0, TERMINAL_VELOCITY)
			_velocity = move_and_slide(_velocity, FLOOR_NORMAL)

func transition_action_state():
	match state:
		States.FLOOR:
			if not is_on_floor() and _frames_in_air > BUFFER_WINDOW:
				state = States.AIR
		States.AIR:
			if is_on_floor():
				state = States.FLOOR

# interpolation for refresh rates higher than 60 fps
func _process(delta):
	var fps = Engine.get_frames_per_second()
	var lerp_interval = _velocity / fps
	var lerp_position = global_transform.origin + lerp_interval
	
	if fps > 60:
		_player_body.set_as_toplevel(true)
		_player_body.global_transform.origin = _player_body.global_transform.origin.linear_interpolate(lerp_position, 50 * delta)
	else:
		_player_body.global_transform = global_transform
		_player_body.set_as_toplevel(false)
