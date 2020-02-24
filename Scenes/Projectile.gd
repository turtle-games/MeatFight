extends Area2D

export var speed = 15
export var id = -1
export var is_pizza = false

func _ready():
	if ((randi() % 8) == 0):
		$AnimatedSprite.play("2")
		is_pizza = true

func _process(delta):
	position.x += speed * (delta * 100)
	#print("projectile pos: %s"%position)


func _on_collision(body):
	if body.id == id:
		return
	get_tree().call_group("Players", "projectile_collision", body.id, is_pizza)
	queue_free()
