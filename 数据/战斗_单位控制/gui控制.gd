extends 战斗_单位控制
class_name 战斗_gui控制


@onready var 可选卡牌容器: 战斗_可选卡牌容器 = %可选卡牌容器
@onready var 动画系统: Node = %动画系统
@onready var gui单位管理: Control = %gui单位管理
@onready var 按钮: Control = %按钮
@onready var 打出按钮: Button = %打出按钮
@onready var 发动按钮: Button = %发动按钮

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus


var life_gui:战斗_life

var o_cards:Array = [
	["test打1", "test卡组堆二", 20]
]


func _ready() -> void:
	life_nam = "control"
	种类 = "c0ntrol"
	
	event_bus.subscribe("战斗_显示单位切换", _显示单位切换的信号)


func _显示单位切换的信号(life_gui:战斗_life, p_is_positive:bool) -> void:
	if p_is_positive != is_positive:
		life_sys.face_life = life_gui.life_sys





func 创造牌库() -> Array:
	return 生成牌库(o_cards)


func 确认目标(lifes:Array[战斗_单位管理系统.Life_sys], efils:Array[战斗_单位管理系统.Life_sys]) -> void:
	if lifes.has(life_sys):
		life_sys.face_life = gui单位管理.efils[gui单位管理.efils_ind].life_sys
	else:
		life_sys.face_life = gui单位管理.lifes[gui单位管理.lifes_ind].life_sys


signal test
func 第一次弃牌() -> Array:
	var cards_sys:Array = life_sys.cards_pos["手牌"].cards
	var cards:Array
	for card in cards_sys:
		cards.append(动画系统.对照表["card"][card])
	可选卡牌容器.set_cards(cards, "要弃牌吗", 10, 0, false)
	可选卡牌容器.visible = true
	
	await 可选卡牌容器.确认按下
	var ret:Array
	for i in 可选卡牌容器.free_cards():
		ret.append(i.card_sys)
	
	
	return ret

func 整理手牌() -> Array:
	return []

func 打出(cards:Array[战斗_单位管理系统.Card_sys]) -> 战斗_单位管理系统.Card_sys:
	var cards_gui:Array
	for card in cards:
		cards_gui.append(动画系统.对照表["card"][card])
	可选卡牌容器.set_cards(cards_gui, "要打出吗", 1, 0, false)
	可选卡牌容器.visible = true
	
	await 可选卡牌容器.确认按下
	var ret = 可选卡牌容器.free_cards()[0]
	ret = ret.card_sys
	
	
	return ret

func 发动(cards:Array[战斗_单位管理系统.Card_sys]) -> 战斗_单位管理系统.Card_sys:
	var cards_gui:Array
	for card in cards:
		cards_gui.append(动画系统.对照表["card"][card])
	可选卡牌容器.set_cards(cards_gui, "要发动吗", 1, 0, false)
	可选卡牌容器.visible = true
	
	await 可选卡牌容器.确认按下
	var ret = 可选卡牌容器.free_cards()[0]
	ret = ret.card_sys
	
	
	return ret




func 主要阶段():
	pass

func 主要阶段打出() -> void:
	return

func 主要阶段发动() -> void:
	return

func 主要阶段判断(cards1:Array[战斗_单位管理系统.Card_sys], cards2:Array[战斗_单位管理系统.Card_sys]) -> void:
	发动cards = cards1
	打出cards = cards2


func 结束阶段弃牌() -> Array[战斗_单位管理系统.Card_sys]:
	return []





func 选择效果发动(card:战斗_单位管理系统.Card_sys, arr_int:Array[int]) -> int:
	return 0

func 对象选择(arr:Array, 描述:String = "无", count_max:int = 1, count_min:int = 1):
	pass

func 选择一格(arr:Array[战斗_单位管理系统.Card_pos_sys]) -> 战斗_单位管理系统.Card_pos_sys:
	return

func 选择单位(arr:Array[战斗_单位管理系统.Life_sys]) -> 战斗_单位管理系统.Life_sys:
	return

func 效果选项():
	pass


var 可进行的卡牌:Dictionary

func set_card_mode() -> void:
	for card:Card in 可进行的卡牌:
		card.光圈改变(可进行的卡牌[card])
	


func _on_发动_button_up() -> void:
	pass # Replace with function body.

func _on_打出_button_up() -> void:
	pass # Replace with function body.
