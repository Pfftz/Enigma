extends Resource
class_name LoadingPreset

## Resource for managing loading screen presets and transitions

@export var loading_timer: float = 5.0 ## Duration of the loading screen in seconds
@export var fade_color: Color = Color.WHITE ## Color to fade to during loading
@export var show_loading_text: bool = true ## Whether to show loading text
@export var loading_text: String = "Loading..." ## Text to display during loading
