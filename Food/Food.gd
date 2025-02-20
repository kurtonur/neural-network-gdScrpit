extends Node2D
class_name  Food
@onready var animation : AnimatedSprite2D = get_node("AnimatedSprite2D")


func _ready():
	randomize()
	animation.frame = randi() % 36
	position = Vector2(randi()%490+20,randi() %190 + 20)
	pass

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		body.EatFood()
		queue_free()
		pass
	pass

func _on_Timer_timeout():
	queue_free()
	pass
