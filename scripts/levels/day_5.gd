extends Node3D

@onready var video_player = $VideoPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if monolog has already been played for this day
	if not GameState.is_monolog_played(5):
		# Play Day 5 video first, then monolog
		play_day5_video()

func play_day5_video():
	if video_player:
		video_player.play_video("res://asset/videos/Day5_intro.ogv", _on_day5_video_finished)

func _on_day5_video_finished():
	# After Day 5 video, play monolog and mark as played
	GameState.mark_monolog_played(5)
	Dialogic.start("monolog/day5")
