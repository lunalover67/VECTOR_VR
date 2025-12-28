extends Node3D

var vector_velocity_x : Node3D
var vector_velocity_y : Node3D
var vector_velocity_z : Node3D
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
	vector_velocity_x = get_node("velocity_X")
	vector_velocity_y = get_node("velocity_Y")
	vector_velocity_z = get_node("velocity_Z")
	ball = get_node("Ball")

func set_velocity_colours() -> void:
	
	# X-axis (Red)
	var red : StandardMaterial3D = StandardMaterial3D.new()
	red.albedo_color = Color(1, 0, 0)
	var rodX = vector_velocity_x.get_node("Rod") as MeshInstance3D #.get_mesh()
	rodX.set_surface_override_material(0, red)
	var coneX = vector_velocity_x.get_node("Cone") as MeshInstance3D
	coneX.set_surface_override_material(0, red)
	
	# Y-axis (Green)
	var green : StandardMaterial3D = StandardMaterial3D.new()
	green.albedo_color = Color(0, 1, 0)
	var rodY = vector_velocity_y.get_node("Rod") as MeshInstance3D #.get_mesh()
	rodY.set_surface_override_material(0, green)
	var coneY = vector_velocity_y.get_node("Cone") as MeshInstance3D
	coneY.set_surface_override_material(0, green)	
	

	# Z-axis (Blue)
	var blue : StandardMaterial3D = StandardMaterial3D.new()
	blue.albedo_color = Color(0, 0, 1)
	var rodZ = vector_velocity_z.get_node("Rod") as MeshInstance3D #.get_mesh()
	rodZ.set_surface_override_material(0, blue)
	var coneZ = vector_velocity_z.get_node("Cone") as MeshInstance3D
	coneZ.set_surface_override_material(0, blue)	

func process_vectors(delta: float) -> void:
	
	# velocity vectors
	vector_velocity_x.global_transform.origin = ball.global_transform.origin
	vector_velocity_y.global_transform.origin = ball.global_transform.origin
	vector_velocity_z.global_transform.origin = ball.global_transform.origin

	var ball_velocity : Vector3 = ball.linear_velocity 
	
	var lerp_speed := 10.0

# X vector
	var target_x := ball_velocity.x * vector_scale
	vector_velocity_x.scale.y = lerp(vector_velocity_x.scale.y, target_x, lerp_speed * delta)

	# Y vector
	var target_y := ball_velocity.y * vector_scale
	vector_velocity_y.scale.y = lerp(vector_velocity_y.scale.y, target_y, lerp_speed * delta)

# Z vector
	var target_z := ball_velocity.z * vector_scale
	vector_velocity_z.scale.y = lerp(vector_velocity_z.scale.y, target_z, lerp_speed * delta)
