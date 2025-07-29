# File: Laptop.gd
extends Area3D

var player_is_near = false
@onready var interaction_prompt = $Label3D # Ganti jika nama node prompt Anda berbeda

func _ready():
	if interaction_prompt:
		interaction_prompt.visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_is_near = true
		if interaction_prompt:
			interaction_prompt.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_near = false
		if interaction_prompt:
			interaction_prompt.visible = false

func _process(delta):
	if player_is_near and Input.is_action_just_pressed("pressed_action"):
		start_interview()
			
func start_interview():
	player_is_near = false
	if interaction_prompt:
		interaction_prompt.visible = false
	
	# Ganti dengan path scene wawancara Anda
	get_tree().change_scene_to_file("res://scenes/interview/qte_interview.tscn")
