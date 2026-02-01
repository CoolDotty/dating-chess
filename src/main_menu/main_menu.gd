extends Node2D

const FALLING_PIECE = preload("uid://bajocrxa711er")

@onready var spawn_timer = Timer.new()
var spawn_interval = 0.15  # Change this to adjust spawn rate (in seconds)

func _ready() -> void:
	# Set up the timer
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func _on_spawn_timer_timeout() -> void:
	# Create new piece instance
	var piece = FALLING_PIECE.instantiate()
	
	# Set random x position between 0 and 1280, y at -200
	var random_x = randf_range(0, 1280)
	piece.position = Vector2(random_x, -200)
	
	# Set random angular velocity (rotation spin)
	piece.angular_velocity = randf_range(-5, 5)
	
	# Set random scale to fake depth (0.7 to 1.3 for subtle variation)
	var random_scale = randf_range(0.7, 1.3)
	piece.scale = Vector2(random_scale, random_scale)
	
	# Add to scene
	add_child(piece)
