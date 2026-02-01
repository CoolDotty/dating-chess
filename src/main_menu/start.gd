extends Label

var flash_count = 0
var max_flashes = 17
var target_scene = "uid://cw1fs4vp0p4tm"  # Change this to your scene path

@onready var color_rect: ColorRect = $"../ColorRect"
@onready var start: AudioStreamPlayer = $"../start"
@onready var title_2: AudioStreamPlayer = $"../Title2"

@onready var flash_timer = Timer.new()

func _ready() -> void:
	# Set up flash timer
	flash_timer.wait_time = 0.15 / 3  # Flash speed (0.15 seconds per toggle)
	flash_timer.timeout.connect(_on_flash_timer_timeout)
	add_child(flash_timer)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		start_flash()

func start_flash() -> void:
	start.play()
	flash_count = 0
	flash_timer.start()

func _on_flash_timer_timeout() -> void:
	# Toggle visibility
	visible = !visible
	flash_count += 1
	
	# After max flashes, change scene
	if flash_count >= max_flashes:
		flash_timer.stop()
		await color_rect.fade_to_black()
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file(target_scene)
