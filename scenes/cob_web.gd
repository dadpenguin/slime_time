extends AudioStreamPlayer

func _physics_process(_delta):
	if Input.is_action_pressed("shoot"):
		if not is_playing():
			play()
		stream_paused = false
	else:
		stream_paused = true
