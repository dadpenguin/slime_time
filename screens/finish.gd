extends Control

const MAIN_GAME_SCENE = "res://scenes/main.tscn"
const START_MENU_SCENE = "res://screens/startMenu.tscn"

@onready var restart_button: Button = $MarginContainer/VBoxContainer/RestartButton
@onready var menu_button: Button = $MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	print("Finish screen ready.")
	print("Restart button found: ", restart_button != null)
	print("Menu button found: ", menu_button != null)
	
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)

func _on_restart_pressed() -> void:
	print("Restart button clicked!")
	var err = get_tree().change_scene_to_file(MAIN_GAME_SCENE)
	print("Scene change result code: ", err)

func _on_menu_pressed() -> void:
	print("Menu button clicked!")
	var err = get_tree().change_scene_to_file(START_MENU_SCENE)
	print("Scene change result code: ", err)
