extends Node2D
export var INTERNAL = {"width": 40, "height": 80}
var frame = 0
var Mouse = Vector2()
var bullets = []

func _ready():
	$Player.position = Vector2(16, 62)
	$Player.play()
	$Bullet.hide()

func _process(_delta):
	frame += 1
	Mouse = get_global_mouse_position()
	update_player()
	update_bullet()

func update_player():
	var old_position = $Player.position 
	if Input.is_action_pressed("key_left") or $btn_left.pressed: $Player.position.x += -2.5
	elif Input.is_action_pressed("key_right") or $btn_right.pressed: $Player.position.x += +2.5
	if old_position.x != $Player.position.x: $Player.animation = "walk"
	else: $Player.animation = "idle"
	$Player.flip_h = bool($Player.position.x-old_position.x < 0)
	if $Player.position.x < -4 : $Player.position.x = 48
	elif $Player.position.x > 48: $Player.position.x = -4
	
func update_bullet():
	if (Input.is_action_pressed("key_space") or $btn_fire.pressed) and (frame%10 == 0):
		bullets.append($Bullet.duplicate())
		bullets[-1].position = Vector2($Player.position.x, $Player.position.y)
		bullets[-1].show()
		add_child(bullets[-1])
	for n in bullets:
		if n.position.y < 8: bullets.erase(n)
		n.position = Vector2(n.position.x, n.position.y-2.5)
