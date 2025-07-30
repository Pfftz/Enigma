extends Node

# Warp-related signals
signal scene_transition_started
signal scene_transition_finished
signal warp_triggered(warp_id: int, scene_path: String)

# Piece collection signals
signal piece_collected(piece_count: int)

# UI-related signals
signal return_to_options
signal return_to_pause
signal return_to_title
signal pause_leave_sfx

# Game state signals
signal game_paused
signal game_unpaused
signal destroy_hud
signal destroy_pause
signal crash_game
