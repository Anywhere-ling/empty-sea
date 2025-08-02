extends Node2D
class_name 战斗_卡牌四区

@onready var 白区: Button = %白区
@onready var 绿区: Button = %绿区
@onready var 蓝区: Button = %蓝区
@onready var 红区: Button = %红区

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus



func set_all(is_positive:bool) -> void:
	for i:Button in [白区, 绿区, 蓝区, 红区]:
		i.pivot_offset = i.size/2
		if !is_positive:
			i.rotation_degrees = 180
		_set_区卡牌显示(i)


func add_card(card:Card, pos:String) -> void:
	
	var pos_node:Button
	match pos:
		"白区":pos_node = 白区
		"绿区":pos_node = 绿区
		"蓝区":pos_node = 蓝区
		"红区":pos_node = 红区
	
	pos_node.get_child(0).add_card(card)

func remove_card(card:Card, pos:String) -> void:
	var pos_node:Button
	match pos:
		"白区":pos_node = 白区
		"绿区":pos_node = 绿区
		"蓝区":pos_node = 蓝区
		"红区":pos_node = 红区
	
	return pos_node.get_child(0).remove_card(card)

func get_posi(pos:String) -> Vector2:
	var pos_node:Button
	match pos:
		"白区":pos_node = 白区
		"绿区":pos_node = 绿区
		"蓝区":pos_node = 蓝区
		"红区":pos_node = 红区
	
	return pos_node.global_position


func _set_区卡牌显示(btn:Button) -> void:
	var gui:战斗_区卡牌显示 = load(文件路径.tscn_战斗_区卡牌显示()).instantiate()
	btn.add_child(gui)
	gui.set_nam(btn.name)
	event_bus.push_event("战斗_右边显示改变", gui)


func change_ccount(arr:Array) -> void:
	白区.text = str(arr[0])
	绿区.text = str(arr[1])
	蓝区.text = str(arr[2])
	红区.text = str(arr[3])







func _on_白区_button_up() -> void:
	event_bus.push_event("战斗_右边显示改变", 白区.get_child(0))


func _on_绿区_button_up() -> void:
	event_bus.push_event("战斗_右边显示改变", 绿区.get_child(0))


func _on_蓝区_button_up() -> void:
	event_bus.push_event("战斗_右边显示改变", 蓝区.get_child(0))


func _on_红区_button_up() -> void:
	event_bus.push_event("战斗_右边显示改变", 红区.get_child(0))
