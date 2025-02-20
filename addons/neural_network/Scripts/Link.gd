@icon("res://addons/neural_network/icon.svg")

class_name Link
extends Node

enum {Active,Passive}

var status := Link.Active

var weight :float = 0.0
var bias :float = 0.0

var from_ID :Vector2i = Vector2i.ZERO
var from :Neuron = null

var to_ID :Vector2i = Vector2i.ZERO
var to :Neuron = null

func getData() -> Dictionary:
	var data :Dictionary = {
		status = self.status,
		weight = self.weight,
		bias = self.bias,
		from_ID = self.from_ID,
		to_ID = self.to_ID,
	}
	return data

func setData(data :Dictionary) -> void:
	if data.status != null:
		self.status = data.status
	if data.weight != null:
		self.weight = data.weight
	if data.bias != null:
		self.bias = data.bias
	if data.from_ID != null:
		self.from_ID = str_to_var("Vector2" + str(data.from_ID))
	if data.to_ID != null:
		self.to_ID = str_to_var("Vector2" + str(data.to_ID))
	pass
