class_name UpgradeCollectable
extends Area2D

enum ItemType { NONE, DOUBLE_JUMP }

export(Texture) var item_texture 
export(Script) var upgrade_item
var item_type = ItemType.NONE

func _ready():
	$Sprite.texture = item_texture
	set_script(upgrade_item)

func _on_InWorldItem_body_entered(body):
	Events.emit_signal("InWorldItem_collected", item_type)
	queue_free()
