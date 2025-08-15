extends Control
class_name 战斗_场上

@onready var _0: Control = %"0"
@onready var _1: Control = %"1"
@onready var _2: Control = %"2"
@onready var _3: Control = %"3"
@onready var _4: Control = %"4"
@onready var _5: Control = %"5"
@onready var button_0: Button = %Button0
@onready var button_1: Button = %Button1
@onready var button_2: Button = %Button2
@onready var button_3: Button = %Button3
@onready var button_4: Button = %Button4
@onready var button_5: Button = %Button5

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var life_sys:战斗_单位管理系统.Life_sys

func _ready() -> void:
	event_bus.subscribe("战斗_gui场上按钮被按下", func(a,b):
		for i in [button_0, button_1, button_2, button_3, button_4, button_5]:
			i.visible = false)


func add_card(card:Card, pos:String) -> void:
	var node:Control
	match pos:
		"场上0":node = _0
		"场上1":node = _1
		"场上2":node = _2
		"场上3":node = _3
		"场上4":node = _4
		"场上5":node = _5
	
	node.add_child(card)
	reset_chlidren(node, pos)


func remove_card(card:Card, pos:String) -> void:
	var node:Control
	match pos:
		"场上0":node = _0
		"场上1":node = _1
		"场上2":node = _2
		"场上3":node = _3
		"场上4":node = _4
		"场上5":node = _5
	
	node.remove_child(card)


func reset_chlidren(node:Control, pos:String) -> void:
	var arr1:Array = node.get_children()
	if arr1.size() <= 1:
		return
	var ind:int = int(pos.erase(0, 2))
	pos = pos.erase(2)
	var arr2:Array = life_sys.cards_pos[pos][ind].cards
	var arr3:Array = arr1.duplicate(true)
	
	arr3.sort_custom(func(a,b):return arr2.find(a.card_sys) < arr2.find(b.card_sys))
	arr3.reverse()
	if arr1 != arr3:
		for i in len(arr3):
			node.move_child(arr3[i], i)



func get_posi(pos:String) -> Vector2:
	var node:Control
	match pos:
		"场上0":node = _0
		"场上1":node = _1
		"场上2":node = _2
		"场上3":node = _3
		"场上4":node = _4
		"场上5":node = _5

	return node.global_position


func set_button(index:int) -> Button:
	var node:Button
	match index:
		0:node = button_0
		1:node = button_1
		2:node = button_2
		3:node = button_3
		4:node = button_4
		5:node = button_5
	
	node.visible = true
	return node








func _on_button_0_button_up() -> void:
	event_bus.push_event("战斗_gui场上按钮被按下", [button_0, get_parent(), 0])


func _on_button_1_button_up() -> void:
	event_bus.push_event("战斗_gui场上按钮被按下", [button_1, get_parent(), 1])


func _on_button_2_button_up() -> void:
	event_bus.push_event("战斗_gui场上按钮被按下", [button_2, get_parent(), 2])


func _on_button_3_button_up() -> void:
	event_bus.push_event("战斗_gui场上按钮被按下", [button_3, get_parent(), 3])


func _on_button_4_button_up() -> void:
	event_bus.push_event("战斗_gui场上按钮被按下", [button_4, get_parent(), 4])


func _on_button_5_button_up() -> void:
	event_bus.push_event("战斗_gui场上按钮被按下", [button_5, get_parent(), 5])
