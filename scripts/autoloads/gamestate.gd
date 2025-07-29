# File: GameState.gd
extends Node

var current_day: int = 1
var total_score: int = 0

# Daftar path scene kamar untuk setiap hari
var room_scenes: Array[String] = [
	"res://scenes/rooms/kamar/ruang1test.tscn",
	"res://scenes/rooms/kamar/ruang2test.tscn",
	"res://scenes/rooms/kamar/ruang3test.tscn",
	"res://scenes/rooms/kamar/ruang4test.tscn",
	"res://scenes/rooms/kamar/ruang5test.tscn"
]

func advance_to_next_day() -> void:
	current_day += 1

func add_to_total_score(score: int):
	total_score += score

func get_current_room_scene() -> String:
	var day_index = current_day - 1
	if day_index < room_scenes.size():
		return room_scenes[day_index]
	else:
		return room_scenes.back()

func reset_progress() -> void:
	current_day = 1
	total_score = 0
