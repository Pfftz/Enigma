extends Node2D

signal popped(position)

# (MODIFIKASI) Pisahkan suara untuk mengetik dan meledak.
@export var typing_sounds: Array[AudioStream]
@export var pop_sound: AudioStream

var positive_affirmation: String
var initial_y_position: float
var time: float = 0.0
var float_speed: float = 0.5
var float_amplitude: float = 10.0

func _ready():
	add_to_group("trap_bubbles")
	initial_y_position = position.y
	time = randf() * 10.0

func _process(delta):
	time += delta
	position.y = initial_y_position + sin(time * float_speed) * float_amplitude

func setup(thought_text: String, type_word: String):
	positive_affirmation = type_word
	$TypingLabel.text = type_word
	$ThoughtLabel.text = thought_text

func play_typing_feedback():
	if not $Sprite2D.visible:
		return
	$AnimationPlayer.play("squish")
	if not typing_sounds.is_empty():
		# Gunakan AudioStreamPlayer2D yang lama untuk mengetik.
		$AudioStreamPlayer2D.stream = typing_sounds.pick_random()
		$AudioStreamPlayer2D.play()

# (FIX TOTAL) Fungsi ini sekarang membuat pemutar suara sementara.
func pop():
	# 1. Buat pemutar suara baru saat itu juga.
	if pop_sound:
		var sound_player = AudioStreamPlayer2D.new()
		sound_player.stream = pop_sound
		sound_player.global_position = self.global_position
		# 2. Tambahkan ke scene utama agar tidak ikut terhapus bersama balon.
		get_parent().add_child(sound_player)
		sound_player.play()
		# 3. Suruh pemutar suara untuk menghapus dirinya sendiri SETELAH suaranya selesai.
		sound_player.finished.connect(sound_player.queue_free)
		
	# Sisa dari fungsi ini berjalan seperti biasa.
	$Sprite2D.hide()
	$TypingLabel.hide()
	$ThoughtLabel.hide()

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

	popped.emit(self.global_position)
	
	# Balon tetap menghapus dirinya sendiri seperti biasa.
	queue_free()

func play_spawn_animation():
	$Sprite2D.scale = Vector2.ZERO
	$AnimationPlayer.play("respawn")
