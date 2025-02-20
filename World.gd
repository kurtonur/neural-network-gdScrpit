extends Node


@export var foodSize :int = 8
var food = preload("res://Food/Food.tscn")

func _ready():
	CreateFood()
	pass

func _on_Timer_timeout():
	CreateFood()
	pass

func CreateFood():
# warning-ignore:unused_variable
	for i in range(foodSize):
		var temp :Node2D= food.instantiate()
		add_child(temp)
	pass
