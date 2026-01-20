extends Node3D

var slow_light: MeshInstance3D
var paused_light: MeshInstance3D

var slow_material: StandardMaterial3D
var paused_material: StandardMaterial3D

var is_slowed: bool = false
var is_paused: bool = false

# Label references
var mass_label: Label3D
var gravity_label: Label3D
var v_resultant_label: Label3D
var v_x_label: Label3D
var v_y_label: Label3D
var v_z_label: Label3D
var f_g_label: Label3D
var f_n_label: Label3D
var time_scale_label: Label3D

# Ball reference
var ball: RigidBody3D

# Frozen values when paused
var frozen_velocity: Vector3 = Vector3.ZERO
var frozen_normal_force: float = 0.0
var frozen_gravity_scale: float = 1.0  # NEW: Store gravity scale when pausing

func _ready() -> void:
	initialize_lights()
	initialize_labels()
	get_ball_reference()
	
	# Connect to the XR controller signals
	var user_node = get_node("/root/Main/user")
	if user_node:
		var xr_origin = user_node.get_node("Controller")
		if xr_origin:
			xr_origin.connect("time_toggled_signal", Callable(self, "_on_time_paused"))

func initialize_lights() -> void:
	# Get the light mesh instances
	slow_light = get_node("PickableObject/slow_light")
	paused_light = get_node("PickableObject/paused_light")
	
	# Create materials for the lights
	slow_material = StandardMaterial3D.new()
	slow_material.albedo_color = Color.BLACK
	slow_material.emission_enabled = true
	slow_material.emission = Color.BLACK
	slow_material.emission_energy = 2.0
	
	paused_material = StandardMaterial3D.new()
	paused_material.albedo_color = Color.BLACK
	paused_material.emission_enabled = true
	paused_material.emission = Color.BLACK
	paused_material.emission_energy = 2.0
	
	# Apply materials to the lights
	slow_light.set_surface_override_material(0, slow_material)
	paused_light.set_surface_override_material(0, paused_material)

func initialize_labels() -> void:
	mass_label = get_node("PickableObject/mass")
	gravity_label = get_node("PickableObject/gravity")
	v_resultant_label = get_node("PickableObject/v_resultant")
	v_x_label = get_node("PickableObject/v_x")
	v_y_label = get_node("PickableObject/v_y")
	v_z_label = get_node("PickableObject/v_z")
	f_g_label = get_node("PickableObject/F_g")
	f_n_label = get_node("PickableObject/F_n")
	time_scale_label = get_node("PickableObject/time_scale")

func get_ball_reference() -> void:
	var main_node = get_node("/root/Main")
	if main_node:
		var projectile_node = main_node.get_node("projectile")
		if projectile_node:
			ball = projectile_node.get_node("Ball")

func _process(_delta: float) -> void:
	# Check slow time state from Engine
	var current_slow_state = Engine.time_scale < 1.0
	if current_slow_state != is_slowed:
		is_slowed = current_slow_state
		update_slow_light()
	
	# Update labels with live data
	if ball:
		# Store frozen values when pausing
		if not is_paused:
			frozen_velocity = ball.linear_velocity
			frozen_normal_force = calculate_normal_force()
			frozen_gravity_scale = ball.gravity_scale  # NEW: Store gravity scale
		
		update_labels()
	
	# Update time scale label
	update_time_scale_label()

func update_labels() -> void:
	# Mass (constant)
	mass_label.text = "m = " + format_value(ball.mass) + " kg"
	
	# Gravity - use frozen value when paused
	var g_scale = frozen_gravity_scale if is_paused else ball.gravity_scale
	var g_value = g_scale * 9.8
	gravity_label.text = "g = " + format_value(g_value) + " m/s²"
	
	# Use frozen or live values depending on pause state
	var velocity = frozen_velocity if is_paused else ball.linear_velocity
	var normal_force = frozen_normal_force if is_paused else calculate_normal_force()
	
	# Velocities
	v_resultant_label.text = "V  = " + format_value(velocity.length()) + " m/s"
	v_x_label.text = "Vx = " + format_value(velocity.x) + " m/s"
	v_y_label.text = "Vy = " + format_value(velocity.y) + " m/s"
	v_z_label.text = "Vz = " + format_value(velocity.z) + " m/s"
	
	# Force of gravity - use frozen gravity scale
	var f_gravity = ball.mass * g_scale * 9.8
	f_g_label.text = "Fg = " + format_value(f_gravity) + " N"
	
	# Normal force
	f_n_label.text = "Fn = " + format_value(normal_force) + " N"

func format_value(value: float) -> String:
	# Round to 1 decimal place
	var rounded = round(value * 10.0) / 10.0
	
	# If it's a whole number, show as int
	if rounded == floor(rounded):
		return str(int(rounded))
	else:
		return str(rounded)

func calculate_normal_force() -> float:
	# Check if ball is on a surface using raycast
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		ball.global_position,
		ball.global_position + Vector3.DOWN * 0.15
	)
	query.exclude = [ball]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var surface_normal = result.normal
		# Use frozen gravity scale when paused
		var g_scale = frozen_gravity_scale if is_paused else ball.gravity_scale
		var gravity_magnitude = ball.mass * g_scale * 9.8
		var normal_magnitude = gravity_magnitude * surface_normal.dot(Vector3.UP)
		
		if normal_magnitude > 0.1:
			return normal_magnitude
	
	return 0.0

func update_slow_light() -> void:
	if is_slowed:
		slow_material.albedo_color = Color.CYAN
		slow_material.emission = Color.CYAN
	else:
		slow_material.albedo_color = Color.BLACK
		slow_material.emission = Color.BLACK

func update_paused_light() -> void:
	if is_paused:
		paused_material.albedo_color = Color.ORANGE
		paused_material.emission = Color.ORANGE
	else:
		paused_material.albedo_color = Color.BLACK
		paused_material.emission = Color.BLACK

func _on_time_paused(paused: bool) -> void:
	is_paused = paused
	update_paused_light()
	update_time_scale_label()

func update_time_scale_label() -> void:
	var display_value: float
	
	if is_paused:
		display_value = 0.0
	elif is_slowed:
		display_value = Engine.time_scale
	else:
		display_value = 1.0
	
	time_scale_label.text = "time_scale = " + format_value(display_value)
