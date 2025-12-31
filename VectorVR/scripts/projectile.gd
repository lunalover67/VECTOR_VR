extends Node3D

var velocity_vectors : Node3D
var vector_velocity_x : Node3D
var vector_velocity_y : Node3D
var vector_velocity_z : Node3D
var vector_velocity_resultant : Node3D

var vector_gravity: Node3D

var ball : XRToolsPickable

@export var vector_scale : int = 1.5

var is_paused: bool = false
var pause_label: Label3D
var frozen_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	initialize_nodes()
	set_velocity_colours()
	create_pause_hud()

func create_pause_hud() -> void:
	# Create label as a child of the camera for HUD effect
	pause_label = Label3D.new()
	pause_label.text = "[TIME PAUSED]"
	pause_label.font_size = 48
	pause_label.outline_size = 8
	pause_label.modulate = Color(1, 0, 0, 1)  # Red color
	pause_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pause_label.visible = false
	
	# Position it in front of camera (will be updated in _process)
	pause_label.position = Vector3(0, 0.3, -1.5)  # Above center, 1.5m away
	
	# Find the camera and attach label to it
	var camera = get_node("/root/Main/user/XROrigin3D/XRCamera3D")
	if camera:
		camera.add_child(pause_label)
	else:
		# Fallback: add to scene root
		add_child(pause_label)

func _process(delta: float) -> void:
	if not is_paused:
		process_vectors(delta)
		pause_label.visible = false
	else:
		display_frozen_vectors()
		pause_label.visible = true

# Rest of your code stays the same...
func display_frozen_vectors() -> void:
	velocity_vectors.visible = true
	vector_gravity.visible = true
	velocity_vectors.global_position = ball.global_position
	vector_gravity.global_position = ball.global_position

func initialize_nodes() -> void:
	vector_velocity_x = get_node("velocities/velocity_X")
	vector_velocity_y = get_node("velocities/velocity_Y")
	vector_velocity_z = get_node("velocities/velocity_Z")
	vector_velocity_resultant = get_node("velocities/velocity_RESULTANT")
	velocity_vectors = get_node("velocities")
	vector_gravity = get_node("forces/force_GRAVITY")
	ball = get_node("Ball")

func set_velocity_colours() -> void:
	
	# X-axis (Red)
	var red : StandardMaterial3D = StandardMaterial3D.new()
	red.albedo_color = Color.RED
	var rodX = vector_velocity_x.get_node("Rod") as MeshInstance3D #.get_mesh()
	rodX.set_surface_override_material(0, red)
	var coneX = vector_velocity_x.get_node("Cone") as MeshInstance3D
	coneX.set_surface_override_material(0, red)
	
	# Y-axis (Green)
	var green : StandardMaterial3D = StandardMaterial3D.new()
	green.albedo_color = Color.GREEN
	var rodY = vector_velocity_y.get_node("Rod") as MeshInstance3D #.get_mesh()
	rodY.set_surface_override_material(0, green)
	var coneY = vector_velocity_y.get_node("Cone") as MeshInstance3D
	coneY.set_surface_override_material(0, green)	
	

	# Z-axis (Blue)
	var blue : StandardMaterial3D = StandardMaterial3D.new()
	blue.albedo_color = Color.BLUE
	var rodZ = vector_velocity_z.get_node("Rod") as MeshInstance3D #.get_mesh()
	rodZ.set_surface_override_material(0, blue)
	var coneZ = vector_velocity_z.get_node("Cone") as MeshInstance3D
	coneZ.set_surface_override_material(0, blue)	

	# resultant (orange)
	var orange : StandardMaterial3D = StandardMaterial3D.new()
	orange.albedo_color = Color.ORANGE
	var rodRes = vector_velocity_resultant.get_node("Rod") as MeshInstance3D
	rodRes.set_surface_override_material(0, orange)
	var coneRes = vector_velocity_resultant.get_node("Cone") as MeshInstance3D
	coneRes.set_surface_override_material(0, orange)	
	
	
	# FORCES ---
	
		# resultant (orange)
	var purple : StandardMaterial3D = StandardMaterial3D.new()
	purple.albedo_color = Color.PURPLE
	var rodGrav = vector_gravity.get_node("Rod") as MeshInstance3D
	rodGrav.set_surface_override_material(0, purple)
	var coneGrav = vector_gravity.get_node("Cone") as MeshInstance3D
	coneGrav.set_surface_override_material(0, purple)	
	
	


func process_vectors(delta: float) -> void:
	# Make sure vectors are visible when not paused
	velocity_vectors.visible = true
	vector_gravity.visible = true
	
	# Position all vectors at the ball's location
	velocity_vectors.global_position = ball.global_position
	vector_gravity.global_position = ball.global_position
	
	var ball_velocity : Vector3 = ball.linear_velocity 
	var lerp_speed : float = 10.0

	# ===== COMPONENT VECTORS (X, Y, Z) =====
	# These show individual velocity components along each world axis
	
	# X component (side-to-side motion)
	var target_x : float = ball_velocity.x * vector_scale
	vector_velocity_x.scale.y = lerp(vector_velocity_x.scale.y, target_x, lerp_speed * delta)

	# Y component (up/down motion)
	var target_y : float = ball_velocity.y * vector_scale
	vector_velocity_y.scale.y = lerp(vector_velocity_y.scale.y, target_y, lerp_speed * delta)

	# Z component (forward/back motion)
	var target_z : float = ball_velocity.z * vector_scale
	vector_velocity_z.scale.y = lerp(vector_velocity_z.scale.y, target_z, lerp_speed * delta)

	# ===== RESULTANT VECTOR (total velocity) ===== <--------------------------- claude below
	# This shows the actual direction and magnitude of movement
	
	if ball_velocity.length() > 0.01:  # Only show if there's actual velocity
		var magnitude = ball_velocity.length()
		var target_scale_y = magnitude * vector_scale
		
		# STEP 1: Reset transform to remove any inherited rotations
		# This ensures we start from a clean slate (identity = no rotation)
		vector_velocity_resultant.transform = Transform3D.IDENTITY
		vector_velocity_resultant.scale.y = target_scale_y
		
		# STEP 2: Get the direction we want to point (normalized = length of 1)
		var velocity_normalized = ball_velocity.normalized()
		
		# STEP 3: Build a complete rotation basis
		# A basis needs 3 perpendicular axes (x, y, z) to define a 3D rotation
		var target_basis = Basis()
		
		# Set Y axis to point in velocity direction (our arrow points up in +Y)
		target_basis.y = velocity_normalized
		
		# STEP 4: Calculate the other two axes (X and Z) so they're perpendicular
		# We use the cross product which gives us a vector perpendicular to both inputs
		
		if abs(velocity_normalized.y) < 0.99:
			# Normal case: velocity is mostly horizontal
			# Cross with world UP to get a perpendicular X axis
			target_basis.x = velocity_normalized.cross(Vector3.UP).normalized()
			# Cross X with Y to get Z (completes the perpendicular trio)
			target_basis.z = target_basis.x.cross(velocity_normalized).normalized()
		else:
			# Edge case: velocity points nearly straight up/down
			# Using UP would cause issues (can't cross a vector with itself)
			# So we use RIGHT instead as our reference
			target_basis.z = velocity_normalized.cross(Vector3.RIGHT).normalized()
			target_basis.x = velocity_normalized.cross(target_basis.z).normalized()
		
		# STEP 5: Apply the rotation
		vector_velocity_resultant.basis = target_basis
		
		# STEP 6: Reapply scale (setting basis can affect scale)
		vector_velocity_resultant.scale = Vector3(1.0, target_scale_y, 1.0)
		
	else:
		# No velocity - shrink arrow to invisible
		vector_velocity_resultant.scale.y = lerp(vector_velocity_resultant.scale.y, 0.0, lerp_speed * delta)
		vector_velocity_resultant.scale.x = 1.0
		vector_velocity_resultant.scale.z = 1.0
	
	
	# ===== FORCES =====
	
	# Gravity force vector (Fg = mg)
	# Note: This just scales, doesn't rotate (gravity always points down)
	var target_grav : float = ball.mass * ball.gravity_scale * vector_scale
	vector_gravity.scale.y = lerp(vector_gravity.scale.y, target_grav, lerp_speed * delta)
