extends Node3D 

# MAIN.GD =========================

# Standard vr interface stuff.
var m_interfaceVr : XRInterface
var m_transformVr : Transform3D

# Reference nodes
var user_node : Node3D
var projectile_node : Node3D
var ball : RigidBody3D
var tablet : Node3D

# Time-stop variables
var stored_linear_velocity: Vector3 = Vector3.ZERO
var stored_angular_velocity: Vector3 = Vector3.ZERO
var stored_gravity_scale: float = 1.0
var stored_position: Vector3 = Vector3.ZERO
var is_time_paused: bool = false
var is_transitioning: bool = false


func _ready():
	initializeInterfaces()
	initialize_references()
	
	
# Default init function, dunno what it does.
func initializeInterfaces():
	m_interfaceVr = XRServer.find_interface("OpenXR")
	if m_interfaceVr and m_interfaceVr.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
		m_transformVr = XRServer.get_hmd_transform()
		m_interfaceVr.pose_recentered.connect(processOpenXrPoseRecentered)

func processOpenXrPoseRecentered():
	XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)

# Initializes the references to used nodes.
func initialize_references():
	user_node = get_node("user")
	projectile_node = get_node("projectile")
	ball = projectile_node.get_node("Ball")
	tablet = get_node("tablet")
		
	var xr_origin = user_node.get_node("Controller")
	xr_origin.connect("time_toggled_signal", Callable(self, "_on_time_control_pressed"))
	xr_origin.connect("teleport_ball_signal", Callable(self, "on_ball_teleport_called"))
	xr_origin.connect("teleport_tablet_signal", Callable(self, "on_tablet_teleport_called"))

func on_ball_teleport_called(right_hand_pos : Vector3):
	var new_ball_pos = right_hand_pos
	new_ball_pos.y += 0.1
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.global_position = new_ball_pos
	

func on_tablet_teleport_called(left_hand_pos : Vector3, left_hand_basis : Basis):
	var pickable = tablet.get_node("PickableObject")
	
	if pickable:
		var camera = user_node.get_node("Controller/Camera")
		
		# Create a new basis for the tablet orientation
		var tablet_basis = Basis()
		
		# Calculate direction from hand to camera (for tablet to face player)
		var to_camera = (camera.global_position - left_hand_pos).normalized()
		
		# The tablet's "up" should align with the hand's up direction (thumb direction)
		tablet_basis.y = left_hand_basis.y
		
		# The tablet's "forward" (negative Z) should point toward the camera
		# Project to_camera onto the plane perpendicular to the hand's up direction
		var forward = to_camera - to_camera.dot(tablet_basis.y) * tablet_basis.y
		if forward.length() > 0.01:
			forward = forward.normalized()
			tablet_basis.z = -forward
		else:
			tablet_basis.z = -left_hand_basis.z
		
		# Calculate the right direction (X-axis) to complete the basis
		tablet_basis.x = tablet_basis.y.cross(tablet_basis.z).normalized()
		
		# Recalculate Z to ensure orthonormality
		tablet_basis.z = tablet_basis.x.cross(tablet_basis.y).normalized()
		
		# Rotate 90 degrees to the right around the Y-axis
		var rotation_adjustment = Basis(Vector3.UP, PI/2)
		tablet_basis = tablet_basis * rotation_adjustment
		
		# Calculate offset position
		var offset_position = left_hand_pos + tablet_basis.z * -0.19 + tablet_basis.x * 0.07
		
		# Apply to the pickable object
		pickable.global_basis = tablet_basis
		pickable.global_position = offset_position
		
		# Reset velocities
		pickable.linear_velocity = Vector3.ZERO
		pickable.angular_velocity = Vector3.ZERO

func _process(_delta: float) -> void:
	# If paused and ball is picked up, update stored position
	if is_time_paused and ball and ball.is_picked_up():
		stored_position = ball.global_position

func _on_time_control_pressed(is_paused: bool):
	# Prevent overlapping pause/unpause operations
	if is_transitioning:
		return
	
	is_transitioning = true
	is_time_paused = is_paused
	
	if projectile_node:
		projectile_node.is_paused = is_paused
	
	if ball:
		if is_paused:
			# Get CURRENT position from ball right now
			var current_pos = ball.global_position
			var current_vel = ball.linear_velocity
			
			# Store everything
			stored_linear_velocity = current_vel
			stored_angular_velocity = ball.angular_velocity
			stored_gravity_scale = ball.gravity_scale
			stored_position = current_pos
			
			# Update projectile frozen velocity
			if projectile_node:
				projectile_node.frozen_velocity = current_vel
			
			# Freeze the ball in place
			ball.freeze = true
			ball.gravity_scale = 0.0
			ball.linear_velocity = Vector3.ZERO
			ball.angular_velocity = Vector3.ZERO
			
			# Force position update
			ball.global_position = current_pos
			
		else:
			# Restore position
			ball.global_position = stored_position
			
			# Unfreeze
			ball.freeze = false
			ball.gravity_scale = stored_gravity_scale
			
			# Set velocities to zero first
			ball.linear_velocity = Vector3.ZERO
			ball.angular_velocity = Vector3.ZERO
			
			# Wait for physics to settle
			await get_tree().physics_frame
			
			# Restore velocities
			ball.linear_velocity = stored_linear_velocity
			ball.angular_velocity = stored_angular_velocity
	
	is_transitioning = false
