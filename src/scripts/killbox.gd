extends Area2D

func _on_Area2D_body_entered(body):
	if(self as Area2D && body as KinematicBody2D):
		get_tree().reload_current_scene()
