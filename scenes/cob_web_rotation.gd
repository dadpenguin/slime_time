extends AudioStreamPlayer2D

var sound_clips: Array[AudioStream] = []
var last_index: int = -1

func _ready():
	load_sounds_from_folder("res://Cobwebs") # Make sure the path matches your FileSystem tab

func load_sounds_from_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				# Filter out import files and check for audio extensions
				if file_name.ends_with(".wav") or file_name.ends_with(".ogg"):
					var full_path = folder_path + "/" + file_name
					var sound = load(full_path)
					if sound is AudioStream:
						sound_clips.append(sound)
						
			file_name = dir.get_next()

func _physics_process(_delta):
	if Input.is_action_just_pressed("shoot"):
		play_random_sound()

func play_random_sound():
	if sound_clips.is_empty():
		return

	var random_index: int = randi() % sound_clips.size()
	while sound_clips.size() > 1 and random_index == last_index:
		random_index = randi() % sound_clips.size()

	last_index = random_index
	stream = sound_clips[random_index]
	play()
