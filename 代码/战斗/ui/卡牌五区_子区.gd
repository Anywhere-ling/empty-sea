extends Button
class_name 战斗_卡牌五区_子区


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var pos_sys:战斗_单位管理系统.Card_pos_sys
var 区卡牌显示:战斗_区卡牌显示
var cards:Array

signal 请求区卡牌显示

func _ready() -> void:
	button_up.connect(_按钮按下)



func get_pos_nam() -> String:
	return pos_sys.nam


func add_cards(p_cards:Array) -> void:
	for card in p_cards:
		print(name)
		if card.get_parent():
			card.get_parent().remove_child(card)
		
		card.scale = Vector2()
		card.modulate = Color(1,1,1,0)
		add_child(card)
		card.set_pos(self)
		cards.insert(0, card)
	_cards_change()


func add_card(card:Card) -> void:
	if card.get_parent():
		card.get_parent().remove_child(card)
	
	add_child(card)
	card.set_pos(self)
	cards.insert(0, card)
	_cards_change()


func remove_card(card:Card) -> void:
	remove_child(card)
	cards.erase(card)
	_cards_change()

func _cards_change() -> void:
	text = str(cards.size())
	emit_signal("请求区卡牌显示", self, cards)


func get_posi() -> Vector2:
	return get_child(0).global_position


func _按钮按下() -> void:
	event_bus.push_event("战斗_区卡牌显示改变", [self, cards])
	
