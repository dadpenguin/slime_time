extends CharacterBody3D

# Path to your finish screen scene
const FINISH_SCREEN_PATH = "res://screens/finish.tscn"

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003
const CAPTURE_RANGE: float = 3.5

@onready var head: Node3D = $Head
@onready var ray_cast: RayCast3D = $Head/RayCast3D

# UI Reference (Make sure your Label has 'Access as Unique Name' enabled)
@onready var timer_label: Label = $"../HUD/%TimerLabel"

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var score: int = 0
var total_enemies: int = 0

# Countdown Timer variables
var time_left: float = 25.0
var game_over: bool = false

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    
    GameManager.reset_game()
    
    total_enemies = get_tree().get_nodes_in_group("enemies").size()
    GameManager.max_enemies = total_enemies
    print("Total enemies to capture: ", total_enemies)

func _process(delta: float) -> void:
    if game_over:
        return
        
    # Tick down the timer
    time_left -= delta
    if time_left <= 0.0:
        time_left = 0.0
        finish_game(false) # Timer ran out -> LOST
    
    # Update the on-screen HUD timer label
    if timer_label:
        timer_label.text = "Time Left: " + str(snapped(time_left, 0.1)) + "s"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_capture()

func try_capture() -> void:
    if game_over:
        return

    ray_cast.force_raycast_update()
    
    if ray_cast.is_colliding():
        var hit_object = ray_cast.get_collider()
        var distance = global_position.distance_to(hit_object.global_position)
        
        if distance <= CAPTURE_RANGE:
            if hit_object.has_method("get_captured"):
                var was_new_capture: bool = hit_object.get_captured()
                
                if was_new_capture:
                    score += 1
                    print("New Capture! Score: ", score, "/", total_enemies)
                    
                    if score >= total_enemies and total_enemies > 0:
                        finish_game(true)

func finish_game(won: bool) -> void:
    game_over = true
    
    GameManager.is_win = won
    GameManager.total_captured = score
    GameManager.time_left = time_left
    
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    get_tree().change_scene_to_file(FINISH_SCREEN_PATH)
