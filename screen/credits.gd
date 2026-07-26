extends Node

# Update the path if your MainMenu scene file has a different file extension (e.g. .tscn or .scn)
const MAIN_MENU_PATH := "res://screen/MainMenu.tscn"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file(MAIN_MENU_PATH)
