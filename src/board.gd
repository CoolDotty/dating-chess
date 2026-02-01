extends Node2D

@onready var game := $RealChess as Control

signal piece_grabbed(from_square);
signal piece_dropped(from_square, to_square);

# TODO: piece is actually a square that might have a piece (this allows selecting empty squares to move to)
@export var piece: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for y_i in range(8):
	#	for x_i in range(8):
	for rank in range(8, 0, -1):
		for file in range(1, 9):
			var y_i = rank - 1
			var x_i = file - 1
			var p1 = piece.instantiate()

			var side = 47
			var x0 = side*x_i
			var y0 = side*y_i
			var x = x0*1.0 - 0.22*y0
			var y = x0*0.1 + 0.92*y0
			var z = x0*0.0 - 0.0009*y0 + 1
			p1.position = Vector2(360+1.08*x/z, 100+0.85*y/z - 10)
			p1.modulate = Color(x_i/8.0, y_i/8.0, 1)
			#p1.scale = Vector2(4,4)
			# only for classic chess pieces provided
			p1.get_node("Sprite2D").scale = Vector2(0.15,0.15)
			var area2d = p1.get_node("Area2D")
			area2d.x_i = x_i
			area2d.y_i = y_i
			area2d.piece_selected.connect(_on_piece_selected)
			area2d.piece_grabbed.connect(_on_piece_grabbed)
			area2d.piece_dropped.connect(_on_piece_dropped)
			
			# for rank in range(8, 0, -1):
			#   for file in range(1, 9):
			#
			#var file = x_i  # ???
			#var rank = y_i # ???
			#area2d.index = y_i * 8 + x_i # ???
			area2d.file = file
			area2d.rank = rank
			area2d.index = Chess.square_index(file, rank)
			print(area2d.index)
			area2d.san_name = Chess.square_get_name(area2d.index)
			
			add_child(p1)

func _on_piece_selected(x_i, y_i):
	print(x_i, y_i)
	for child in get_children():
		var area2d = child.get_node("Area2D")
		if area2d and (area2d.x_i != x_i or area2d.y_i != y_i):
			area2d.unselect()
			
func _on_piece_grabbed(idx):
	piece_grabbed.emit(idx)
	#game._on_Square_piece_grabbed(idx)
	
func _on_piece_dropped(from, to):
	piece_dropped.emit(from, to)
	#game._on_Square_piece_dropped(from, to) # silly, I know

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func setup_board(chess: Chess) -> void:
	#print(chess.pieces)
	for child in get_children():
		#print(child.scene_file_path == 'res://piece.tscn')
		if child.scene_file_path != 'res://piece.tscn': continue
		var piece_node = child
		if not piece_node: continue
		var square = piece_node.get_node("Area2D")
		var sprite = piece_node.get_node("Sprite2D")
		var piece = chess.pieces[square.index]
		if piece != null:
			var col := "b" if Chess.piece_color(piece) else "w"
			piece = piece.to_upper()
			sprite.texture = load("res://assets/tatiana/" + col + piece + ".svg")
		else:
			sprite.texture = null


func flip_board() -> void:
	var squares_flipped := []
	for child in get_children():
		var square = child.get_node("Area2D")
		if not square: continue
		squares_flipped.push_front(child)
		remove_child(child)

	for child in squares_flipped:
		add_child(child)
