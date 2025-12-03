extends Node


@export var population :int = 100 # (int,0,500,1)
@export var gameSpeed :int = 1 # (int,1,50,1)
@export var saveFile = "name" # (String, FILE)
var PLayer = preload("res://Player/Player.tscn")
var playerList :Array = Array();

@onready var genLabel = get_node("CanvasLayer/Gen")
@onready var popLabel = get_node("CanvasLayer/Pop")
var generation :int= 1

func _ready():
	genLabel.text ="Gen : " + str(generation)
	for i in range(population):
		var temp = PLayer.instantiate()
		playerList.append(temp)
		add_child(temp)
		temp.AI.name = "player"+ str(i)
		temp.playerIAName.text = "p-"+ str(i)
		pass
	pass

func _process(_delta):
	Engine.time_scale = gameSpeed
	if countAlive() <=0:
		nextGen()
		generation += 1
		genLabel.text ="Gen : " + str(generation)
		SetAllAlive()
		pass
	popLabel.text = "Pop : " + str(countAlive())
	pass

func _input(event):
	if event.is_action_released("Kill"):
		KillThemAll()
	pass

func KillThemAll():
	for player in playerList:
		player.Dead()
	pass

func SetAllAlive():
	for player in playerList:
		player.SetAlive()
	pass

func countAlive():
	var count :int= 0
	for player in playerList:
		if player.status == player.Alive:
			count +=1
	return count

func CheckBestPLayer():
	var bestAI :NeuralNetwork = playerList[0].AI
	for player in playerList:
		if player.AI.fitness >= bestAI.fitness:
			bestAI = player.AI
		pass
	return bestAI

##continue
func nextGen():
	for player in playerList:
		if player.status == player.Death:
			if(player.eaten>=player.AI.fitness):
				player.AI.fitness = player.eaten
				pass
			pass
	
	var bestAI :NeuralNetwork= CheckBestPLayer()
	var temp :NeuralNetwork = NeuralNetwork.new()
	
	temp.LoadNetworkFromFile("user://"+ saveFile)
	if(temp.fitness < bestAI.fitness):
		bestAI.SaveNetworkToFile("user://"+ saveFile)
	else:
		bestAI = temp
	
	for i in range(population/4.0):
		playerList[i].AI.SetNetworkData(bestAI.GetNetworkData())
	for i in range(population*1/4.0,population*3/4.0):
		playerList[i].AI.SetNetworkData(bestAI.GetNetworkData())
		playerList[i].AI.Mutate()
	for i in range(population*3/4.0,population):
		playerList[i].AI.Cleaner()
		playerList[i].AI.InitLayers([2,randi_range(2,8),randi_range(2,8),randi_range(2,8),2])
		playerList[i].AI.Mutate()

	pass
