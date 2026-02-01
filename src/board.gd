extends Node2D

# TODO: piece is actually a square that might have a piece (this allows selecting empty squares to move to)
@export var piece: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for y_i in range(8):
		for x_i in range(8):
			var p1 = piece.instantiate()

			var side = 47
			var x0 = side*x_i
			var y0 = side*y_i
			var x = x0*1.0 - 0.22*y0
			var y = x0*0.1 + 0.92*y0
			var z = x0*0.0 - 0.0009*y0 + 1
			p1.position = Vector2(360+1.08*x/z, 100+0.85*y/z - 10)
			p1.modulate = Color(x_i/8.0, y_i/8.0, 1)
			var area2d = p1.get_node("Area2D")
			area2d.x_i = x_i
			area2d.y_i = y_i
			area2d.piece_selected.connect(_on_piece_selected)
			add_child(p1)

func _on_piece_selected(x_i, y_i):
	print(x_i, y_i)
	for child in get_children():
		var area2d = child.get_node("Area2D")
		if area2d and (area2d.x_i != x_i or area2d.y_i != y_i):
			area2d.unselect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
