extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if monolog has already been played for this day
	if not GameState.is_monolog_played(2):
		# If monolog hasn't been played, start it and mark as played
		GameState.mark_monolog_played(2)
		Dialogic.start("monolog/day2")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
