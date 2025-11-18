extends Node3D

#@onready var camera_3d_p1 := %Camera3D_p1
@onready var viewport_controller: ViewportController = %Viewports

func _input(event):
	if event.is_action_pressed("ui_start"):
		var next_scene = Altuin.get_scene_path(Altuin.SceneName.PLAYER_SELECT)
		get_tree().change_scene_to_file(next_scene)

func _ready():
	var player_count = Sentinel.get_player_count()
	print("Number of players: ", player_count)

	for player_id in Sentinel.players.keys():
		var player = Sentinel.players[player_id]
		print("Player ID: ", player_id, " Device ID: ", player.device_id, " Name: ", player.name)
		_instantiate_player_scene(player_id)

func _instantiate_player_scene(player_id):
	var player_scene = Sentinel.get_player_character_scene(player_id)
	if player_scene:
		var player_instance = player_scene.instantiate()
		player_instance.name = 'player_%d' % player_id
		# Attach the Player.gd script
		var player_script = load("res://scripts/Player.gd")
		player_instance.set_script(player_script)
		if "player_id" in player_instance:
			player_instance.player_id = player_id
		if "player_camera" in player_instance:
			player_instance.player_camera = viewport_controller.player_cameras[player_id]
		var players_node = _get_players_node()
		players_node.add_child(player_instance)
		print("Instantiated scene for Player %d" % player_id)
	else:
		print("No character scene found for Player %d" % player_id)

func _get_players_node():
	var players_node = $Players
	if players_node == null:
		players_node = Node3D.new()
		players_node.name = "Players"
		add_child(players_node)

	return players_node
