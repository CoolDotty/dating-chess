extends Sprite2D

var love_level: float = 0.0

@onready var fill: Sprite2D = $Fill
@onready var jar: Sprite2D = $Jar
@onready var hearts: Sprite2D = $Hearts

var on_screen: bool = false

var start_pos: Vector2
var off_pos: Vector2

var fill_amount: float = 0.0

func _ready():
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	start_pos = position
	off_pos = position + Vector2(115, 0)
	position = off_pos


func _process(float) -> void:
	fill.material.set("shader_parameter/fill_percentage", fill_amount)
	jar.material.set("shader_parameter/fill_percentage", fill_amount)
	hearts.material.set("shader_parameter/fill_percentage", fill_amount)
	
	var weight = 0.1
	if not on_screen:
		position = lerp(position, off_pos, weight)
		return
	position = lerp(position, start_pos, weight)
	
	if not Dialogic.current_timeline:
		return
	
	var piece = Dialogic.current_timeline_name.get_slice("_", 0)
	match piece:
		"King":
			fill_amount = lerp(fill_amount, pow(Dialogic.VAR.king_love / 10.0, 0.75), weight)
		"Bishop":
			fill_amount = lerp(fill_amount, pow(Dialogic.VAR.bishop_love / 10.0, 0.75), weight)
		"Knight":
			fill_amount = lerp(fill_amount, pow(Dialogic.VAR.knight_love / 10.0, 0.75), weight)
		"Pawn":
			fill_amount = lerp(fill_amount, pow(Dialogic.VAR.pawn_love / 10.0, 0.75), weight)
		"Rook":
			fill_amount = lerp(fill_amount, pow(Dialogic.VAR.rook_love / 10.0, 0.75), weight)
		"Queen":
			fill_amount = lerp(fill_amount, pow(Dialogic.VAR.queen_love / 10.0, 0.75), weight)


func _on_timeline_started():
	fill_amount = 0
	on_screen = true
	
	
func _on_timeline_ended():
	on_screen = false
