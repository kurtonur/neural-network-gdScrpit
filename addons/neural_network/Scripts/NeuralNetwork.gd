@icon("res://addons/neural_network/icon.svg")

class_name NeuralNetwork
extends Node

const Debugger :String =  "NN_Game_Debugger" 

enum MutationFunctions {NewRandomByLearningRate,MultiplyByTwo,MultiplyByLearningRate,MultiplyByZeroOne,MultiplyByZeroOnePlus,Custom,Default}
enum ActivationFuctions {Sigmoid,SigmoidDerivative,Tanh,TanhDerivative,ReLU,ReLUDerivative,ELU,ELUDerivative,Linear,LinearDerivative,Custom,Default}

@export var layers :Array[int] = [] # (Array,int)

var neurons :Array = []
var links :Array[Link] = []

var isReady: bool= false

@export var fitness: float = 0.0 # Value will be saved and visible in the property editor.
@export var bestFitness: float = 0.0
@export var startRandomization: Vector2 = Vector2(-0.5,0.5)
@export var learningRate: Vector2 = Vector2(-0.1,0.1)

@export var mutationFunction: MutationFunctions= MutationFunctions.Default
@export var activationFuction: ActivationFuctions= ActivationFuctions.Default

func SetLayers(layers :Array) -> void:
	self.layers.clear()
	self.layers.assign(layers) 

func _enter_tree() -> void:
	randomize()
	self.InitLayers()
	if OS.is_debug_build():
		add_to_group(Debugger)
	pass

func GetFitness() -> float:
	return fitness

func GetBestFitness() -> float:
	return bestFitness

func SetFitness(value :float) -> void:
	self.fitness = value

func SetBestFitness(value :float) -> void:
	self.bestFitness = value

# warning-ignore:shadowed_variable
func SetBias(layer:int,neuron:int,bias:float) -> void:
	if(layer < layers.size()):
		if neuron < neurons[layer].size():
			for link in neurons[layer][neuron].links:
				link.bias = bias
	pass

# warning-ignore:shadowed_variable
func SetAllBias(bias :float) -> void:
	for link in links:
		link.bias = bias
	pass

func SetNeuronAction(layer:int,neuron:int,value:bool = true) -> void:
	if(layer < layers.size()):
		if neuron < neurons[layer].size():
			var tempStatus := Neuron.Active
			if !value:
				tempStatus = Neuron.Passive
				neurons[layer][neuron].status = tempStatus

# warning-ignore:shadowed_variable
func SetAllNeuronsAction(value :bool = true) -> void:
	var tempStatus := Neuron.Active
	if !value:
		tempStatus = Neuron.Passive
	for neuron in neurons:
		neuron.status = tempStatus
	pass

func SetLearningRate(rate :Vector2) -> void:
	self.learningRate = rate
	pass
	
func GetLearningRate() -> Vector2:
	return self.learningRate
	
func SetStartRandomization(random :Vector2) -> void:
	self.startRandomization = random
	pass
	
func GetStartRandomization() -> Vector2:
	return self.startRandomization

func GetIsReady() -> bool:
	return self.isReady
	
# warning-ignore:shadowed_variable
func InitLayers(layers:Array = self.layers) -> void:
	if !isReady:
		if self.layers.size() <= 0:
			for item in layers:
				self.layers.append(item)
		_InitNeurons()
		_InitWeights()
		self.isReady = true
	pass

func _InitNeurons() -> void:
	for layer in range(self.layers.size()):
		self.neurons.append(Array())
		for neuron in range(layers[layer]):
			var tempNeuron :Neuron = Neuron.new()
			tempNeuron.value = randf_range(startRandomization.x,startRandomization.y)
			neurons[layer].append(tempNeuron)
			pass
	pass

func _InitWeights() -> void:
	for layer in range(1,self.layers.size()):
		for neuron in range(self.neurons[layer].size()):
			for from in range(neurons[layer-1].size()):
				var tempLink :Link = neurons[layer][neuron].SetLinkWithWeight(randf_range(startRandomization.x,startRandomization.y),neurons[layer-1][from])
				tempLink.from_ID = Vector2i(layer-1,from)
				tempLink.to_ID = Vector2i(layer,neuron)
				tempLink.from = neurons[tempLink.from_ID.x][tempLink.from_ID.y]
				tempLink.to = neurons[tempLink.to_ID.x][tempLink.to_ID.y]
				self.links.append(tempLink)
				pass
			pass
	pass

func Forward(input :Array,CustomFunction = null) -> Array:
	if(self.isReady):
		
		if(input.size() != layers[0]):
			print("!!! Wrong input size for Neural Network !!!")
			return neurons.back()

		for layer in range(self.layers.size()):
			if layer == 0:
				for neuron in range(neurons[0].size()):
					neurons[0][neuron].value = input[neuron]
				pass
			else:
				for neuron in neurons[layer]:
					if(neuron.status == Neuron.Passive):
						continue
					var value = 0.0
					for link in neuron.links:
						if link.status == Link.Passive:
							continue
						value += link.weight * link.from.value + link.bias
						pass
						neuron.value = _ActivationFuction(value,activationFuction,CustomFunction)
					pass
		return neurons.back()
	else:
		print("Neural Network is not ready.")
	return neurons.back()
	pass

func _ActivationFuction(value :float, ActivationType :int = activationFuction, CustomFunction = null) -> float:
	var result :float = 0.0
	match(ActivationType):
		ActivationFuctions.Sigmoid:
			result = 1.0 / (1.0 + exp(-value))
		ActivationFuctions.SigmoidDerivative:
			result = (1.0 / (1.0 + exp(-value))) * (1 - (1.0 / (1.0 + exp(-value))))
		ActivationFuctions.Tanh:
			result = tanh(value)
		ActivationFuctions.TanhDerivative:
			result = 1 - pow(tanh(value),2)
		ActivationFuctions.ReLUDerivative:
			if value > 0:
				result = 1
			else:
				result = 0
		ActivationFuctions.ReLU:
			result = max(0,value)
		ActivationFuctions.ELU:
			if value >= 0:
				result = value
			else:
				result = exp(value)-1
		ActivationFuctions.ELUDerivative:
			if value >= 0:
				result = 1
			else:
				result = exp(value)
		ActivationFuctions.Linear:
			result = value
		ActivationFuctions.LinearDerivative:
			result = 1
		ActivationFuctions.Custom:
			if (CustomFunction):
				result = CustomFunction.call_func(value)
		ActivationFuctions.Default:
			result = 1.0 / (1.0 + exp(-value))
	return result
	pass

func Mutate(MutationFunction:int = mutationFunction,CustomFunction = null) -> void:
	for link in links:
		link.weight = _MutateFunction(link.weight,MutationFunction,CustomFunction)
	pass

func _MutateFunction(weight :float,MutationType :int,CustomFunction = null) -> float:
	var result :float = 0.0
	match(MutationType):
		MutationFunctions.MultiplyByTwo:
			result = weight*2
		MutationFunctions.MultiplyByLearningRate:
			result = weight * randf_range(learningRate.x,learningRate.y)
		MutationFunctions.NewRandomByLearningRate:
			result =randf_range(learningRate.x,learningRate.y)
		MutationFunctions.MultiplyByZeroOne:
			result = weight * randf_range(0.0,1.0)
		MutationFunctions.MultiplyByZeroOnePlus:
			result = weight * (randf_range(0.0,1.0)+1.0)
		MutationFunctions.Custom:
			if (CustomFunction):
				result = CustomFunction.call_func(weight)
		MutationFunctions.Default:
			result = randf_range(learningRate.x,learningRate.y)
	return result
	pass

#### Save Network #####

func SaveNetworkToFile(path: String, password: String = "") -> void:
	var data :Dictionary = GetNetworkData()
	var jsonData = JSON.stringify(data)
	var file :FileAccess = null
	if password != "":
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE,password)
	else:
		file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(jsonData)
	pass

func LoadNetworkFromFile(path :String, password: String = "") -> void:
	var file :FileAccess = null
	var doFileExists :bool = FileAccess.file_exists(path)
	if(doFileExists):
		if password != "":
			file  = FileAccess.open_encrypted_with_pass(path, FileAccess.READ,password)
		else:
			file = FileAccess.open(path, FileAccess.READ)
		var data = file.get_var()
		Cleaner()
		SetNetworkData(JSON.parse_string(data))
		self.isReady = true
	pass

func GetNetworkData() -> Dictionary:
	var tempNeuronDataArray  :Array = []
	for layer in range(layers.size()):
		tempNeuronDataArray.append(Array())
		for neuron in neurons[layer]:
			tempNeuronDataArray[layer].append(neuron.GetNeuronData())
			
	var data :Dictionary= {
		layers = self.layers,
		neurons = tempNeuronDataArray,
		fitness = self.fitness,
		bestFitness = self.bestFitness,
		startRandomization = self.startRandomization,
		learningRate  = self.learningRate,
		mutationFunction = self.mutationFunction,
		activationFuction  = self.activationFuction,
		isReady = self.isReady
	}
	return data
	pass

func SetNetworkData(data :Dictionary) -> void:
	Cleaner()
	if data.layers:
		SetLayers(data.layers)
	if data.neurons:
		for layer in range(data.layers.size()):
			self.neurons.append(Array())
			for neuron in data.neurons[layer]:
				var tempNeuron :Neuron = Neuron.new()
				tempNeuron.value = neuron.value
				tempNeuron.status = neuron.status
				for link in neuron.links:
					var tempLink :Link = Link.new()
					tempLink.setData(link)
					tempLink.from= self.neurons[tempLink.from_ID.x][tempLink.from_ID.y]
					tempLink.to = tempNeuron
					tempNeuron.SetLink(tempLink)
					self.links.append(tempLink)
					pass
				self.neurons[layer].append(tempNeuron)
				pass
	if data.fitness:
		self.fitness = data.fitness
	if data.bestFitness:
		self.bestFitness = data.bestFitness
	if data.startRandomization:
		self.startRandomization = str_to_var("Vector2" + str(data.startRandomization))
	if data.learningRate:
		self.learningRate = str_to_var("Vector2" + str(data.learningRate))
	if data.mutationFunction:
		self.mutationFunction = data.mutationFunction
	if data.activationFuction:
		self.activationFuction = data.activationFuction
	if data.isReady:
		self.isReady = data.isReady
	pass

func Cleaner()  -> void:
	self.isReady = false
	self.layers  = []
	self.neurons = []
	self.links = []
	self.fitness  = 0
	self.bestFitness  = 0
	self.startRandomization  = Vector2(-0.5,0.5)
	self.learningRate  = Vector2(-0.1,0.1)
	self.mutationFunction = MutationFunctions.Default
	self.activationFuction  = ActivationFuctions.Default
	pass

func CopyFrom(neuralNetwork :NeuralNetwork)  -> void:
	Cleaner()
	SetNetworkData(neuralNetwork.GetNetworkData())
	pass
