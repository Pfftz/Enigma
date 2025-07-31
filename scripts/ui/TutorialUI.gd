# File: TutorialUI.gd
extends Control

@onready var close_button: Button = $Panel/closeButton # Ganti path ini sesuai node button Anda


func _ready():
    # Hubungkan sinyal saat tombol ditekan ke fungsi _on_close_button_pressed
    close_button.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed():
    # Lanjutkan game
    get_tree().paused = false
    # Hapus scene tutorial ini dari memori
    queue_free()