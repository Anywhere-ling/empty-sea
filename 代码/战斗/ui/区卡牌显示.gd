extends Control
class_name 战斗_区卡牌显示


@export var card_边距:Vector2

@onready var v: VBoxContainer = %v

var cards:Array[Card] = []
var nam:String

func set_nam(p_nam:String) -> void:
	nam = p_nam
	v.tooltip_text = nam


func add_card(card:Card) -> void:
	if card.get_parent():
		card.get_parent().remove_child(card)
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

var 容器s:Array = []
func _get_容器() -> 战斗_卡牌容器:
	if len(容器s) > 0:
		var 容器:战斗_卡牌容器 = 容器s[0]
		容器s.erase(容器)
		return 容器
	else :
		var 容器:战斗_卡牌容器 = load(文件路径.tscn_战斗_卡牌容器()).instantiate()
		容器.set_nam(nam, v.size.x)
		容器.边距 = card_边距
		return 容器

func _remove_容器(容器:战斗_卡牌容器) -> void:
	容器.get_parent().remove_child(容器)
	容器.remove_card()
	容器s.append(容器)
		

func _reset_cadrs() -> void:
	var 保留:Dictionary = {}
	for 容器:战斗_卡牌容器 in v.get_children():
		if cards.has(容器.card):
			保留[容器.card] = 容器
		else:
			_remove_容器(容器)
	for card:Card in cards:
		var 容器:战斗_卡牌容器
		if 保留.has(card):
			容器 = 保留[card]
			if 容器.get_index() != cards.find(card):
				v.move_child(容器, cards.find(card))
		else :
			容器 = _get_容器()
			v.add_child(容器)
			var a = card.get_parent()
			容器.add_card(card)
