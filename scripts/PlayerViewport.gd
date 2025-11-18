class_name PlayerViewport extends Node

## Programmatically builds a player viewport configuration
## Includes: SubViewportContainer -> SubViewport -> [UI Control, Camera3D]

var ui_scene: PackedScene = preload("res://scenes/UI.tscn")
var subviewport_container: SubViewportContainer
var subviewport: SubViewport
var camera: Camera3D
var ui_control: Control

## Default viewport dimensions
var viewport_width: int = 1280
var viewport_height: int = 720
var subviewport_width: int = 640
var subviewport_height: int = 720

## Camera transform defaults
var camera_position: Vector3 = Vector3(-0.826057, 5.04316, 12)
var camera_rotation_degrees: Vector3 = Vector3(-26.57, 0, 0)  # Approximate from transform

func _ready() -> void:
	build_viewport()

func build_viewport() -> void:
	# Create SubViewportContainer
	subviewport_container = SubViewportContainer.new()
	subviewport_container.name = "SubViewportContainer_1"
	subviewport_container.set_size(Vector2(viewport_width, viewport_height))
	add_child(subviewport_container)
	
	# Create SubViewport
	subviewport = SubViewport.new()
	subviewport.name = "SubViewport"
	subviewport.handle_input_locally = false
	subviewport.size = Vector2i(subviewport_width, subviewport_height)
	subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	subviewport_container.add_child(subviewport)
	
	# Add UI Control
	ui_control = ui_scene.instantiate()
	ui_control.name = "Control"
	# ui_control.set_size(Vector2(subviewport_width, 0))  # Width constrained, height auto
	subviewport.add_child(ui_control)
	
	# Create Camera3D
	camera = Camera3D.new()
	camera.name = "player_camera3D"
	camera.unique_name_in_owner = true
	camera.position = camera_position
	camera.rotation_degrees = camera_rotation_degrees
	subviewport.add_child(camera)

## Configure viewport dimensions (call before _ready or in parent)
func set_viewport_size(size: Vector2i) -> void:
	viewport_width = size.x
	viewport_height = size.y

## Configure subviewport dimensions (call before _ready or in parent)
func set_subviewport_size(size: Vector2i) -> void:
	subviewport_width = size.x
	subviewport_height = size.y

func set_subviewport_position(position: Vector2i) -> void:
	if subviewport_container:
		subviewport_container.position = position

## Configure camera transform (call before _ready or in parent)
func set_camera_transform(pos: Vector3, rot_degrees: Vector3) -> void:
	camera_position = pos
	camera_rotation_degrees = rot_degrees

## Get reference to the camera for external control
func get_camera() -> Camera3D:
	return camera

## Get reference to the subviewport
func get_subviewport() -> SubViewport:
	return subviewport

## Get reference to the container
func get_container() -> SubViewportContainer:
	return subviewport_container

## Update viewport layout at runtime
func update_layout(container_rect: Rect2) -> void:
	if subviewport_container:
		subviewport_container.position = container_rect.position
		subviewport_container.set_size(container_rect.size)

## Update subviewport size at runtime (useful for split-screen resizing)
func update_subviewport_size(new_size: Vector2i) -> void:
	if subviewport:
		subviewport.size = new_size
		if ui_control:
			ui_control.set_size(Vector2(new_size.x, 0))
