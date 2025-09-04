extends CharacterBody3D

@export_group("Player variables")
@export var player_id: int

@export_group("Movement variables")
@export var walk_speed: float = 7.0
@export var run_speed: float = 12.0
@export var jump_strength: float = 15.0
@export var gravity: float = 50.0
@export var deadzone: float = 0.2

@export_group("Camera variables")
@export var player_camera: Camera3D
var camera_yaw: float = 0.0
var camera_offset: Vector3 = Vector3(0, 5, -10)
var camera_follow_speed: float = 5.0
var camera_rotation_speed: float = 3.0

@onready var player_mesh: Node3D = $Rig
@onready var animator: AnimationTree = $AnimationTree

const ANIMATION_BLEND: float = 7.0
const LERP_VALUE: float = 0.15

var snap_vector: Vector3 = Vector3.DOWN
var movement_speed: float = walk_speed
var is_shooting: bool = false
var is_run_toggled: bool = false
var is_running: bool = false
var device_id: int = -7777

func _ready():
	GlobalSignals.player_device_changed.connect(_on_player_device_changed)
	GlobalSignals.player_removed.connect(_on_player_removed)
	device_id = Sentinel.get_device_by_player(player_id)

func _physics_process(delta):
	handle_movement(delta)
	handle_camera(delta)
	apply_floor_snap()
	move_and_slide()
	animate(delta)

func _input(event):
	if !is_listenable_input_event(event):
		return

	if event.is_action_pressed("shoot"):
		is_shooting = true

	if event.is_action_pressed("jump"):
		handle_jump()

	if event.is_action_pressed("run"):
		is_running = true
	elif event.is_action_released("run"):
		is_running = false
		
	if event.is_action_pressed("toggle_run"):
		is_run_toggled = !is_run_toggled

func _on_player_device_changed(_player_id: int, new_device_id: int):
	if player_id == _player_id:
		device_id = new_device_id

func _on_player_removed(_player_id: int):
	if player_id == _player_id:
		device_id = -7777

func is_listenable_input_event(event: InputEvent) -> bool:
	if event.device != device_id:
		return false

	return event is InputEventJoypadButton or event is InputEventJoypadMotion

func calculate_movement_speed():
	if is_running or is_run_toggled:
		return run_speed
	else:
		return walk_speed

func handle_camera(delta):
	var joy_right_x = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X)
	if abs(joy_right_x) > deadzone:
		camera_yaw += joy_right_x * camera_rotation_speed * delta
	#else:
		#if Input.is_action_pressed("camera_rotate_left"):
			#self.camera_yaw -= self.camera_rotation_speed * delta
		#if Input.is_action_pressed("camera_rotate_right"):
			#self.camera_yaw += self.camera_rotation_speed * delta

	var rotated_offset = self.camera_offset.rotated(Vector3.UP, camera_yaw)
	var desired_position = global_transform.origin + rotated_offset
	player_camera.global_transform.origin = player_camera.global_transform.origin.lerp(desired_position, self.camera_follow_speed * delta)
	player_camera.look_at(global_transform.origin, Vector3.UP)

func handle_movement(delta):
	var move_input: Vector3 = Vector3.ZERO
	var joy_left_x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	var joy_left_y = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
	var use_controller = abs(joy_left_x) > deadzone or abs(joy_left_y) > deadzone
	if use_controller:
		move_input.x = joy_left_x
		move_input.z = joy_left_y
	
	## Use keyboard input
	#move_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#move_input.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	#if move_input.length() > 0:
		#print("Movement input from keyboard (device_id: -1)")

	var move_direction: Vector3 = Vector3.ZERO
	var cam_basis = player_camera.global_transform.basis
	move_direction = (cam_basis.x * move_input.x + cam_basis.z * move_input.z)
	move_direction.y = 0
	move_direction = move_direction.normalized()
	
	if move_direction.length() > 0.01:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(move_direction.x, move_direction.z), LERP_VALUE)

	movement_speed = calculate_movement_speed()
	velocity.x = move_direction.x * movement_speed
	velocity.z = move_direction.z * movement_speed
	velocity.y -= gravity * delta

func handle_jump():
	if is_on_floor():
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO

		if snap_vector == Vector3.ZERO:
			snap_vector = Vector3.DOWN

func animate(delta):
	if is_on_floor():
		animator.set("parameters/ground_air_transition/transition_request", "grounded")
		
		if is_shooting:
			if (!animator.get("parameters/shoot_oneshot/active")):
				animator.set("parameters/shoot_oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				is_shooting = false
		else:
			if velocity.length() > 0:
				if movement_speed == run_speed:
					animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
				else:
					animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
			else:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
	else:
		animator.set("parameters/ground_air_transition/transition_request", "air")
