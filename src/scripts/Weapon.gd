extends Node2D

var active_animation: String

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_swing: AnimationPlayer = $Sprite/AnimationPlayer
onready var entity_facing_left: bool = get_parent().left_direction
onready var attack_hitbox: CollisionShape2D = $Hitbox/Location
onready var swing_trail: AnimatedSprite = $Sprite/SwingTrail

func _ready():
	attack_hitbox.disabled = true

func _physics_process(delta):
	entity_facing_left = get_parent().left_direction
	swing_trail.flip_h = entity_facing_left
	if Input.is_action_just_pressed("attack_melee"):
		attack_hitbox.disabled = false
		if entity_facing_left:
			swing_trail.position.x = -6
			active_animation = "attack_melee_left"
			anim_player.play("attack_melee_left")
		else:
			swing_trail.position.x = 6
			active_animation = "attack_melee_right"
			anim_player.play("attack_melee_right")
		anim_swing.play("swing_stretch")
		swing_trail.play("swing")
		return
	

func _on_AnimationPlayer_animation_finished(active_animation):
	attack_hitbox.disabled = true
	swing_trail.frame = 0
	swing_trail.stop()
	return

func _on_Hitbox_body_entered(body: EntityBase):
	if body != get_parent():
		print("Hit ", body)
