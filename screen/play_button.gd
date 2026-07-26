extends TextureButton# Use 'extends TextureButton' if using TextureButton

func _on_button_down():
	print("Button pressed!")
	self_modulate = Color(0.5, 0.5, 0.5, 1.0)

func _on_button_up():
	print("Button released!")
	self_modulate = Color(1.0, 1.0, 1.0, 1.0)
