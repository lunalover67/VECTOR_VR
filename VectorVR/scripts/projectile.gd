extends Node3D

var velocity_vectors : Node3D
var vector_velocity_x : Node3D
var vector_velocity_y : Node3D
var vector_velocity_z : Node3D
var vector_velocity_resultant : Node3D

var vector_gravity: Node3D

var ball : XRToolsPickable

@export var vector_scale : int = 1.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	initialize_nodes()
	set_velocity_colours()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#ball.linear_velocity = Vector3.ZERO
	process_vectors(delta)


# ----

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
	
	# velocity vectors
	velocity_vectors.global_position = ball.global_position
	vector_gravity.global_position = ball.global_position
	
	#vector_velocity_x.global_position = ball.global_position
	#vector_velocity_y.global_position = ball.global_position
	#vector_velocity_z.global_position = ball.global_position
	#vector_velocity_resultant.global_position = ball.global_position
	
	
	
	var ball_velocity : Vector3 = ball.linear_velocity 
	
	var lerp_speed : float = 10.0

# X vector
	var target_x : float = ball_velocity.x * vector_scale
	vector_velocity_x.scale.y = lerp(vector_velocity_x.scale.y, target_x, lerp_speed * delta)

	# Y vector
	var target_y : float = ball_velocity.y * vector_scale
	vector_velocity_y.scale.y = lerp(vector_velocity_y.scale.y, target_y, lerp_speed * delta)

# Z vector
	var target_z : float = ball_velocity.z * vector_scale
	vector_velocity_z.scale.y = lerp(vector_velocity_z.scale.y, target_z, lerp_speed * delta)

	# resultant vector
	
	# a) apply stretch via magnitude
	var target_resultant : float = ball_velocity.length() * vector_scale
	vector_velocity_resultant.scale.y = lerp(vector_velocity_resultant.scale.y, target_resultant, lerp_speed * delta)
	
	# b) set its orientation to match actual velocity
	
	
	
	# FORCES
	
	# gravity // Fg = mg // for some reason mass doesnt seem to affect anything actually (vector does change)
	
	var target_grav : float = ball.mass * ball.gravity_scale * vector_scale # * 9.81
	vector_gravity.scale.y = lerp(vector_gravity.scale.y, target_grav, lerp_speed * delta)
	
	
