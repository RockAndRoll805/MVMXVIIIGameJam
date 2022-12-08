extends EntityBase

const BUFFER_WINDOW = 8

var _frames_in_air: int = 0
var _frames_since_jump_input: int = 0
var _jump_interrupted = false
var _double_jump_able = false
var _weapon_offset: int = 1

onready var _player_weapon = $Weapon/Sprite
onready var _weapon_hitbox = $Weapon/Hitbox/Location

func _ready():
	States["DOUBLE_JUMP"] = 3
#	States["WALL"] = 4
	Events.connect("InWorldItem_collected", self, "_on_InWorldItem_collected")

func _physics_process(delta):
	add_jump_input()
	_frames_since_jump_input += 1

func take_x_input() -> float:
	return float(
		1 if Input.is_action_pressed("move_right") else -1 if Input.is_action_pressed("move_left") else 0
	)

func add_jump_input():
	velocity = .apply_speed_to_input()
	if Input.is_action_just_pressed("jump") and state != States.AIR and _frames_since_jump_input > BUFFER_WINDOW:
		velocity.y = jump_force
		_frames_since_jump_input = 0

func sprite_direction():
	.sprite_direction()
	_player_weapon.flip_h = _entity_body.flip_h
	_weapon_offset = clamp(int(left_direction) * 2 - 1, -1, 1)
	_weapon_hitbox.position.x = 40 * - _weapon_offset
#
func move_and_fall():
	.move_and_fall()
	match state:
		States.AIR:
			_entity_body.play("jump") if velocity.y < 0 else _entity_body.play("fall")
			if Input.is_action_just_released("jump"):
				_jump_interrupted = true
			if Input.is_action_just_pressed("jump"):
				if _frames_in_air < BUFFER_WINDOW:
					velocity.y = jump_force
				elif _double_jump_able:
					velocity.y = jump_force
					state = States.DOUBLE_JUMP
					continue
			_frames_in_air += 1
		States.DOUBLE_JUMP: #technically this state isn't preventing further jumps, but the later clamp on velocity.y is preventing ascent
			if Input.is_action_just_released("jump"):
				_jump_interrupted = true 
			if is_on_floor():
				state = States.FLOOR
				continue
			_frames_in_air += 1
		_: #single underscore is equiv to "default" case
			buffer_jump()
			_jump_interrupted = false
			_frames_in_air = 0
	velocity.y = clamp(velocity.y, jump_force, TERMINAL_VELOCITY) if _jump_interrupted == false else clamp(velocity.y, 0.0, TERMINAL_VELOCITY)

func buffer_jump():
	if state != States.AIR and _frames_since_jump_input < BUFFER_WINDOW:
		velocity.y = jump_force
		_frames_since_jump_input = 0

func _on_InWorldItem_collected(item_type):
	print("Item collected!")
	match item_type:
		1:
			_double_jump_able = true
		_:
			pass
