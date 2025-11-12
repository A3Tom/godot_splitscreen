extends Node

# Player Config Signals
signal player_added(player_id)
signal player_device_changed(player_id, device_id)
signal player_removed(player_id)
signal player_paused(player_id)
signal player_resumed(player_id)

# Player Gameplay Signals
signal player_health_changed(player_id, health_change)
signal player_score_changed(player_id, score_change)
signal player_died(player_id)
signal player_respawned(player_id, position)
signal player_level_up(player_id, new_level)
signal player_ability_used(player_id, ability_name)
signal player_item_collected(player_id, item_name)

# Character Selection Signals
signal character_selection_hover(player_id, character_id)
signal player_character_changed(player_id, character_id)

# Game Signals
signal game_started()
signal game_paused()
signal game_resumed()
signal register_playable_character(character_name, scene)
