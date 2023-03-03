#####################
## Name: vechten   ##
## Author: @whmsft ##
## version: v1b3   ##
## commit: 22      ##
#####################

extends Node2D

# variables for internal mechanics
var FPS = 0
var SCREEN = Vector2(0,0)
var MOUSE = Vector2()
var timer = 0
var timer_limit = 0.2
var framer = [0,0]

# variables related to game
var SCORE = 0
var bullets = []

func _ready():
	SCREEN.x = get_viewport().get_visible_rect().size.x
	SCREEN.y = get_viewport().get_visible_rect().size.y
	$btn_fire.set_global_position(Vector2(SCREEN.x -9, SCREEN.y -9))
	$btn_left.set_global_position(Vector2(1, SCREEN.y -9))
	$btn_right.set_global_position(Vector2(10, SCREEN.y -9))
	$Player.position = Vector2(16, SCREEN.y -18)
	$Player.play()
	$Bullet.hide()
	$Enemy.position = Vector2(16, 4)
	$Enemy.play()

func _process(_delta):
	FPS = Engine.get_frames_per_second()
	$FPS_label.text = "Score:"+str(SCORE)
	MOUSE = get_global_mouse_position()
	update_player(_delta)
	update_enemy(_delta)
	update_bullet(_delta)

func update_enemy(_delta):
	if framer[0] > [241,181,121][randi()%3]: 
		framer[0] = 0
		framer[1] = (randi() %3)
	else: framer[0] += 1
	var e = $Enemy.position
	if framer[1] == 0: e.x += -96*_delta; elif framer[1] == 1: e.x += +96*_delta; elif framer[1] == 2: e.x += 0
	if e.x != $Enemy.position.x: $Enemy.animation = "walk"
	else: $Enemy.animation = "idle"
	$Enemy.flip_h = bool($Enemy.position.x-e.x < 0)
	if e.x < -4 : e.x = 36; elif e.x > 36: e.x = -4
	$Enemy.position.x = e.x

func update_player(_delta):
	var old_position = $Player.position 
	if Input.is_action_pressed("key_left") or $btn_left.is_pressed(): $Player.position.x += -192*_delta
	elif Input.is_action_pressed("key_right") or $btn_right.is_pressed(): $Player.position.x += +192*_delta
	if old_position.x != $Player.position.x: $Player.animation = "walk"
	elif Input.is_action_pressed("key_space") or $btn_fire.is_pressed(): $Player.animation = "fire"
	else: $Player.animation = "idle"
	$Player.flip_h = bool($Player.position.x-old_position.x < 0)
	if $Player.position.x < -4 : $Player.position.x = 36
	elif $Player.position.x > 36: $Player.position.x = -4
	
func update_bullet(_delta):
	if (Input.is_action_pressed("key_space") or $btn_fire.is_pressed()):
		timer += _delta
		if (timer > timer_limit):
			timer -= timer_limit
			bullets.append($Bullet.duplicate())
			bullets[-1].position = Vector2($Player.position.x, $Player.position.y)
			bullets[-1].animation = "fire"
			bullets[-1].show()
			bullets[-1].play()
			add_child(bullets[-1])
	for n in bullets:
		n.position = Vector2(n.position.x, n.position.y-128*_delta)
		if n.position.y < 8:
			bullets.erase(n)
			n.queue_free()
		if (n.position.x > $Enemy.position.x and n.position.x < $Enemy.position.x + 8) and (n.position.y > 4 and n.position.y < 12):
			SCORE += 1
			bullets.erase(n)
			n.queue_free()
