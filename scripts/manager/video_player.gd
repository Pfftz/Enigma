extends Node2D

signal video_finished

@onready var video_stream_player = $VideoStreamPlayer
@onready var camera_2d = $Camera2D

var video_path: String = ""
var callback_function: Callable

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide the video player initially
	visible = false
	
	# Connect the finished signal
	if video_stream_player:
		video_stream_player.finished.connect(_on_video_finished)

func play_video(path: String, on_finished: Callable = Callable()):
	video_path = path
	callback_function = on_finished
	
	# Create video stream
	var video_stream = VideoStreamTheora.new()
	video_stream.file = path
	
	# Set the stream and play
	video_stream_player.stream = video_stream
	video_stream_player.play()
	
	# Show video player
	visible = true
	
	# Make camera current to show the video
	camera_2d.make_current()

func _on_video_finished():
	# Hide video player
	visible = false
	
	# Emit signal
	video_finished.emit()
	
	# Call callback if provided
	if callback_function and callback_function.is_valid():
		callback_function.call()

func _input(event):
	# Allow skipping video with ESC or ENTER
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("pressed_start")):
		skip_video()

func skip_video():
	if video_stream_player.is_playing():
		video_stream_player.stop()
		_on_video_finished()
