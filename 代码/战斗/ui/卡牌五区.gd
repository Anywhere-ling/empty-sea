extends Node2D
class_name 战斗_卡牌五区


@onready var 白区: 战斗_卡牌五区_子区 = %白区
@onready var 手牌: 战斗_卡牌五区_子区 = %手牌
@onready var 绿区: 战斗_卡牌五区_子区 = %绿区
@onready var 蓝区: 战斗_卡牌五区_子区 = %蓝区
@onready var 红区: 战斗_卡牌五区_子区 = %红区
@onready var 光圈白区: PanelContainer = %光圈白区
@onready var 光圈绿区: PanelContainer = %光圈绿区
@onready var 光圈蓝区: PanelContainer = %光圈蓝区
@onready var 光圈红区: PanelContainer = %光圈红区
@onready var 光圈手牌: PanelContainer = %光圈手牌

@export var 光圈_arr:Array[StyleBoxFlat]


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var life_sys:战斗_单位管理系统.Life_sys

func set_all(is_positive:bool) -> void:
	for i:战斗_卡牌五区_子区 in [白区, 绿区, 蓝区, 红区, 手牌]:
		if !is_positive:
			i.scale = Vector2(-1,1)


func add_cards(cards:Array, pos:String) -> void:
	var pos_node:战斗_卡牌五区_子区
	match pos:
		"白区":pos_node = 白区
		"绿区":pos_node = 绿区
		"蓝区":pos_node = 蓝区
		"红区":pos_node = 红区
		"手牌":pos_node = 手牌
		
	
	pos_node.add_cards(cards)


func add_card(card:Card, pos:String) -> void:
	var pos_node:战斗_卡牌五区_子区
	match pos:
		"白区":pos_node = 白区
		"绿区":pos_node = 绿区
		"蓝区":pos_node = 蓝区
		"红区":pos_node = 红区
		"手牌":pos_node = 手牌
	
	pos_node.add_card(card)


func remove_card(card:Card, pos:String = "") -> void:
	if !pos:
		pos = card.get_his_pos()
	var pos_node:战斗_卡牌五区_子区
	match pos:
		"白区":pos_node = 白区
		"绿区":pos_node = 绿区
		"蓝区":pos_node = 蓝区
		"红区":pos_node = 红区
		"手牌":pos_node = 手牌
	
	pos_node.remove_card(card)


func get_posi(pos:String) -> Vector2:
	var pos_node:战斗_卡牌五区_子区
	match pos:
		"白区":pos_node = 白区
		"绿区":pos_node = 绿区
		"蓝区":pos_node = 蓝区
		"红区":pos_node = 红区
		"手牌":pos_node = 手牌
	
	
	return pos_node.get_posi()



func 光圈(arr:Array) -> void:
	for i:int in arr.size():
		var style:StyleBoxFlat = 光圈_arr[arr[i]]
		[光圈白区, 光圈绿区, 光圈蓝区, 光圈红区][i].add_theme_stylebox_override("panel", style)



signal 按钮按下
func _on_白区_button_up() -> void:
	emit_signal("按钮按下", "白区")

func _on_绿区_button_up() -> void:
	emit_signal("按钮按下", "绿区")

func _on_蓝区_button_up() -> void:
	emit_signal("按钮按下", "蓝区")

func _on_红区_button_up() -> void:
	emit_signal("按钮按下", "红区")

func _on_手牌_button_up() -> void:
	emit_signal("按钮按下", "手牌")
