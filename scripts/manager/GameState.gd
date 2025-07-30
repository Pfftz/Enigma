extends Node

var phantom_camera_position: Vector3 = Vector3.ZERO
var using_phantom_camera: bool = false
var current_day: int = 1

func get_current_room_scene() -> String:
    return "res://scenes/rooms/kamar/ruang1test.tscn"