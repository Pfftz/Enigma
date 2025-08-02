extends Node2D

signal ultimate_bubble_popped

# Pastikan path ini sesuai dengan lokasi file gambar Anda.
const CIRCLE_EMPTY = preload("res://asset/2d/core game/Bulet emas.png")
const CIRCLE_FILLED = preload("res://asset/2d/core game/Bulet emas fill.png")

# (MODIFIKASI) Pisahkan suara untuk spam dan meledak.
@export var spam_sounds: Array[AudioStream]
@export var pop_sound: AudioStream

var spam_needed: int = 0
var current_spam: int = 0

# Variabel untuk efek membesar.
var initial_scale: Vector2 = Vector2.ONE
@export var max_scale_multiplier: float = 2.0

@onready var indicator_container = $SpamIndicatorContainer
@onready var sprite = $Sprite2D
# (BARU) Referensi ke pemutar suara yang sudah ada di scene.
@onready var spam_sound_player = $AudioStreamPlayer2D

var initial_y_position: float
var time: float = 0.0

func _ready():
	# sprite.modulate = Color.GOLD # Dihapus agar warna bisa diatur dari editor.
	
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
	
	# Gunakan Tween untuk membuat animasi membesar yang halus.
	var progress = float(current_spam) / float(spam_needed)
	var target_scale = initial_scale.lerp(initial_scale * max_scale_multiplier, progress)
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", target_scale, 0.1).set_trans(Tween.TRANS_SINE)
	
	# (MODIFIKASI) Mainkan suara spam dari pemutar suara yang sudah ada.
	if not spam_sounds.is_empty():
		spam_sound_player.stream = spam_sounds.pick_random()
		spam_sound_player.play()

	if current_spam >= spam_needed:
		await get_tree().create_timer(0.2).timeout
		pop()

func pop():
	# (MODIFIKASI) Mainkan suara pop menggunakan pemutar suara sementara.
	if pop_sound:
		var sound_player = AudioStreamPlayer2D.new()
		sound_player.stream = pop_sound
		sound_player.global_position = self.global_position
		get_parent().add_child(sound_player)
		sound_player.play()
		sound_player.finished.connect(sound_player.queue_free)

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
	await $AnimationPlayer.animation_finished
	initial_scale = sprite.scale
