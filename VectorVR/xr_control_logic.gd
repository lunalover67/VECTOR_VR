extends XROrigin3D

var left_controller : XRController3D
var right_controller : XRController3D

var reset_toggle : bool = false


func _ready() -> void:
	left_controller = get_node("LeftController")
	right_controller = get_node("RightController")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




var start_position : Vector3 = Vector3(0, 1, 0)  # Customize this as needed
var start_rotation : Vector3 = Vector3.ZERO  # Customize this if you want to reset rotation


func reset_pressed() -> void:
	reset_toggle = true

func reset_game() -> void:
	# Reset player position and rotation (possible err- not moving usr moving child)
	self.position = start_position
	self.rotation_degrees = start_rotation
	print("Player position and rotation reset!")

	# Reset the controllers (if needed)
	left_controller.position = start_position
	right_controller.position = start_position
	left_controller.rotation_degrees = start_rotation
	right_controller.rotation_degrees = start_rotation
	print("Controllers reset to start position!")
