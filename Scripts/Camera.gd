extends Camera3D

@export var target: Node3D
@export var follow_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 5, -10)

# Camera rotation variables
var yaw: float = 0.0
@export var rotation_speed: float = 2.0

func _process(delta):
	if target:
		# Handle user input for camera rotation
		if Input.is_action_pressed("camera_rotate_left"):
			yaw -= rotation_speed * delta
		if Input.is_action_pressed("camera_rotate_right"):
			yaw += rotation_speed * delta

		# Calculate rotated offset
		var rotated_offset = offset.rotated(Vector3.UP, yaw)
		var desired_position = target.global_transform.origin + rotated_offset
		global_transform.origin = global_transform.origin.lerp(desired_position, follow_speed * delta)
		look_at(target.global_transform.origin, Vector3.UP)
