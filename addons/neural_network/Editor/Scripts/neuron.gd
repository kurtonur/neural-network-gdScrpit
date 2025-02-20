extends GraphNode

var ID :Vector2 = Vector2.ZERO 

var data :Neuron = Neuron.new()

var baseColor :Color = Color.WHITE
var disableColor :Color = Color.NAVY_BLUE


signal On_Click

func SetData(data :Neuron) ->void:
	self.data = data
	pass

func SetDataValue(value :float) ->void:
	if(value):
		self.data.value = value
		get_node("Value").text =  str(snapped(value,0.001))
		if(ID.x != 0 and self.data.status == Neuron.Active):
			BgColorChangingByValue(value)
	pass
	
func SetValue() ->void:
	get_node("Value").text =  str(snapped(data.value,0.001))
	if(ID.x != 0 and self.data.status == Neuron.Active):
		BgColorChangingByValue(data.value)
	pass

func SetAsInput(value :bool = true)-> void:
	set("slot/0/left_enabled",!value)
	pass

func SetAsOutput(value :bool = true)-> void:
	set("slot/0/right_enabled",!value)
	pass

func SetID(value :Vector2) -> void:
	self.ID = value
	pass

func ChangeColor(color:Color) -> void:
	#set("custom_styles/panel/bg_color",color)
	baseColor = color
	modulate = color
	pass

func _gui_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and event.double_click and ID.x !=0:
		if(self.data.status == Neuron.Active):
			self.data.status =  Neuron.Passive
			pass
		else:
			self.data.status =  Neuron.Active
			pass
	CheckClick()
	emit_signal("On_Click",self)
	pass

func SetDisabled(value:bool = false) -> void:
	self.isActive = value
	CheckClick()
	pass

func CheckClick() -> void:
	if(self.data.status == Neuron.Active):
		modulate = baseColor
		pass
	else:
		modulate = disableColor
		pass
	pass

func BgColorChangingByValue(value) -> void:
	if value < 0:
		modulate = baseColor/2
		modulate.a = 1.0
	else:
		modulate = baseColor
