class_name GameManager extends Node

@export var max_players: int = 2

var players: Dictionary = {}
var player_device_map: Dictionary = {}
var player_character_map: Dictionary = {}
var playable_characters: Dictionary = {}

func _ready():
	GlobalSignals.player_added.connect(self._on_player_added)
	GlobalSignals.player_device_changed.connect(self._on_player_device_changed)
	GlobalSignals.player_character_changed.connect(self._on_player_character_changed)
	GlobalSignals.character_selection_hover.connect(self._on_character_selection_hover_changed)
	GlobalSignals.player_removed.connect(self._on_player_removed)
	GlobalSignals.player_paused.connect(self._on_player_paused)
	GlobalSignals.player_resumed.connect(self._on_player_resumed)

	GlobalSignals.player_health_changed.connect(self._on_player_health_changed)
	GlobalSignals.player_score_changed.connect(self._on_player_score_changed)

	GlobalSignals.register_playable_character.connect(self._on_register_playable_character)


# Signal handlers
func _on_player_added(player_id, device_id):
	if not players.has(player_id):
		players[player_id] = Player.new(device_id, "Player %d" % player_id)
		player_device_map[device_id] = player_id
		var device_detail = Input.get_joy_name(device_id)
		print("Device %d (%s) added for Player %d." % [device_id, device_detail, player_id])

func _on_player_device_changed(player_id, new_device_id):
	if players.has(player_id):
		player_device_map.erase(players[player_id].device_id)
		players[player_id].device_id = new_device_id
		player_device_map[new_device_id] = player_id
		print("Player %d device changed to %d" % [player_id, new_device_id])
	else:
		print("Device change for player %d not relevant." % player_id)

func _on_player_character_changed(player_id, character_id):
	if players.has(player_id):
		players[player_id].character_id = character_id
		var character_name = playable_characters.get(character_id, null).name if playable_characters.has(character_id) else "Unknown"
		print("Player %d character changed to %d (%s)" % [player_id, character_id, character_name])
	else:
		print("Character change for player %d not relevant." % player_id)

func _on_character_selection_hover_changed(player_id, character_id):
	var character_name = playable_characters.get(character_id, null).name if playable_characters.has(character_id) else "Unknown"
	print("Player %d is hovering over character %d (%s)" % [player_id, character_id, character_name])

func _on_player_removed(player_id):
	if players.has(player_id):
		player_device_map.erase(players[player_id].device_id)
		players.erase(player_id)
		print("Player %d removed." % player_id)

func _on_player_paused(player_id):
	pass

func _on_player_resumed(player_id):
	pass

# Player Gameplay signal handlers

func _on_player_health_changed(player_id, health_change):
	if players.has(player_id):
		players[player_id].health += health_change
		print("Player %d health changed by %d" % [player_id, health_change])
	else:
		print("Health change for player %d not relevant." % player_id)

func _on_player_score_changed(player_id, score_change):
	if players.has(player_id):
		players[player_id].score += score_change
		print("Player %d score changed by %d" % [player_id, score_change])
	else:
		print("Score change for player %d not relevant." % player_id)

func _on_player_died(player_id):
	pass

func _on_player_respawned(player_id, position):
	pass

func _on_player_level_up(player_id, new_level):
	pass

func _on_player_ability_used(player_id, ability_name):
	pass

func _on_player_item_collected(player_id, item_name):
	pass


# Game signal handlers

func _on_game_started():
	pass

func _on_game_paused():
	pass

func _on_game_resumed():
	pass

func _on_register_playable_character(character_name, character_scene):
	var character_id = get_next_playable_character_id()
	print("Registering playable character: %s with ID %d" % [character_name, character_id])
	playable_characters[character_id] = PlayableCharacter.new(character_name, character_scene)


# Utility functions
func get_next_player_id():
	return get_next_dictionary_id(players)

func get_next_playable_character_id():
	return get_next_dictionary_id(playable_characters)

func get_next_dictionary_id(dictionary: Dictionary):
	var next_id = 0
	while dictionary.has(next_id):
		next_id += 1
	return next_id

func get_player_by_device(device_id):
	return player_device_map.get(device_id, null)

func get_device_by_player(player_id):
	return players.get(player_id, null).device_id if players.has(player_id) else -7777

func get_player_character(player_id):
	if players.has(player_id):
		return players[player_id].character_id

func get_player_count():
	return players.size()

func get_player_character_scene(player_id):
	var character_id = get_player_character(player_id)
	if character_id != null and playable_characters.has(character_id):
		return playable_characters[character_id].scene
	return null

func get_playable_characters():
	return playable_characters
