class_name SceneTransition
extends Area2D

export(String) var _destination
export(Vector2) var _entry_coords #coords player will be moved to in destination

func _ready():
	connect("body_entered", self, "_on_body_entered")
	
func _on_body_entered(body):
	if body as KinematicBody2D:
		get_node("/root/PlayerState").scene_entry_position = _entry_coords
		get_tree().change_scene_to(load(_destination))
