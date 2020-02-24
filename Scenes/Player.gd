extends StaticBody2D

export var speed = 5
export var control_up = "ui_up"
export var control_down = "ui_down"
export var projectile_location = 0
export var control_shoot = ""
export var shoot_speed = 20
export var cooldown = 2
export var id = -1
export var hp = 50
export var max_hp = 50
export var do_ai = false
var opponent = null
var cooldown_timer = 2
var screen_height
var projectile
var in_game = true
var times_i_hit_someone_with_a_pizza = 0
var is_shield_on = false
var original_pos

func set_opponent(o):
	opponent = o

func _ready():
	original_pos = position
	screen_height = get_viewport_rect().size.y
	print("screen_height=%s"%screen_height)
	projectile = preload("res://Scenes/Projectile.tscn")
	get_tree().call_group("HUD", "update_values", id, hp)
	get_node("Sprite/Shield").hide()
	
func _process(delta):
	if not in_game:
		return
	if cooldown_timer > 0:
		cooldown_timer -= delta
	else:
		cooldown_timer = 0
	if do_ai:
		ai_move(delta, cooldown_timer)
		return
	var velocity_y = 0
	if Input.is_action_pressed(control_down):
		velocity_y += 1
	if Input.is_action_pressed(control_up):
		velocity_y -= 1
	position.y += velocity_y * speed 
	position.y = clamp (position.y, 0, screen_height)

func _input(event):
	# currently only handling shooting
	if event.is_action_pressed(control_shoot):
		shoot()

func update_shield():
	var shield = get_node("Sprite/Shield")
	if is_shield_on:
		shield.show()
	else:
		shield.hide()

func shoot():
	if cooldown_timer != 0:
		return
	if not in_game:
		return
	cooldown_timer = cooldown
	var node = projectile.instance()
	node.position = position
	node.id = id
	node.position.x += projectile_location
	node.speed = shoot_speed
	get_parent().add_child(node)
	print("projectile pos: %s"%node.position)
	print("player pos: %s"%position)

func projectile_collision(event_id, is_pizza):
	if event_id != id:
		if is_pizza:
			times_i_hit_someone_with_a_pizza += 1
		if times_i_hit_someone_with_a_pizza == 2:
			is_shield_on = true
			update_shield()
			times_i_hit_someone_with_a_pizza = 0
		return
	if is_shield_on:
		is_shield_on = false
		update_shield()
		return
	if not in_game:
		return
	hp -= 1
	if is_pizza:
		hp -= 1
	get_tree().call_group("HUD", "update_values", id, hp)
	$Explosion.show()
	var t = Timer.new()
	t.set_wait_time(0.3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	$Explosion.hide()

func _on_game_ended():
	hide()
	in_game = false
	position = original_pos

func _on_game_restart():
	is_shield_on = false
	times_i_hit_someone_with_a_pizza = 0
	update_shield()
	show()
	hp = max_hp
	get_tree().call_group("HUD", "update_values", id, hp)
	in_game = true
	cooldown_timer = cooldown

func ai_move(delta, cooldown_timer_local):
	if opponent == null:
		print("opponent is null")
		return
	var velocity_y = 0
	var return_value = cooldown_timer_local
	if position.y < opponent.position.y:
		velocity_y += 1
	elif position.y > opponent.position.y:
		velocity_y -= 1
	if randi()%5+1 == 1:
		position.y += velocity_y * speed
	if randi()%5+1 == 1 and ((position.y < opponent.position.y + 30) and (position.y > opponent.position.y - 30)):
		if in_game and (cooldown_timer_local == 0):
			shoot()
			cooldown_timer = cooldown
	if randi()%10+1 == 1 and not ((position.y < opponent.position.y + 30) and (position.y > opponent.position.y - 30)):
		if in_game and (cooldown_timer_local == 0):
			shoot()
			cooldown_timer = cooldown





