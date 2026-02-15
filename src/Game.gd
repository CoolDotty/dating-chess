extends Control
class_name ChessGame


var chess := Chess.new()
var engine := ChessEngine.new()

var legal_moves = null
var bot_thinking := false
var bot_thinking_thread: Thread = null

#@export  var board: ;
@onready var board := $Board as Node2D
#@onready var board = $C/V/C/V/H/Board as GridContainer
@onready var title_label := $Game/C/V/H/Title as Label
@onready var title_text := title_label.text
@onready var bot_timer := $Game/C/V/C/V/H2/BotTimer as Timer
@onready var bot_check := $Game/C/V/C/V/H2/BotCheck as CheckBox

@onready var reset_button := $Game/C/V/C/V/H2/ResetButton as Button
@onready var undo_button := $Game/C/V/C/V/H2/UndoButton as Button
@onready var bot_button := $Game/C/V/C/V/H2/BotButton as Button
@onready var fen_text := $Game/C/V/H2/FenText as LineEdit
@onready var invalid_fen := $Game/C/V/H2/InvalidFen as Label
@onready var invalid_fen_timer := $Game/C/V/H2/InvalidFenTimer as Timer

@onready var san_display := $Game/C/V/C/V/H/SanDisplay as ColorRect

@onready var move_sound: AudioStreamPlayer = $MoveSound
@onready var capture_sound: AudioStreamPlayer = $CaptureSound
@onready var check_sound: AudioStreamPlayer = $Game/CheckSound
@onready var terminal_sound: AudioStreamPlayer = $Game/TerminalSound


func _ready() -> void:
	randomize()
	get_tree().call_group("Squares", "_connect_square_signals", self)
	get_tree().call_group("Squares", "_connect_square_signals", self)
	update_state()
	var globalSignal = get_node("/root/Global")
	globalSignal.bot_turn.connect(_on_Bot_turn)
	
#func _physics_process(delta: float) -> void:
	#if not bot_thinking:
		#bot_play()

# Thread must be disposed (or "joined"), for portability.
func _exit_tree() -> void:
	if bot_thinking_thread != null:
		bot_thinking_thread.wait_to_finish()


func _on_ResetButton_pressed() -> void:
	bot_thinking = false
	bot_timer.stop()
	chess.reset()
	update_state()
	if bot_check.button_pressed and board.get_child(0).index == 63:
		# Board is flipped, play move
		bot_play(true)


func _on_FlipButton_pressed() -> void:
	board.flip_board()


func _on_UndoButton_pressed() -> void:
	bot_thinking = false
	bot_timer.stop()
	chess.undo()
	update_state()


func _on_SetFen_pressed() -> void:
	bot_thinking = false
	bot_timer.stop()
	if chess.set_fen(fen_text.text):
		update_state()
	else:
		invalid_fen.show()
		invalid_fen_timer.start()


func _on_FenText_text_entered(new_text: String) -> void:
	if bot_thinking:
		return
	if chess.set_fen(new_text):
		update_state()
	else:
		invalid_fen.show()
		invalid_fen_timer.start()


func _on_Square_piece_grabbed(from_index: int) -> void:
	if Settings.show_dests:
		var target_squares := []
		for move in legal_moves:
			if move.from_square == from_index:
				target_squares.push_back(move.to_square)
		print(target_squares)
		board.mark_possible_moves(from_index, target_squares)
		#for square in get_tree().get_nodes_in_group("Squares"):
			#if square.index in target_squares:
				#var indicator = square.get_node("LegalMoveIndicator/ColorRect")
				#if chess.pieces[square.index] == null:
					#indicator.custom_minimum_size = Vector2(15, 15)
				#else:
					#indicator.custom_minimum_size = Vector2(40, 40)
				#indicator.get_parent().show()


func _on_Square_piece_dropped(piece_name, from_index: int, to_index: int) -> void:
	# TODO: probablt should use last arguemnt
	var m := chess.construct_move(from_index, to_index, 'q', piece_name.to_lower())
	for lm in legal_moves:
		if m.from_square == lm.from_square and m.to_square == lm.to_square and m.promotion == lm.promotion:
			chess.play_move(lm)
			update_state(true)
			if bot_check.button_pressed:
				bot_play(true)
			break


func _on_InvalidFenTimer_timeout() -> void:
	invalid_fen.hide()


func _on_SettingsButton_pressed() -> void:
	$Game/SettingsMenu.popup_centered()


func _on_SettingsMenu_settings_changed() -> void:
	if board:	# Workaround for crash on startup... Probably can check for some kind of is_ready instead
		update_state()


func _on_CreditsButton_pressed() -> void:
	$Game/CreditsMenu.show()


func _on_BotButton_pressed() -> void:
	bot_play()


func _on_BotCheck_pressed() -> void:
	Global.bot_enabled = true


func _on_BotTimer_timeout() -> void:
	#bot_play()
	pass

func _on_Bot_turn(): # TODO: Connect signal
	bot_play()

func update_state(after_move := false) -> void:
	board.setup_board(chess)
	fen_text.text = chess.get_fen()
	legal_moves = chess.generate_legal_moves()
	undo_button.disabled = chess.move_stack.size() == 0

	var last_move = null
	if chess.move_stack.size() > 0:
		last_move = chess.move_stack[-1]
	if last_move:
		# HACK: after_move only true after white turn
		# SACRIFICE A BISHOP
		if Dialogic.VAR.bishop_challenge_1 >= 1:
			if last_move.did_capture == "B":
				Dialogic.VAR.bishop_challenge_1 += 1

	if last_move and after_move:
		Global.update_alive_checks(chess)
		Global.advance_challenges(last_move, chess.move_stack, chess)
		if Dialogic.current_timeline != null:
			await Dialogic.timeline_ended
		Global.move_character_effects(last_move, chess.move_stack, chess)
		if Dialogic.current_timeline != null:
			await Dialogic.timeline_ended
		

	var result := chess.get_data()
	var game_over: bool = result != Chess.RESULT.ONGOING

	var result_text := title_text
	match result:
		Chess.RESULT.ONGOING:
			pass
		Chess.RESULT.WHITEKINGDIED:
			result_text = "WHITE KING DIED OMG"
		Chess.RESULT.BLACKKINGDIED:
			result_text = "BLACK KING DIED OMG"
		Chess.RESULT.CHECKMATE:
			result_text = "%s wins by checkmate!" % ("White" if chess.turn else "Black")
			await Dialogic.timeline_ended
			if chess.turn:
				# White wins
				Dialogic.start("ending_pick")
			else:
				Dialogic.start("ending_bad")
		Chess.RESULT.STALEMATE:
			result_text = "Draw by stalemate"
		Chess.RESULT.INSUFFICIENT:
			result_text = "Draw by insufficient material"
		Chess.RESULT.FIFTY_MOVE:
			result_text = "Draw by fifty move rule"
		Chess.RESULT.SEVENTY_FIVE_MOVE:
			result_text = "Draw by seventy-five move rule"
		Chess.RESULT.THREEFOLD:
			result_text = "Draw by threefold repetition"
		Chess.RESULT.FIVEFOLD:
			result_text = "Draw by fivefold repetition"

	title_label.text = result_text

	for square in get_tree().get_nodes_in_group("Squares"):
		var piece = chess.pieces[square.index]
		if piece:
			square.grabbable = (not game_over and not bot_thinking) and Chess.piece_color(piece) == chess.turn

		var highlight := square.get_node("LastMoveHighlight") as ColorRect
		var checkIndicator := square.get_node("CheckIndicator") as ColorRect
		highlight.hide()
		checkIndicator.hide()
		if Settings.show_highlights:
			if last_move and (square.index == last_move.from_square or square.index == last_move.to_square):
				highlight.show()
			if piece in ["K", "k"] and chess.is_square_attacked(square.index, not Chess.piece_color(piece)):
				checkIndicator.show()

	san_display.update_moves(chess)

	bot_button.disabled = game_over or bot_thinking

	reset_button.disabled = bot_thinking
	undo_button.disabled = bot_thinking

	if after_move and last_move:
		#if (last_move.did_capture):
		#	print(last_move.did_capture)
			
		if Settings.sounds and OS.has_feature("threads"):
			if last_move.en_passant or last_move.captured_piece:
				capture_sound.play()
			else:
				move_sound.play()

			if result != Chess.RESULT.ONGOING:
				terminal_sound.play()
			elif Settings.sound_check:
				if last_move.notation_san[-1] == "+":
					check_sound.play()


func bot_play(with_timeout := false) -> void:
	if chess.is_game_over():
		return
	bot_thinking = true
	update_state()
	if with_timeout:
		bot_timer.start()
	else:
		if OS.has_feature("threads"):
			bot_thinking_thread = Thread.new()
			var error = bot_thinking_thread.start(bot_think)
			assert(not error)
		else:
			bot_think()


func bot_think() -> void:
	var result = engine.get_move(chess)
	call_deferred("bot_finalize", result)


func bot_finalize(result: Array) -> void:
	if OS.has_feature("threads"):
		bot_thinking_thread.wait_to_finish()
		bot_thinking_thread = null
	#print("%s  score: %d  searched: %d %d  eval: %d  time: %dms" % [result[1].notation_san, result[0],
	#		engine.num_positions_searched, engine.num_positions_searched_q, engine.num_positions_evaluated,
	#		engine.search_time / 1000.0])
	chess.play_move(result[1])
	bot_thinking = false
	bot_timer.stop()
	update_state(true)


func _on_reset_button_pressed() -> void:
	pass # Replace with function body.


func _on_flip_button_pressed() -> void:
	pass # Replace with function body.


func _on_undo_button_pressed() -> void:
	pass # Replace with function body.


func _on_bot_button_pressed() -> void:
	pass # Replace with function body.


func _on_bot_check_pressed() -> void:
	pass # Replace with function body.
