extends Control

# Update path to match your main gameplay scene file
const MAIN_GAME_SCENE = "res://scenes/main.tscn"

@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	# Ensure the mouse cursor is visible for UI interaction
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Connect button signals
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed() -> void:
	# Load into your 3D FPS level
	get_tree().change_scene_to_file(MAIN_GAME_SCENE)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
