extends Control

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("send_message"):
		get_tree().change_scene_to_file("res://Gameplay.tscn")
