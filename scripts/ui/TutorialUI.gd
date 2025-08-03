# File: TutorialUI.gd
extends Control

# Signal yang akan dipancarkan saat tutorial ditutup
signal tutorial_closed

@onready var close_button: Button = $Panel/closeButton # Ganti path ini sesuai node button Anda


func _ready():
	# Hubungkan sinyal saat tombol ditekan ke fungsi _on_close_button_pressed
	close_button.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed():
	# Pancarkan signal bahwa tutorial telah ditutup
	tutorial_closed.emit()
	
	# Lanjutkan game
	get_tree().paused = false
	# Hapus scene tutorial ini dari memori
	queue_free()
