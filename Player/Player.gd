extends CharacterBody2D

const StartHunger = 5
enum{Alive,Pause,Death}

@export var isPlayer: bool = false  
@export_range(50,250,1) var speed :int = 200 # (int,50,250,1)
@export var AIFile :String = ""
var direction :Vector2 = Vector2()

var hunger :int = StartHunger
var eaten :int = 0
var status :int= Alive

@onready var animation :AnimatedSprite2D = get_node("AnimatedSprite2D") 
@onready var hungerLabel :Label = get_node("LabelScore")
@onready var playerIAName :Label = get_node("LabelName")
@onready var timer :Timer = get_node("Timer")
@onready var AI :NeuralNetwork = get_node("NeuralNetwork")

var randomSprite :int = 0
var food :Node2D = null

func _ready():
	SetAlive()
	if AIFile != "":
		AI.LoadNetworkFromFile("user://"+ AIFile)
	pass

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	if(status == Alive):
		if isPlayer:
			get_input()
		else:
			PlayerMove()
# warning-ignore:return_value_discarded
		move_and_collide(velocity * delta)
	elif(status == Pause):
		pass
	elif(status == Death):
		pass
	pass

func PlayerMove():
	var foodData = FoodData()
	var result :Array = AI.Forward([foodData.x,foodData.y])
	velocity = Vector2(result[0].value,result[1].value).normalized() * speed
	pass

func EatFood():
	hunger += 1
	hungerLabel.text = str(hunger)
	eaten +=1
	Split()
	pass

func _on_Timer_timeout():
	hunger -= 1
	hungerLabel.text = str(hunger)
	if hunger<= 0:
		Dead()
		timer.stop()
		pass
	pass 

func Dead():
	set_process(false)
	status = Death
	AI.isReady = false
	animation.set_animation("Dead")
	animation.frame = randomSprite
	hungerLabel.hide()
	playerIAName.hide()
	modulate.a = 0.2
	$Eye.process_mode =Node.PROCESS_MODE_DISABLED
	pass

func SetAlive():
	set_process(true)
	position = Vector2(320/2,240/2)
	eaten = 0
	modulate.a = 1
	AI.isReady = true
	timer.stop()
	animation.set_animation("Idle")
	hunger = StartHunger
	hungerLabel.text = str(hunger)
	hungerLabel.show()
	playerIAName.show()
	status = Alive
	RandomSprite()
	$Eye.process_mode =Node.PROCESS_MODE_INHERIT
	timer.start()
	pass

func FoodData() -> Vector2:
	if self.food != null:
		return global_position.direction_to(food.global_position)
	else:
		self.food = $Eye.get_object()
		return Vector2.ZERO
	

func RandomSprite():
	randomSprite = randi() % 4
	animation.frame = randomSprite
	pass

func Split():
	if hunger >= 10:
		var temp :CharacterBody2D = load("res://Player/Player.tscn").instantiate()
		temp.global_position = global_position
		
		var parent = get_node("../")
		if parent != null:
			parent.add_child(temp)
		temp.AI.CopyFrom(AI)
		temp.AI.Mutate()
		hunger = 7
		pass
	pass

func _on_area_2d_area_entered(area):
	if food == null:
		if (area.get_parent() as Food).is_in_group("Food"):
			self.food = area.get_parent()
			pass
	pass
