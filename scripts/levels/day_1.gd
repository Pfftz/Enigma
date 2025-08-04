extends Node3D

@onready var video_player = $VideoPlayer

func _ready():
	# Check if monolog has already been played for this day
	if not GameState.is_monolog_played(1):
		# Play intro video first, then monolog
		play_intro_video()

func play_intro_video():
	if video_player:
		video_player.play_video("res://asset/videos/intro.ogv", _on_intro_video_finished)

func _on_intro_video_finished():
	# Disable the video player's camera after video finishes
	if video_player and video_player.camera_2d:
		video_player.camera_2d.enabled = false
	
	# After intro video, play monolog and mark as played
	GameState.mark_monolog_played(1)
	Dialogic.start("monolog/day1")
