extends CharacterBody3D

@export var SPRINT_SPEED: float = 3.5
@export var TIRED_SPEED: float = 2.5 # Slower than the player!
@export var MAX_STAMINA: float = 2.0   # Can sprint for 3 seconds
@export var FLEE_DISTANCE: float = 12.0
@export var player: Node3D

@onready var rays_node: Node3D = $Rays
@onready var ray_front: RayCast3D = $Rays/RayFront
@onready var ray_left: RayCast3D = $Rays/RayLeft
@onready var ray_right: RayCast3D = $Rays/RayRight

# Link your slime's MeshInstance3D here in the Inspector or via node path
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D	

var current_stamina: float
var is_resting: bool = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_captured: bool = false

func _ready() -> void:
	current_stamina = MAX_STAMINA

func _physics_process(delta: float) -> void:
	
	# If captured, stop physics & movement entirely
	if is_captured:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if player:
		var distance = global_position.distance_to(player.global_position)
		
		if distance < FLEE_DISTANCE:
			var current_speed: float
			
			# Stamina logic
			if not is_resting:
				current_speed = SPRINT_SPEED
				current_stamina -= delta
				if current_stamina <= 0:
					is_resting = true # Ran out of breath
			else:
				current_speed = TIRED_SPEED
				current_stamina += delta * 0.5 # Recover slowly
				if current_stamina >= MAX_STAMINA:
					is_resting = false # Rested up, can sprint again

			# Steering & movement
			var flee_dir = (global_position - player.global_position)
			flee_dir.y = 0
			var final_dir = avoid_obstacles(flee_dir.normalized())

			velocity.x = final_dir.x * current_speed
			velocity.z = final_dir.z * current_speed

			if final_dir.length() > 0.1:
				var look_target = global_position + final_dir
				if global_position.distance_squared_to(look_target) > 0.001:
					look_at(look_target, Vector3.UP)
		else:
			# Recover stamina when player drops back
			current_stamina = move_toward(current_stamina, MAX_STAMINA, delta)
			velocity.x = move_toward(velocity.x, 0, SPRINT_SPEED)
			velocity.z = move_toward(velocity.z, 0, SPRINT_SPEED)

	move_and_slide()

func avoid_obstacles(desired_dir: Vector3) -> Vector3:
	if desired_dir.length() > 0.1:
		rays_node.look_at(global_position + desired_dir, Vector3.UP)

	var steer = desired_dir

	if ray_front.is_colliding():
		if not ray_left.is_colliding():
			steer += -rays_node.global_transform.basis.z + -rays_node.global_transform.basis.x
		elif not ray_right.is_colliding():
			steer += -rays_node.global_transform.basis.z + rays_node.global_transform.basis.x
		else:
			steer += rays_node.global_transform.basis.x 
	elif ray_left.is_colliding():
		steer += rays_node.global_transform.basis.x * 0.5
	elif ray_right.is_colliding():
		steer -= rays_node.global_transform.basis.x * 0.5

	return steer.normalized()



# Called by the player's RayCast script
func get_captured() -> bool:
	# 1. If already captured, ignore subsequent clicks
	if is_captured:
		return false

	# 2. Set captured state to true
	is_captured = true
	print("Slime captured!")

	# 3. Create a unique red material and assign it to the mesh
	var red_material = StandardMaterial3D.new()
	red_material.albedo_color = Color.RED
	
	# Apply to the active mesh surface
	mesh_instance.material_override = red_material

	return true
