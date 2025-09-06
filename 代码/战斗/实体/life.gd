extends Control
class_name 战斗_life

@onready var life图: TextureRect = %life图
@onready var 卡牌五区: 战斗_卡牌五区 = %卡牌五区
@onready var 手牌: Node
@onready var 行动: 战斗_行动与手牌 = %行动


var nam:String
var life_ind:int
var life_sys:战斗_单位管理系统.Life_sys
var is_positive:bool
var is_c0ntrol:bool = false

func set_life(p_life_sys:战斗_单位管理系统.Life_sys, p_is_positive:bool, p_life_ind:int) -> void:
	life_sys = p_life_sys
	is_positive = p_is_positive
	nam = life_sys.nam
	life_ind = p_life_ind
	
	卡牌五区.life_sys = life_sys
	手牌 = 卡牌五区.手牌
	
	display()

func set_c0ntrol() -> void:
	is_c0ntrol = true

func set_all() -> void:
	卡牌五区.set_all(is_positive)
	手牌.pos_sys = life_sys.cards_pos["手牌"]
	行动.pos_sys = life_sys.cards_pos["行动"]
	卡牌五区.白区.pos_sys = life_sys.cards_pos["白区"]
	卡牌五区.绿区.pos_sys = life_sys.cards_pos["绿区"]
	卡牌五区.蓝区.pos_sys = life_sys.cards_pos["蓝区"]
	卡牌五区.红区.pos_sys = life_sys.cards_pos["红区"]
	
	

func add_cards(cards:Array, pos:String) -> void:
	for card in cards:
		if card.get_parent():
			card.get_parent().remove_child(card)
	
	if pos in ["白区", "绿区", "蓝区" ,"红区"]:
		卡牌五区.add_cards(cards, pos)
	
	
	

func add_card(card:Card, pos:String) -> void:
	if card.get_parent():
		card.get_parent().remove_child(card)
	
	if pos in ["白区", "绿区", "蓝区" ,"红区"]:
		卡牌五区.add_card(card, pos)
	elif pos == "手牌":
		手牌.add_card(card)
	elif pos == "行动":
		行动.add_card(card)
	
	for i:String in ["白区", "绿区", "蓝区" ,"红区", "手牌", "行动", "场上0", "场上1", "场上2", "场上3", "场上4", "场上5"]:
		card.remove_from_group(i)
	card.add_to_group(pos)

func remove_card(card:Card, pos:String) -> void:
	if pos == "临时":
		card.get_parent().remove_child(card)
	elif pos in ["白区", "绿区", "蓝区" ,"红区"]:
		卡牌五区.remove_card(card, pos)
	elif pos == "手牌":
		手牌.remove_card(card)
	elif pos == "行动":
		行动.remove_card(card)
	
	assert(!card.get_parent(), "有父节点")
	card.remove_from_group(pos)
	

func get_posi(pos:String) -> Vector2:
	if pos in ["白区", "绿区", "蓝区" ,"红区"]:
		return 卡牌五区.get_posi(pos)
	if pos == "手牌" and !is_c0ntrol:
		return 卡牌五区.get_posi(pos)
	return Vector2()




func _card_change_手牌(arr:Array) -> void:
	手牌.cards改变(arr)




func display() -> void:
	var path:String
	if life_sys.种类 == "nocard":
		path = 文件路径.png_nocard + life_sys.nam + "/.png"
	elif life_sys.种类 == "character":
		path = 文件路径.png_character + life_sys.nam + "/.png"
	
	if FileAccess.file_exists(path):
		life图.texture = load(path)
	else :
		life图.texture = preload(文件路径.png_test)
