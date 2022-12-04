extends EntityBase

onready var hitbox = $CollisionShape2D

func _ready():
	velocity = Vector2(1.0, 0.0)

func _physics_process(delta):
	if left_direction == false and is_on_wall():
		velocity.x = -1
		left_direction = true
	elif left_direction == true and is_on_wall():
		velocity.x = 1
		left_direction = false
	update_hitbox_offset(left_direction)

func take_x_input():
	return clamp(velocity.x, -1, 1)

func update_hitbox_offset(direction):
	if direction == false:
		hitbox.position.x = 6
	else:
		hitbox.position.x = -6
