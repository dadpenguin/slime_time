extends TextureButton

func _on_button_down():
	# Darkens the button to 60% brightness when pressed
	self_modulate = Color(0.6, 0.6, 0.6, 1.0)

func _on_button_up():
	# Resets back to full brightness when released
	self_modulate = Color(1.0, 1.0, 1.0, 1.0)
