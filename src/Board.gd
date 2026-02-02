extends Node2D

#@onready var game := $RealChess as Control
@onready var game: ChessGame = $".."

signal piece_grabbed(from_square);
signal piece_dropped(from_square, to_square);

var black_color = Color(0.2,0.23,0.25);

func new_piece(file, rank):
	var y_i = rank - 1
	var x_i = file - 1
	var p1 = piece.instantiate()

	var side = 47
	var x0 = side*x_i
	var y0 = side*(7 - y_i)
	var x = x0*1.0 - 0.22*y0
	var y = x0*0.1 + 0.92*y0
	var z = -x0*0.0000 - 0.00087*y0 + 1
	p1.position = Vector2(355+1.1*x/z, 100+0.8*y/z - 10)
	
	#p1.modulate = Color(x_i/8.0, y_i/8.0, 1)
	#p1.scale = Vector2(4,4)
	# only for classic chess pieces provided
	#p1.get_node("Sprite2D").scale = Vector2(0.15,0.15)
	p1.get_node("Sprite2D").scale = Vector2(0.08,0.08)/z*0.8
	var area2d = p1.get_node("Area2D")
	area2d.x_i = x_i
	area2d.y_i = y_i
	area2d.piece_selected.connect(_on_piece_selected)
	area2d.piece_grabbed.connect(_on_piece_grabbed)
	area2d.piece_dropped.connect(_on_piece_dropped)

	area2d.file = file
	area2d.rank = rank
	
	add_child(p1)
	return area2d

# TODO: piece is actually a square that might have a piece (this allows selecting empty squares to move to)
@export var piece: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for y_i in range(8):
	#	for x_i in range(8):
	# draw order 1
	for rank in range(8, 0, -1):
		for file in range(8, 0, -1):
	# draw order 2
	#for rank in range(1, 9):
	#	for file in range(1, 9):
			var area2d = new_piece(file, rank)
			area2d.index = Chess.square_index(file, rank)
			area2d.san_name = Chess.square_get_name(area2d.index)

# NO YOU DONT! We have a board already filled with pieces, so you just gotta
# highlight already placed pieces instead of creating new ones
#func add_dummy_piece(idx):
	#print("adding dummy piece at ", idx)
	#var file = idx / 8;
	#var rank = idx % 8; # probably
	#var area2d = new_piece(file, rank)

func _on_piece_selected(x_i, y_i):
	for child in get_children():
		if child.name == "Sprite2D":
			continue
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

# An array to keep track what textures to unmark later
var movesMarked = [];
func unmark_moves():
	for child in get_children():
		if child.scene_file_path != 'res://piece.tscn': continue
		var square = child.get_node("Area2D")
		var sprite = child.get_node("Sprite2D")
		for x in movesMarked:
			var pieceIdx = x[0]
			var oldTexture = x[1]
			if square.index == pieceIdx:
				if square.target_selector:
					sprite.texture = oldTexture

			if square.black:
				sprite.modulate = black_color
			else:
				sprite.modulate = Color.WHITE
		#if square.index in movesMarked:
			#sprite.texture
	movesMarked.clear()

func mark_possible_moves(from_idx, ids):
	unmark_moves();
	
	# first find out what the previous piece was
	var oldSprite;
	var oldSquare;
	for child in get_children():
		if child.scene_file_path != 'res://piece.tscn': continue
		var square = child.get_node("Area2D")
		var sprite = child.get_node("Sprite2D")
		if square.index == from_idx:
			oldSprite = sprite;
			oldSquare = square;
			square.target_selector = false;

	# then mark possible moves using the same piece but of slightly weaker color
	for child in get_children():
		if child.scene_file_path != 'res://piece.tscn': continue
		var square = child.get_node("Area2D")
		var sprite = child.get_node("Sprite2D")
		if square.index not in ids:
			continue
		movesMarked.append([square.index, sprite.texture]);
		#var piece = chess.pieces[square.index]
		if piece != null:
			#var col := "w" #"b" if Chess.piece_color(piece) else "w"
			#var piece = "Q"
			#piece = piece.to_upper()
			sprite.texture = oldSprite.texture #load("res://assets/tatiana/" + col + piece + ".svg")
			sprite.modulate = Color.YELLOW_GREEN
			square.target_selector = true;
			square.target_selector_from = from_idx;
			square.black = oldSquare.black
		else:
			sprite.texture = null

# TODO: ^ mark_possible moves would look sorta like setup_board
func setup_board(chess: Chess) -> void:
	for child in get_children():
		if child.scene_file_path != 'res://piece.tscn': continue
		var square = child.get_node("Area2D")
		var sprite = child.get_node("Sprite2D")
		var piece = chess.pieces[square.index]
		if piece != null:
			var col := "b" if Chess.piece_color(piece) else "w"
			piece = piece.to_upper()
			#sprite.texture = load("res://assets/tatiana/" + col + piece + ".svg")
			sprite.texture = load("res://assets/cool_pieces/" + piece + ".png")
			#sprite.scale = Vector2(0.1,0.1)
			# TODO: col as effect
			if col == "b":
				square.black = true
				sprite.modulate = black_color;
			else:
				square.black = false
		else:
			sprite.texture = null


# TODO: flipping doesn't work (try simply reversing y coordinate!)
func flip_board() -> void:
	var squares_flipped := []
	for child in get_children():
		var square = child.get_node("Area2D")
		if not square: continue
		squares_flipped.push_front(child)
		remove_child(child)

	for child in squares_flipped:
		add_child(child)
