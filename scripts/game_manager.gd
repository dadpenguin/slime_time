# game_manager.gd
extends Node

var is_win: bool = false
var total_captured: int = 0
var max_enemies: int = 0
var time_left: float = 0.0

# Reset stats when starting a fresh game
func reset_game() -> void:
	is_win = false
	total_captured = 0
	max_enemies = 0
	time_left = 0.0
