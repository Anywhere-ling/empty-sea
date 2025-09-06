extends Control
class_name 战斗_区卡牌显示


@export var card_边距:Vector2
@onready var 容器: VBoxContainer = %容器

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var cards:Array = []
var 正在显示的区:Node

func _ready() -> void:
	event_bus.subscribe("战斗_区卡牌显示改变", set_card)


func set_card(node:Node, node_cards:Array) -> void:
	if 正在显示的区:
		正在显示的区.请求区卡牌显示.disconnect(set_card)
	正在显示的区 = node
	正在显示的区.请求区卡牌显示.connect(set_card)
	
	cards = node_cards
	_reset_cadrs()



func add_cards(p_cards:Array) -> void:
	for card in p_cards:
		cards.insert(0, card)
	_reset_cadrs()

func add_card(card:Card) -> void:
	cards.insert(0, card)
	_reset_cadrs()

func remove_card(card:Card) -> void:
	cards.erase(card)
	_reset_cadrs()


func change_cards(p_cards:Array[Card]) -> void:
	if p_cards == cards:
		return
	
	cards = p_cards
	_reset_cadrs()


func _get_容器() -> 战斗_卡牌复制:
	var 容器:战斗_卡牌复制 = preload(文件路径.tscn_战斗_卡牌复制).instantiate()
	add_child(容器)
	容器.set_边距(card_边距.x, card_边距.y)
	remove_child(容器)
	return 容器

		

func _reset_cadrs() -> void:
	for i:战斗_卡牌复制 in 容器.get_children():
		if i.visible:
			i.free_card()
			i.visible = false
	for card:Card in cards:
		var 卡牌复制:战斗_卡牌复制
		for i:战斗_卡牌复制 in 容器.get_children():
			if !i.visible:
				卡牌复制 = i
				break
		if !卡牌复制:
			卡牌复制 = _get_容器()
			容器.add_child(卡牌复制)
		
		卡牌复制.set_card(card)
