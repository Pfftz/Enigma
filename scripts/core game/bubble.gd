extends Node2D

# (DITAMBAHKAN KEMBALI) Variabel untuk menampung sampel suara Anda.
@export var typing_sounds: Array[AudioStream]

# Variabel untuk menyimpan kalimat yang berhubungan dengan bubble ini.
var positive_affirmation: String

var initial_y_position: float
var time: float = 0.0
# (DIPERBAIKI) Nilai agar bubble mengambang dengan halus tapi tetap terlihat.
var float_speed: float = 0.5 
var float_amplitude: float = 10.0

func _ready():
	initial_y_position = position.y
	time = randf() * 10.0

# (DIKEMBALIKAN) Fungsi agar bubble mengambang.
func _process(delta):
	time += delta
	position.y = initial_y_position + sin(time * float_speed) * float_amplitude

# Fungsi baru untuk mengatur teks pada bubble.
func setup(positive: String):
	positive_affirmation = positive
	$TypingLabel.text = positive_affirmation

# (DIPERBAIKI) Fungsi untuk memberikan feedback saat mengetik.
func play_typing_feedback():
	if not $Sprite2D.visible:
		return

	# Mainkan animasi squish.
	$AnimationPlayer.play("squish")
	# Mainkan suara secara acak dari array.
	if not typing_sounds.is_empty():
		$AudioStreamPlayer2D.stream = typing_sounds.pick_random()
		$AudioStreamPlayer2D.play()

# Fungsi untuk meledakkan bubble.
func pop():
	# Sembunyikan semua elemen visual.
	$Sprite2D.hide()
	$TypingLabel.hide()

	# Mainkan efek partikel.
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

	# Set timer untuk respawn.
	var respawn_timer = get_tree().create_timer(2.0)
	respawn_timer.timeout.connect(_reset_bubble)

# Fungsi untuk memunculkan kembali bubble.

# Fungsi untuk memunculkan kembali bubble.
func _reset_bubble():
	# (FIX) Atur skala ke nol SEBELUM menampilkannya agar tidak berkedip.
	$Sprite2D.scale = Vector2.ZERO
	# Tampilkan kembali sprite dan label.
	$Sprite2D.show()
	$TypingLabel.show()
	# Aktifkan kembali collision.
	# Kita tidak menggunakan Area2D lagi, jadi baris ini bisa dihapus atau dikomentari.
	# $Area2D/CollisionShape2D.disabled = false 
	# (BARU) Mainkan animasi respawn.
	$AnimationPlayer.play("respawn")
