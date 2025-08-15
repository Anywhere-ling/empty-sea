extends Control

@onready var 动画系统: Node = %动画系统

@onready var 确认: Button = %确认
@onready var 取消: Button = %取消
@onready var 描述: Label = %描述


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var 返回data:Dictionary
var max:int
var min:int
var btns:Array[Button]



func _ready() -> void:
	event_bus.subscribe("战斗_gui场上按钮被按下", _选择一格返回)
	event_bus.subscribe("战斗_右键点击", _on_取消_button_up)

func _选择一格返回(btn:Button, life:战斗_life, indes:int) -> void:
	if max == 1:
		返回data[btn] = [life, indes]
		_on_确认_button_up()
	
	if 返回data.size() >= max:
		btn.button_pressed = false
		返回data.erase(btn)
		return
	
	if btn.button_pressed:
		返回data[btn] = [life, indes]
	else :
		返回data.erase(btn)
	
	if 返回data.size() >= min:
		确认.disabled = false
	else :
		确认.disabled = true


func set_cards(arr:Array, p_描述:String = "无", count_max:int = 1, count_min:int = 1) -> void:
	描述.text = p_描述
	max = count_max
	min = count_min
	
	
	
	if min <= 0:
		取消.visible = true
	else:
		取消.visible = false
	visible = true
	
	for i in arr:
		var life:战斗_life = 动画系统.对照表["life"][i.get_parent()]
		btns.append(life.场上.set_button(i.场上index))


func free_cards() -> Array:
	var ret:Array
	for i:Button in 返回data:
		var life:战斗_单位管理系统.Life_sys = 返回data[i][0].life_sys
		ret.append(life.cards_pos["场上"][返回data[i][1]])
	for i:Button in btns:
		i.visible = false
		i.button_pressed = false
	确认.disabled = true
	visible = false
	btns = []
	返回data = {}
	return ret





signal 按下
func _on_确认_button_up() -> void:
	emit_signal("按下")


func _on_取消_button_up() -> void:
	if 取消.disabled or !取消.visible:
		return
	free_cards()
	emit_signal("按下")
