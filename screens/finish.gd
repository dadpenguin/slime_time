extends Control

const MAIN_GAME_SCENE = "res://scenes/main.tscn"
const START_MENU_SCENE = "res://screens/startMenu.tscn"

@onready var restart_button: Button =$MarginContainer/VBoxContainer/RestartButton
@onready var menu_button: Button = $MarginContainer/VBoxContainer/BackButton
@onready var results_label: Label =  $MarginContainer/VBoxContainer/ResultsLabel

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Update results text based on game outcome
	if results_label:
		if GameManager.is_win:
			# Format time_left to 1 decimal place (e.g. 5.4s)
			results_label.text = "WIN\nTime Left: " + str(snapped(GameManager.time_left, 0.1)) + "s"
		else:
			results_label.text = "LOST\nTotal Captured: " + str(GameManager.total_captured) + " / " + str(GameManager.max_enemies)

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_GAME_SCENE)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(START_MENU_SCENE)
