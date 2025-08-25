extends Node2D
class_name 战斗_卡牌五区

@onready var 白区: Button = %白区
@onready var 绿区: Button = %绿区
@onready var 蓝区: Button = %蓝区
@onready var 红区: Button = %红区
@onready var 手牌: Button = %手牌
@onready var 光圈白区: PanelContainer = %光圈白区
@onready var 光圈绿区: PanelContainer = %光圈绿区
@onready var 光圈蓝区: PanelContainer = %光圈蓝区
@onready var 光圈红区: PanelContainer = %光圈红区
@onready var 光圈手牌: PanelContainer = %光圈手牌

@export var 光圈_arr:Array[StyleBoxFlat]


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var life_sys:战斗_单位管理系统.Life_sys

func set_all(is_positive:bool) -> void:
	for i:Button in [白区, 绿区, 蓝区, 红区, 手牌]:
		if !is_positive:
			i.scale = Vector2(-1,1)
		_set_区卡牌显示(i)


func add_cards(cards:Array, pos:String) -> void:
	
	var pos_node:Button
	match pos:
		"白区":pos_node = 白区
		"绿区":pos_node = 绿区
		"蓝区":pos_node = 蓝区
		"红区":pos_node = 红区
		"手牌":pos_node = 手牌
		
	
	pos_node.text = str(int(pos_node.text) + cards.size())
	pos_node.get_child(1).add_cards(cards)
	
	for card in cards:
		card.scale = Vector2()
		card.modulate = Color(1,1,1,0)
		pos_node.add_child(card)
		card.set_pos(self)


func add_card(card:Card, pos:String) -> void:
	
	var pos_node:Button
	match pos:
		"白区":pos_node = 白区
		"绿区":pos_node = 绿区
		"蓝区":pos_node = 蓝区
		"红区":pos_node = 红区
		"手牌":pos_node = 手牌
	
	pos_node.text = str(int(pos_node.text) + 1)
	pos_node.get_child(1).add_card(card)
	
	card.scale = Vector2()
	card.modulate = Color(1,1,1,0)
	pos_node.add_child(card)
	card.set_pos(self)




func remove_card(card:Card, pos:String = "") -> void:
	if !pos:
		pos = card.get_his_pos()
	var pos_node:Button
	match pos:
		"白区":pos_node = 白区
		"绿区":pos_node = 绿区
		"蓝区":pos_node = 蓝区
		"红区":pos_node = 红区
		"手牌":pos_node = 手牌
	
	pos_node.text = str(int(pos_node.text) - 1)
	pos_node.get_child(1).remove_card(card)
	pos_node.remove_child(card)


func get_posi(pos:String) -> Vector2:
	var pos_node:Button
	match pos:
		"白区":pos_node = 白区
		"绿区":pos_node = 绿区
		"蓝区":pos_node = 蓝区
		"红区":pos_node = 红区
		"手牌":pos_node = 手牌
	
	
	return pos_node.get_child(0).global_position


func _set_区卡牌显示(btn:Button) -> void:
	var gui:战斗_区卡牌显示 = preload(文件路径.tscn_战斗_区卡牌显示).instantiate()
	btn.add_child(gui)
	event_bus.push_event("战斗_右边显示改变", gui)



func 光圈(arr:Array) -> void:
	for i:int in arr.size():
		var style:StyleBoxFlat = 光圈_arr[arr[i]]
		[光圈白区, 光圈绿区, 光圈蓝区, 光圈红区][i].add_theme_stylebox_override("panel", style)



signal 按钮按下
func _on_白区_button_up() -> void:
	event_bus.push_event("战斗_右边显示改变", 白区.get_child(1))
	emit_signal("按钮按下", "白区")

func _on_绿区_button_up() -> void:
	event_bus.push_event("战斗_右边显示改变", 绿区.get_child(1))
	emit_signal("按钮按下", "绿区")

func _on_蓝区_button_up() -> void:
	event_bus.push_event("战斗_右边显示改变", 蓝区.get_child(1))
	emit_signal("按钮按下", "蓝区")

func _on_红区_button_up() -> void:
	event_bus.push_event("战斗_右边显示改变", 红区.get_child(1))
	emit_signal("按钮按下", "红区")

func _on_手牌_button_up() -> void:
	event_bus.push_event("战斗_右边显示改变", 手牌.get_child(1))
	emit_signal("按钮按下", "手牌")
