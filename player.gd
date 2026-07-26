extends CharacterBody3D

# Path to your finish screen scene
const FINISH_SCREEN_PATH = "res://screens/finish.tscn"

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003
const CAPTURE_RANGE: float = 3.5 # Maximum distance to capture

@onready var head: Node3D = $Head
@onready var ray_cast: RayCast3D = $Head/RayCast3D # Make sure your RayCast3D is here!

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var score: int = 0
var total_enemies: int = 0

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    
    # Automatically count all enemies in the scene at start
    # Make sure your enemy nodes belong to the "enemies" group!
    total_enemies = get_tree().get_nodes_in_group("enemies").size()
    print("Total enemies to capture: ", total_enemies)

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

# Left-click input handler
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        try_capture()

func try_capture() -> void:
    ray_cast.force_raycast_update()
    
    if ray_cast.is_colliding():
        var hit_object = ray_cast.get_collider()
        var distance = global_position.distance_to(hit_object.global_position)
        
        if distance <= CAPTURE_RANGE:
            if hit_object.has_method("get_captured"):
                # get_captured() returns true only if it wasn't captured before
                var was_new_capture: bool = hit_object.get_captured()
                
                if was_new_capture:
                    score += 1
                    print("New Capture! Score: ", score, "/", total_enemies)
                    
                    # Trigger win condition when score hits total enemy count
                    if score >= total_enemies and total_enemies > 0:
                        finish_game()

func finish_game() -> void:
    print("All enemies captured! Switching to finish screen...")
    # Release the mouse so the player can interact with UI buttons
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    
    # Load the finish screen
    get_tree().change_scene_to_file(FINISH_SCREEN_PATH)
