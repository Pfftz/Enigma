extends Node

# Warp-related signals
signal scene_transition_started
signal scene_transition_finished
signal warp_triggered(warp_id: int, scene_path: String)

# Piece collection signals
signal piece_collected(piece_count: int)
