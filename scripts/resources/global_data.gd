extends Resource
class_name GlobalData

## Global game data resource for persistent save data

@export var gen: int = 8 ## Generation/progression level that controls game elements

func _init():
	# Initialize default values if needed
	if gen == 0:
		gen = 8
