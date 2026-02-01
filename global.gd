extends Node

signal music_toggled(is_playing : bool)
signal bot_turn()

var pawn_loves_you := false
var knight_loves_you := false
var bishop_loves_you := false
var rook_loves_you := false
var queen_loves_you := false

var bot_enabled := false
func bot_play_if_turn():
	if bot_enabled:
		bot_turn.emit()


func is_distance_6_or_more(from_square: int, to_square: int) -> bool:
	var rank_diff = abs(from_square / 8 - to_square / 8)
	var file_diff = abs(from_square % 8 - to_square % 8)

	# Chebyshev distance (king moves needed)
	var distance = max(rank_diff, file_diff)
	return distance >= 6

func where_white_king_at(pieces: Array):
	return pieces.rfind_custom(func(p): return p == "K")

# Not including diagonals
func get_adjacent_piece_types(target_square: int, pieces: Array) -> Array:
	var adjacent_pieces = []
	
	# left, right, up, down
	var left = target_square - 1
	var right = target_square + 1
	var up = target_square - 8
	var down = target_square + 8
	var adjacents = [left, right, up, down]
	
	for adj in adjacents:
		if adj < 0 or adj > 64:
			# Over / Under the board
			continue
		if target_square % 8 == 0 and adj == left:
			# Outside the left side
			continue
		if target_square % 8 == 7 and adj == right:
			# Outside the right side
			continue
		adjacent_pieces.append(pieces[adj])

	return adjacent_pieces


func is_char_lowercase(char: String) -> bool:
	return char == char.to_lower() and char != char.to_upper()
	
func is_white_move(move: Move) -> bool:
	return is_char_lowercase(move.piece_type)

func update_alive_checks(chess: Chess):
	Dialogic.VAR.pawn_alive = "P" in chess.pieces
	Dialogic.VAR.rook_alive = "R" in chess.pieces
	Dialogic.VAR.knight_alive = "N" in chess.pieces
	Dialogic.VAR.queen_alive = "Q" in chess.pieces
	Dialogic.VAR.bishop_alive = "B" in chess.pieces


func move_character_effects(move: Move, moves: Array, chess: Chess):
	print("move ", move.whos_turn, " ", move.did_capture, " ", move.piece_type)
	if move.whos_turn == "black":
		if not move.did_capture:
			return
		match move.did_capture:
			"K":
				Dialogic.start('King_on_death')
			"Q":
				Dialogic.start('Queen_on_death')
			"B":
				Dialogic.start('Bishop_on_death')
			"N":
				Dialogic.start('Knight_on_death')
			"R":
				Dialogic.start('Rook_on_death')
			"P":
				Dialogic.start('Pawn_on_death')
		return
	var played_piece = move.piece_type.capitalize()
	if move.did_capture:
		match played_piece:
			"K":
				Dialogic.start('King_on_capture')
			"Q":
				Dialogic.start('Queen_on_capture')
			"B":
				Dialogic.start('Bishop_on_capture')
			"N":
				Dialogic.start('Knight_on_capture')
			"R":
				Dialogic.start('Rook_on_capture')
			"P":
				Dialogic.start('Pawn_on_capture')
	match played_piece:
		"K":
			Dialogic.start('King_on_move')
		"Q":
			Dialogic.start('Queen_on_move')
		"B":
			Dialogic.start('Bishop_on_move')
		"N":
			Dialogic.start('Knight_on_move')
		"R":
			Dialogic.start('Rook_on_move')
		"P":
			Dialogic.start('Pawn_on_move')
	

func advance_challenges(move: Move, moves: Array, chess: Chess):
	if move.whos_turn == "black":
		return
	var played_piece = move.piece_type
	
	# use a rook to defeat 1 pieces
	if Dialogic.VAR.rook_challenge_1 >= 1:
		if move.piece_type == "R" and move.captured_piece:
			Dialogic.VAR.rook_challenge_1 += 1
		if Dialogic.VAR.rook_challenge_1 >= 2:
			pass
	
	# Move king adjacent to rook
	if Dialogic.VAR.rook_challenge_2 >= 1:
		var king_square = where_white_king_at(chess.pieces)
		var adjacent = get_adjacent_piece_types(king_square, chess.pieces)
		var rook_is_adjacent = adjacent.any(func(piece): return piece == "R")
		if rook_is_adjacent:
			print("HUGGGSS")
		
	
	
	# Knight defeat 3 different pieces
	if Dialogic.VAR.knight_challenge_1 >= 1:
		if move.piece_type == "N" and move.captured_piece:
			Dialogic.VAR.knight_challenge_1 += 1
		if Dialogic.VAR.knight_challenge_1 >= 4:
			pass
	
	# Knight challenge 2 undefined
	
	# SACRIFICE A BISHOP
	if Dialogic.VAR.bishop_challenge_1 >= 1:
		print(move.did_capture)
		if move.did_capture == "B":
			Dialogic.VAR.bishop_challenge_1 += 1
	
	# Bishop challenge 2 undefined
	
	# Queen move 6 spaces or more in one turn
	if Dialogic.VAR.queen_challenge_1 >= 1:
		print(is_distance_6_or_more(move.from_square, move.to_square))
		if move.piece_type == "Q" and is_distance_6_or_more(move.from_square, move.to_square):
			Dialogic.VAR.queen_challenge_1 += 1
	
	# Queen challenge 2 undefined
	
	# Pawn take two pieces
	if Dialogic.VAR.pawn_challenge_1 >= 1:
		if move.piece_type == "P" and move.captured_piece:
			Dialogic.VAR.pawn_challenge_1 += 1
		if Dialogic.VAR.pawn_challenge_1 >= 3:
			pass
	
	# Pawn challenge two undefined
