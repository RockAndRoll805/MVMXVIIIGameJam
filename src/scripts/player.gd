extends EntityBase

const BUFFER_WINDOW = 8

var _frames_in_air: int = 0
var _frames_since_jump_input: int = BUFFER_WINDOW + 1
var _jump_interrupted = false
var _weapon_offset: int = 1
var _double_jump_used = false

onready var _player_weapon = $Weapon/Sprite
onready var _weapon_hitbox = $Weapon/Hitbox/Location
onready var player_vars = get_node("/root/PlayerState")

func _ready():
	States["DOUBLE_JUMP"] = 3
#	States["WALL"] = 4
	Events.connect("InWorldItem_collected", self, "_on_InWorldItem_collected")
	global_position = player_vars.scene_entry_position

func _physics_process(delta):
	add_jump_input()
	_frames_since_jump_input += 1

func take_x_input() -> float:
	return float(
		1 if Input.is_action_pressed("move_right") else -1 if Input.is_action_pressed("move_left") else 0
	)

func add_jump_input():
	velocity = .apply_speed_to_input()
	if Input.is_action_just_pressed("jump"):
		if state != States.AIR and _frames_since_jump_input > BUFFER_WINDOW:
			velocity.y = jump_force
		_frames_since_jump_input = 0

func sprite_direction():
	.sprite_direction()
	_player_weapon.flip_h = _entity_body.flip_h
	_weapon_offset = clamp(int(left_direction) * 2 - 1, -1, 1)
	_weapon_hitbox.position.x = 40 * - _weapon_offset

# overwriting apply speed function to add floatiness
func apply_speed_to_input() -> Vector2:
	velocity.x = take_x_input()
	velocity.x *= speed
	if(velocity.y >= -300
	and velocity.y <= 300):
		velocity.y += GRAVITY/4
	else:
		velocity.y += GRAVITY
	return velocity

func move_and_fall():
	.move_and_fall()
	match state:
		
		States.AIR:
			_entity_body.play("jump") if velocity.y < 0 else _entity_body.play("fall")
			
			if Input.is_action_just_released("jump"):
				_jump_interrupted = true
				velocity.y = max(velocity.y, -100.0)
				# reset buffer window on release so short hops dont get buffered
				_frames_since_jump_input = BUFFER_WINDOW + 1
				
			# coyote jump
			if(Input.is_action_just_pressed("jump")
			and velocity.y > 0
			and _frames_since_jump_input < BUFFER_WINDOW
			and not _jump_interrupted):
				velocity.y = jump_force
				
			# double jump
			elif(Input.is_action_just_pressed("jump")
			and player_vars.double_jump_able
			and not _double_jump_used):
				velocity.y = jump_force
				_double_jump_used = true
				_jump_interrupted = false
					
			_frames_in_air += 1
			
		States.FLOOR:
			buffer_jump()
			_jump_interrupted = false
			_double_jump_used = false
			_frames_in_air = 0

func buffer_jump():
	if state != States.AIR and _frames_since_jump_input < BUFFER_WINDOW:
		velocity.y = jump_force
		_frames_since_jump_input = 0

func _on_InWorldItem_collected(item_type):
	match item_type:
		1:
			player_vars.double_jump_able = true
			player_vars.scene_entry_position = Vector2(1054.0, 1780.0)
		_:
			pass
