extends Node3D

var m_interfaceVr : XRInterface
var m_transformVr : Transform3D

# References to scene nodes
var user_node : Node3D
var projectile_node : Node3D
var ball : RigidBody3D

func _ready():
	initializeInterfaces()
	initialize_references()
	
func initializeInterfaces():
	m_interfaceVr = XRServer.find_interface("OpenXR")
	if m_interfaceVr and m_interfaceVr.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
		m_transformVr = XRServer.get_hmd_transform()
		m_interfaceVr.pose_recentered.connect(processOpenXrPoseRecentered)

func processOpenXrPoseRecentered():
	XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)

# NEW FUNCTION: Get references and connect signals
func initialize_references():
	user_node = get_node("user")
	projectile_node = get_node("projectile")
	ball = projectile_node.get_node("Ball")
	
	# Connect the time control signal from XROrigin3D
	var xr_origin = user_node.get_node("XROrigin3D")
	xr_origin.connect("time_toggled_signal", Callable(self, "_on_time_control_pressed"))

# NEW FUNCTION: Handle time control
func _on_time_control_pressed(is_paused: bool):
	if ball:
		ball.freeze = is_paused
		if is_paused:
			print("⏸️ Ball paused")
		else:
			print("▶️ Ball resumed")
