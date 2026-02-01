extends RigidBody2D

func _ready():
	var children = get_children()
	if children.size() > 0:
		var random_child = children[randi() % children.size()]
		random_child.visible = true

func _process(delta):
	if position.y > 2000:
		queue_free()
