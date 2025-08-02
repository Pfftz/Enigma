# File: Kamar.gd (atau skrip di scene kamar Anda)
extends Node3D # Atau tipe node root Anda yang lain

# Simpan path ke scene tutorial Anda
const TUTORIAL_SCENE = preload("res://scenes/ui/TutorialUI.tscn") # <-- GANTI PATH INI

func _ready():
	# Cek dua kondisi:
	# 1. Apakah ini hari pertama?
	# 2. Apakah tutorial BELUM pernah ditampilkan?
	if GameState.current_day == 1 and not GameState.tutorial_shown:
		# Jika kedua kondisi terpenuhi, tampilkan tutorial
		show_tutorial()
	else:
		# Jika bukan hari pertama atau tutorial sudah pernah ditampilkan, langsung jalankan dialogic
		Dialogic.start("day1")

func show_tutorial():
	# 1. Tandai bahwa tutorial sudah akan ditampilkan, agar tidak muncul lagi
	GameState.tutorial_shown = true

	# 2. Pause game
	get_tree().paused = true

	# 3. Muat dan tampilkan scene tutorial di atas scene saat ini
	var tutorial_instance = TUTORIAL_SCENE.instantiate()
	
	# 4. Hubungkan signal tutorial_closed ke fungsi yang akan menjalankan dialogic
	tutorial_instance.tutorial_closed.connect(_on_tutorial_closed)
	
	add_child(tutorial_instance)

func _on_tutorial_closed():
	# Fungsi ini dipanggil saat tutorial ditutup
	# Jalankan dialogic timeline setelah tutorial selesai
	Dialogic.start("day1")
