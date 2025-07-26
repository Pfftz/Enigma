extends Marker3D
class_name SpawnPoint

@export var spawn_id: int = 0
@export var spawn_direction: int = 2 # Direction player should face when spawning

func _ready() -> void:
    # Check if player should spawn here
    if Global.player_spawn_info.size() >= 2:
        if Global.player_spawn_info[1] == spawn_id:
            spawn_player_here()

func spawn_player_here() -> void:
    var player = get_tree().get_first_node_in_group("player")
    if player:
        player.global_position = global_position
        if player.has_method("set_direction"):
            player.set_direction(spawn_direction)
        print("Player spawned at spawn point: ", spawn_id)