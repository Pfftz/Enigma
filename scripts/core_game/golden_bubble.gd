extends Node2D

signal ultimate_bubble_popped

# Pastikan path ini sesuai dengan lokasi file gambar Anda.
const CIRCLE_EMPTY = preload("res://asset/2d/core game/Bulet emas.png")
const CIRCLE_FILLED = preload("res://asset/2d/core game/Bulet emas fill.png")

@export var typing_sounds: Array[AudioStream]

var spam_needed: int = 0
var current_spam: int = 0

# Variabel untuk efek membesar.
var initial_scale: Vector2 = Vector2.ONE
@export var max_scale_multiplier: float = 2.0

@onready var indicator_container = $SpamIndicatorContainer
@onready var sprite = $Sprite2D

var initial_y_position: float
var time: float = 0.0

func _ready():
	# (DIHAPUS) Baris ini dihapus agar warna bisa diatur sepenuhnya dari editor.
	# sprite.modulate = Color.GOLD
	
	initial_y_position = position.y
	time = randf() * 10.0
	
	for child in indicator_container.get_children():
		child.queue_free()
	
	for i in range(spam_needed):
		var indicator = TextureRect.new()
		indicator.texture = CIRCLE_EMPTY
		indicator.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		indicator_container.add_child(indicator)

func _process(_delta):
	pass # Bubble emas tidak mengambang.

func setup(spam_count: int):
	spam_needed = spam_count
	current_spam = 0
	
func register_spam():
	if current_spam >= spam_needed:
		return

	# Perbarui indikator visual.
	var indicator_to_fill = indicator_container.get_child(current_spam)
	if indicator_to_fill is TextureRect:
		indicator_to_fill.texture = CIRCLE_FILLED
	
	current_spam += 1
	
	# (MODIFIKASI TOTAL) Gunakan Tween untuk membuat animasi membesar yang halus.
	var progress = float(current_spam) / float(spam_needed)
	var target_scale = initial_scale.lerp(initial_scale * max_scale_multiplier, progress)
	
	# Buat tween baru untuk menganimasikan properti 'scale'.
	var tween = create_tween()
	# Animasikan 'scale' dari ukuran saat ini ke target_scale selama 0.1 detik.
	tween.tween_property(sprite, "scale", target_scale, 0.1).set_trans(Tween.TRANS_SINE)
	
	# Mainkan suara secara langsung tanpa memanggil animasi "squish"
	if not typing_sounds.is_empty():
		$AudioStreamPlayer2D.stream = typing_sounds.pick_random()
		$AudioStreamPlayer2D.play()

	if current_spam >= spam_needed:
		# Beri jeda sedikit sebelum meledak agar pemain bisa melihatnya besar.
		await get_tree().create_timer(0.2).timeout
		pop()

# Fungsi ini tetap ada jika diperlukan di tempat lain, tapi tidak dipanggil saat spam.
func play_typing_feedback():
	if not sprite.visible:
		return
	$AnimationPlayer.play("squish")
	if not typing_sounds.is_empty():
		$AudioStreamPlayer2D.stream = typing_sounds.pick_random()
		$AudioStreamPlayer2D.play()

func pop():
	sprite.hide()
	indicator_container.hide()

	var particles_instance = $GPUParticles2D.duplicate()
	get_parent().add_child(particles_instance)
	particles_instance.global_position = global_position
	particles_instance.emitting = true
	var particle_timer = Timer.new()
	particle_timer.wait_time = particles_instance.lifetime
	particle_timer.one_shot = true
	particle_timer.timeout.connect(particles_instance.queue_free)
	particles_instance.add_child(particle_timer)
	particle_timer.start()

	ultimate_bubble_popped.emit()
	queue_free()

func play_spawn_animation():
	sprite.scale = Vector2.ZERO
	$AnimationPlayer.play("respawn")
	# (BARU) Tunggu animasi selesai untuk menyimpan skala awal yang benar.
	await $AnimationPlayer.animation_finished
	initial_scale = sprite.scale
