#####################
## Name: vechten   ##
## Author: @whmsft ##
## version: v1b5   ##
## commit: 25      ##
#####################

extends Node2D # Why is it necessary? IDK!

# variables for internal mechanics
var FPS = 0
var SCREEN = Vector2(0,0)
var MOUSE = Vector2()
var player_bullet_timer = 0
var enemy_bullet_timer = 0
var timer_limit = 0.2
var framer = [0,0]

# variables related actual Gameplay
var SCORE = 0
var LIVES = 5
var player_bullets = []
var enemy_bullets  = []

func _ready():
	# Get Screen info
	SCREEN.x = get_viewport().get_visible_rect().size.x
	SCREEN.y = get_viewport().get_visible_rect().size.y
	
	# Position everything
	$btn_fire.set_global_position(Vector2(SCREEN.x -9, SCREEN.y -9))
	$btn_left.set_global_position(Vector2(1, SCREEN.y -9))
	$btn_right.set_global_position(Vector2(10, SCREEN.y -9))
	$Player.position = Vector2(16, SCREEN.y -18)
	$Enemy.position = Vector2(16, 9)

	# Make things ready for gameplay
	$Player.play()
	$Enemy.play()
	$Bullet.hide()
	$EnemyBullet.hide()
	
	#$Background_music.play() # Silence for now...

func _process(_delta):
	FPS = Engine.get_frames_per_second()
	MOUSE = get_global_mouse_position()
	if !(LIVES < 0):
		$ScoreLabel.text = "Score: "+str(SCORE)
		$LivesLabel.text = "Lives: "+str(LIVES)
		update_player(_delta)
		update_enemy(_delta)
		update_pbullet(_delta)
		update_ebullet(_delta)
	else:
		$Player.stop()
		$Enemy.stop()

func _input(event):
	var Event = make_input_local(event)
	if (Event) and (LIVES < 0):
		if Event.pressed:
			LIVES = 5

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
	# Assign a temp variable
	var old_position = $Player.position 

	# Check for motion
	if Input.is_action_pressed("key_left") or $btn_left.is_pressed(): $Player.position.x += -192*_delta
	elif Input.is_action_pressed("key_right") or $btn_right.is_pressed(): $Player.position.x += +192*_delta

	# Update animation
	if old_position.x != $Player.position.x: $Player.animation = "walk"
	elif Input.is_action_pressed("key_space") or $btn_fire.is_pressed(): $Player.animation = "fire"
	else: $Player.animation = "idle"
	$Player.flip_h = bool($Player.position.x-old_position.x < 0)
	
	# Screen bounds
	if $Player.position.x < -4 : $Player.position.x = 36
	elif $Player.position.x > 36: $Player.position.x = -4
	

# Player Bullet Handler
func update_pbullet(_delta):
	# Trigger and stuffs
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
	
	# Loop for bullets
	for n in player_bullets:
		n.position = Vector2(n.position.x, n.position.y-128*_delta)
		if n.position.y < 8:
			player_bullets.erase(n)
			n.queue_free()
		if collision([n.position.x, n.position.y, 8, 4], [$Enemy.position.x, $Enemy.position.y, 8, 8]):
			SCORE += 1
			player_bullets.erase(n)
			n.queue_free()

# Enemy Bullet Handler
func update_ebullet(_delta):
	# As creation is handled by Sprite itself, There's only Loop here
	for n in enemy_bullets:
		n.position = Vector2(n.position.x, n.position.y+128*_delta)
		if n.position.y > SCREEN.y-12:
			enemy_bullets.erase(n)
			n.queue_free()
		if collision([n.position.x, n.position.y, 8, 4], [$Player.position.x, $Player.position.y, 8, 8]):
			LIVES += -1
			$ScoreLabel.text = "Click to continue"
			enemy_bullets.erase(n)
			n.queue_free()

# Collision implement because I'm too lazy to use CollisionShape2D (LOL!)
# https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection
func collision(hitbox, hitbox2): # Each is a list of [x, y, width, height]
	return (hitbox[0] < hitbox2[0] + hitbox2[2] and
			hitbox[0] + hitbox[2] > hitbox2[0] and
			hitbox[1] < hitbox2[1] + hitbox2[3] and
			hitbox[1] + hitbox[3] > hitbox2[1])
