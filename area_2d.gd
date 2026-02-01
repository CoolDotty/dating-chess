extends Area2D

signal piece_selected(x_i, y_i);
signal piece_grabbed(from_square);
signal piece_dropped(from_square, to_square);

var x_i;
var y_i;
var file;
var rank;
var index;
var san_name;
var selected;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected = false
	#pass # Replace with function body.

func _connect_square_signals(game: ChessGame):
	piece_grabbed.connect(game._on_Square_piece_grabbed)
	piece_dropped.connect(game._on_Square_piece_dropped)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered():
	#print("entered")
	get_parent().modulate = Color.WEB_GRAY  # Highlight sprite parent

var selected_color = Color.PALE_GREEN

func _on_mouse_exited():
	if not selected:
		get_parent().modulate = Color.WHITE
	else:
		get_parent().modulate = selected_color

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		selected = true
		piece_selected.emit(x_i, y_i)
		piece_grabbed.emit(index)
		get_parent().modulate = selected_color
		#print(viewport, event, shape_idx)
		
func unselect():
	selected = false
	get_parent().modulate = Color.WHITE
