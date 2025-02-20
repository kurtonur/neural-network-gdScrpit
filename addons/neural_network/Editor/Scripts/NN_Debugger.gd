extends Window

@onready var list: ItemList = get_node("NeuralNetworkList")
@onready var view: GraphEdit  = get_node("View")

var neuronFile: PackedScene = preload("res://addons/neural_network/Editor/Neuron.tscn")

var neuralNetwork :NeuralNetwork

var AllNetworks : Array 
var nodeNeurons :Array[GraphNode]


var run :bool = false

func _ready() -> void:
	list.connect("item_activated",Callable(self,"change_in_list"))
	initGroupNN()
	pass

func _process(delta) -> void:
	
	if visible and run and neuralNetwork and neuralNetwork.GetIsReady():
		SetNeuralValues()
	pass

func initNetwork(neuralNetwork) -> void:
	run = false
	removeAll()
	self.neuralNetwork = neuralNetwork
	for layer in range(neuralNetwork.layers.size()):
		for neuron in range(neuralNetwork.layers[layer]):
			var tempNeuronNode :GraphNode
			if(layer == 0):
				tempNeuronNode = AddNeuron(neuralNetwork.neurons[layer][neuron],Vector2(layer,neuron),Color.GOLDENROD)
				tempNeuronNode.SetAsInput()
				nodeNeurons.append(tempNeuronNode)
			elif(layer == neuralNetwork.layers.size()-1):
				tempNeuronNode = AddNeuron(neuralNetwork.neurons[layer][neuron],Vector2(layer,neuron),Color.BROWN)
				tempNeuronNode.SetAsOutput()
			else:
				tempNeuronNode = AddNeuron(neuralNetwork.neurons[layer][neuron],Vector2(layer,neuron),Color.FOREST_GREEN)
			nodeNeurons.append(tempNeuronNode)
	for link in neuralNetwork.links:
		if link.status == Link.Active:
			view.connect_node("NeuronNode_" + str(link.from_ID),0,"NeuronNode_" + str(link.to_ID),0)
		pass
	run = true
	
func SetNeuralValues(neuralNetwork = self.neuralNetwork) -> void:
	for nodeNeuron in nodeNeurons:
		if run and nodeNeuron != null:
			nodeNeuron.SetValue()
	pass

func removeAll() -> void:
	self.run = false
	view.clear_connections()
	#
	for child in view.get_children():
		if child is GraphNode:
			child.queue_free()
	self.run = true
	pass

func change_in_list(id) -> void:
	var node :NeuralNetwork = self.AllNetworks[id]
	if node.has_method("GetIsReady") && node.GetIsReady():
		initNetwork(node)
	pass

func initGroupNN() -> void:
	self.AllNetworks = get_tree().get_nodes_in_group(NeuralNetwork.Debugger)
	for item in self.AllNetworks:
		if item.isReady:
			list.add_item(item.name,load("res://addons/neural_network/icon.svg"))
		else:
			list.add_item(item.name,null,false)
		pass
	pass

func On_Click_Neuron(NeuronNode) -> void:
	#neuralNetwork.SetNeuronAction(NeuronNode.ID.x,NeuronNode.ID.y,NeuronNode.isActive)
	pass

func AddNeuron(neuron :Neuron,neuronID :Vector2 = Vector2.ZERO, color :Color = Color.WHITE) -> GraphNode:
	var neuronIns :GraphNode = neuronFile.instantiate()
	neuronIns.SetData(neuron)
	neuronIns.SetID(neuronID)
	neuronIns.ChangeColor(color)
	neuronIns.position_offset = neuronID * 200
	neuronIns.name = "NeuronNode_" + str(neuronID)
	view.add_child(neuronIns)
	neuronIns.connect("On_Click",Callable(self,"On_Click_Neuron"))
	return neuronIns
	pass

func _on_NeuralNetworkList_item_selected(index) -> void:
	self.run = false
	change_in_list(index)
	self.run = true
	pass 

func _on_Refresh_pressed() -> void:
	list.clear()
	initGroupNN()
	pass

func _on_game_debugger_about_to_popup() -> void:
	hide()
	removeAll()
	pass

func _on_close_requested() -> void:
	hide()
	removeAll()
	pass 

func _on_view_connection_request(from_node, from_port, to_node, to_port):
	
	var splitFrom = (from_node as String).split("_")[1]
	var splitTo = (to_node as String).split("_")[1]
	
	for link in neuralNetwork.links:
		if (str(link.from_ID) == splitFrom) &&  (str(link.to_ID) == splitTo):
			neuralNetwork.neurons[link.from_ID.x][link.from_ID.y].links.erase(link)
			neuralNetwork.neurons[link.to_ID.x][link.to_ID.y].links.erase(link)
			neuralNetwork.links.erase(link)
			view.disconnect_node(from_node, from_port, to_node, to_port)
			return
	var newLink :Link = Link.new()
	newLink.setData({
		status = Link.Active,
		weight = 0.5,
		bias = 0.0,
		from_ID = splitFrom,
		to_ID = splitTo,
	})
	
	neuralNetwork.links.append(newLink)
	newLink.from = neuralNetwork.neurons[newLink.to_ID.x][newLink.to_ID.y]
	newLink.to = neuralNetwork.neurons[newLink.from_ID.x][newLink.from_ID.y]
	newLink.to.SetLink(newLink)
	view.connect_node(from_node, from_port, to_node, to_port)
	pass # Replace with function body.

func _on_view_disconnection_request(from_node, from_port, to_node, to_port):
	pass # Replace with function body.
