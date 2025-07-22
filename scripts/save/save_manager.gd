extends Node

const SAVE_PATH: String = "user://savedata/"

var _data: SaveData = SaveData.new()

func _ready() -> void:
    # Create save directory if it doesn't exist
    var dir = DirAccess.open("user://")
    if not dir.dir_exists("savedata"):
        dir.make_dir("savedata")

func get_data() -> SaveData:
    return _data

func set_data(data: SaveData) -> void:
    _data = data.duplicate(true)

func load_slot(slot: int = 0) -> void:
    var save_path = SAVE_PATH + "save" + str(slot) + ".tres"
    if ResourceLoader.exists(save_path):
        _data = load(save_path)
        print("Save loaded from slot ", slot)
    else:
        print("No save found in slot ", slot)

func save_slot(slot: int = 0) -> void:
    var save_path = SAVE_PATH + "save" + str(slot) + ".tres"
    ResourceSaver.save(_data, save_path)
    print("Game saved to slot ", slot)

func new_game() -> void:
    _data = SaveData.new()
    print("New game started")

func has_save(slot: int = 0) -> bool:
    var save_path = SAVE_PATH + "save" + str(slot) + ".tres"
    return ResourceLoader.exists(save_path)