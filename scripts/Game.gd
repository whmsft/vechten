extends Node2D
export var INTERNAL = {"width": 40, "height": 80}
var Mouse = Vector2()

func _ready():
	$Player.position = Vector2(16, 62)

func _process(_delta):
	var Mouse = get_global_mouse_position()
	update_player()

func update_player():
	var old_position = $Player.position 
	if Input.is_action_pressed("key_left") or $btn_left.pressed: $Player.position.x += -2.5
	elif Input.is_action_pressed("key_right") or $btn_right.pressed: $Player.position.x += +2.5
	if old_position.x != $Player.position.x: $Player.animation = "walk"
	else: $Player.animation = "idle"
	$Player.flip_h = bool($Player.position.x-old_position.x < 0)
	if $Player.position.x < -4 : $Player.position.x = 48
	elif $Player.position.x > 48: $Player.position.x = -4
