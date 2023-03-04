#####################
## Name: vechten   ##
## Author: @whmsft ##
## version: v1b4   ##
## commit: 24      ##
#####################

extends Node2D

# variables for internal mechanics
var FPS = 0
var SCREEN = Vector2(0,0)
var MOUSE = Vector2()
var player_bullet_timer = 0
var enemy_bullet_timer = 0
var timer_limit = 0.2
var framer = [0,0]

# variables related to game
var SCORE = 0
var LIVES = 5
var player_bullets = []
var enemy_bullets  = []

func _ready():
	SCREEN.x = get_viewport().get_visible_rect().size.x
	SCREEN.y = get_viewport().get_visible_rect().size.y
	$btn_fire.set_global_position(Vector2(SCREEN.x -9, SCREEN.y -9))
	$btn_left.set_global_position(Vector2(1, SCREEN.y -9))
	$btn_right.set_global_position(Vector2(10, SCREEN.y -9))
	$Player.position = Vector2(16, SCREEN.y -18)
	$Player.play()
	$Enemy.position = Vector2(16, 4)
	$Enemy.play()
	$Bullet.hide()
	$EnemyBullet.hide()

func _process(_delta):
	FPS = Engine.get_frames_per_second()
	MOUSE = get_global_mouse_position()
	if !(LIVES < 0):
		$General_label.text = "Score:"+str(SCORE)
		update_player(_delta)
		update_enemy(_delta)
		update_pbullet(_delta)
		update_ebullet(_delta)

func update_enemy(_delta):
	# A try to make enemy perform random tasks for [0.5, 1, 1.5] secs.
	if framer[0] > [0.5, 1, 1.5][randi()%3]: 
		framer[0] = 0
		framer[1] = (randi() %3)
	else: framer[0] += _delta
	
	# Assign a temp variable?
	var e = $Enemy.position
	
	# Try to do stuff(s) (walking)
	if framer[1] == 0: e.x += -96*_delta; elif framer[1] == 1: e.x += +96*_delta; elif framer[1] == 2: e.x += 0
	if e.x != $Enemy.position.x: $Enemy.animation = "walk"
	else: $Enemy.animation = "idle"
	$Enemy.flip_h = bool($Enemy.position.x-e.x < 0)
	if e.x < -4 : e.x = 36; elif e.x > 36: e.x = -4

	# Try to do stuff(s) (firing)
	if (randi() % 4 == 0):
		enemy_bullet_timer += _delta
		if (enemy_bullet_timer > timer_limit):
			enemy_bullet_timer -= timer_limit
			enemy_bullets.append($EnemyBullet.duplicate())
			enemy_bullets[-1].position = Vector2(e.x, e.y)
			enemy_bullets[-1].animation = "fire"
			enemy_bullets[-1].show()
			enemy_bullets[-1].play()
			add_child(enemy_bullets[-1])

	# Update Enemy position
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
	
func update_pbullet(_delta):
	if (Input.is_action_pressed("key_space") or $btn_fire.is_pressed()):
		player_bullet_timer += _delta
		if (player_bullet_timer > timer_limit):
			player_bullet_timer -= timer_limit
			player_bullets.append($Bullet.duplicate())
			player_bullets[-1].position = Vector2($Player.position.x, $Player.position.y)
			player_bullets[-1].animation = "fire"
			player_bullets[-1].show()
			player_bullets[-1].play()
			add_child(player_bullets[-1])
	for n in player_bullets:
		n.position = Vector2(n.position.x, n.position.y-128*_delta)
		if n.position.y < 8:
			player_bullets.erase(n)
			n.queue_free()
		if collision([n.position.x, n.position.y, 8, 4], [$Enemy.position.x, $Enemy.position.y, 8, 8]):
			SCORE += 1
			player_bullets.erase(n)
			n.queue_free()

func update_ebullet(_delta):
	for n in enemy_bullets:
		n.position = Vector2(n.position.x, n.position.y+128*_delta)
		if n.position.y > SCREEN.y-12:
			enemy_bullets.erase(n)
			n.queue_free()
		if collision([n.position.x, n.position.y, 8, 4], [$Player.position.x, $Player.position.y, 8, 8]):
			LIVES += -1
			$General_label.text = "Click to continue"
			enemy_bullets.erase(n)
			n.queue_free()

# https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection
func collision(hitbox, hitbox2):
	return (hitbox[0] < hitbox2[0] + hitbox2[2] and
			hitbox[0] + hitbox[2] > hitbox2[0] and
			hitbox[1] < hitbox2[1] + hitbox2[3] and
			hitbox[1] + hitbox[3] > hitbox2[1])
