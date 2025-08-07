class_name GameManager extends Node

var players: Dictionary = {}
var player_device_map: Dictionary = {}

func _ready():
    GlobalSignals.player_added.connect(self._on_player_added)
    GlobalSignals.player_device_changed.connect(self._on_player_device_changed)
    GlobalSignals.player_removed.connect(self._on_player_removed)
    GlobalSignals.player_paused.connect(self._on_player_paused)
    GlobalSignals.player_resumed.connect(self._on_player_resumed)

    GlobalSignals.player_health_changed.connect(self._on_player_health_changed)
    GlobalSignals.player_score_changed.connect(self._on_player_score_changed)


# Signal handlers
func _on_player_added(player_id, device_id):
    if not players.has(player_id):
        players[player_id] = {
            "device_id": device_id,
            "name": "Player %d" % player_id,
            "score": 0,
            "health": 100
        }
        player_device_map[device_id] = player_id
        print("Player %d added." % player_id)

func _on_player_device_changed(player_id, new_device_id):
    if players.has(player_id):
        player_device_map.erase(players[player_id]["device_id"])
        players[player_id]["device_id"] = new_device_id
        player_device_map[new_device_id] = player_id
        print("Player %d device changed to %d" % [player_id, new_device_id])
    else:
        print("Device change for player %d not relevant." % player_id)

func _on_player_removed(player_id):
    if players.has(player_id):
        player_device_map.erase(players[player_id]["device_id"])
        players.erase(player_id)
        print("Player %d removed." % player_id)

func _on_player_paused(player_id):
    pass

func _on_player_resumed(player_id):
    pass

# Player Gameplay signal handlers

func _on_player_health_changed(player_id, health_change):
    if players.has(player_id):
        players[player_id]["health"] += health_change
        print("Player %d health changed by %d" % [player_id, health_change])
    else:
        print("Health change for player %d not relevant." % player_id)

func _on_player_score_changed(player_id, score_change):
    if players.has(player_id):
        players[player_id]["score"] += score_change
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


# Utility functions
func get_next_player_id():
    var next_id = 0
    while players.has(next_id):
        next_id += 1
    return next_id

func get_player_by_device(device_id):
    return player_device_map.get(device_id, null)