extends 战斗_单位控制
class_name 战斗_gui控制


@onready var 可选卡牌容器: 战斗_可选卡牌容器 = %可选卡牌容器
@onready var 动画系统: Node = %动画系统
@onready var gui单位管理: Control = %gui单位管理
@onready var 按钮: Control = %按钮
@onready var 打出按钮: Button = %打出按钮
@onready var 发动按钮: Button = %发动按钮
@onready var 合成按钮: Button = %合成按钮
@onready var gui效果选择: PanelContainer = %gui效果选择
@onready var gui_场上: 战斗_场上 = %gui_场上
@onready var 回合结束: Button = %回合结束

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus


var life_gui:战斗_life

var o_cards:Array = [
	["海", "剑之坟",  10],
	["内装甲激活", 5],
	["巨人讨灭", 5],
	["剑之坟", 2],
	["潮之高压", "潮汐变化", 10],
]


func _ready() -> void:
	life_nam = "control"
	种类 = "c0ntrol"
	
	event_bus.subscribe("战斗_显示单位切换", _显示单位切换的信号)
	event_bus.subscribe("战斗_卡牌被左键点击", _卡牌_被点击)
	event_bus.subscribe("战斗_左键点击旁边", _卡牌_被点击_取消)
	event_bus.subscribe("战斗_右键点击", _卡牌_被点击_取消)
	
	


func _显示单位切换的信号(p_life_gui:战斗_life, p_is_positive:bool) -> void:
	if p_is_positive != is_positive:
		life_sys.face_life = p_life_gui.life_sys


func set_life_gui(p_life_gui:战斗_life) -> void:
	life_gui = p_life_gui
	动画系统._data转换(life_sys).卡牌五区.按钮按下.connect(_卡牌四区的按钮按下)


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
	if !cards_sys:
		return []
	var test:Array
	for i in 5:
		test.append(cards_sys[i])
	return test
	
	
	
	for card in cards_sys:
		cards.append(动画系统.对照表["card"][card])
	可选卡牌容器.set_cards(cards, "要弃牌吗", 10, 0)
	可选卡牌容器.visible = true
	
	await 可选卡牌容器.按下
	var ret:Array
	for i in 可选卡牌容器.free_cards():
		ret.append(i.card_sys)
	
	
	return ret

func 整理手牌() -> Array:
	return []

func 打出(cards:Array) -> 战斗_单位管理系统.Card_sys:
	return cards[0]
	
	var cards_gui:Array
	if !cards:
		return null
	for card in cards:
		cards_gui.append(动画系统.对照表["card"][card])
	可选卡牌容器.set_cards(cards_gui, "要打出吗", 1, 0)
	可选卡牌容器.visible = true
	
	await 可选卡牌容器.按下
	var ret
	var arr = 可选卡牌容器.free_cards()
	if arr.size() > 0:
		ret = arr[0]
		ret = ret.card_sys
	
	return ret

func 发动(cards:Array) -> 战斗_单位管理系统.Card_sys:
	var cards_gui:Array
	if !cards:
		return null
	for card in cards:
		cards_gui.append(动画系统.对照表["card"][card])
	可选卡牌容器.set_cards(cards_gui, "要发动吗", 1, 0)
	可选卡牌容器.visible = true
	
	await 可选卡牌容器.按下
	var ret
	var arr = 可选卡牌容器.free_cards()
	if arr.size() > 0:
		ret = arr[0]
		ret = ret.card_sys
	
	return ret

func 合成(cards:Dictionary) -> Array:
	var cards_gui1:Array
	if !cards:
		return []
	for card in cards:
		cards_gui1.append(动画系统.对照表["card"][card])
	可选卡牌容器.set_cards(cards_gui1, "要合成吗", 1, 0)
	可选卡牌容器.visible = true
	
	await 可选卡牌容器.按下
	var card1
	var arr1 = 可选卡牌容器.free_cards()
	if arr1.size() > 0:
		card1 = arr1[0].card_sys
	else :
		return []
	
	
	var cards_gui2:Array
	if !cards:
		return []
	for card in cards[card1]:
		cards_gui2.append(动画系统.对照表["card"][card])
	可选卡牌容器.set_cards(cards_gui2, "核心要选哪个呢", 1, 0)
	可选卡牌容器.visible = true
	
	await 可选卡牌容器.按下
	var card2
	var arr2 = 可选卡牌容器.free_cards()
	if arr2.size() > 0:
		card2 = arr2[0].card_sys
	else :
		return []
	
	var cards_gui3:Array
	if !cards:
		return []
	for card in cards[card1][card2][1]:
		cards_gui3.append(动画系统.对照表["card"][card])
	可选卡牌容器.set_cards(cards_gui3, "素材要选哪些呢", cards[card1][card2][0], cards[card1][card2][0])
	可选卡牌容器.visible = true
	
	await 可选卡牌容器.按下
	var card3 = []
	var arr3 = 可选卡牌容器.free_cards()
	if arr3.size() > 0:
		for i in arr3:
			card3.append(i.card_sys)
	else :
		return []
	
	return [card1, card2, card3]



var is_主要阶段:bool = false
func 主要阶段() -> void:
	is_主要阶段 = true

func 主要阶段打出() -> void:
	return

func 主要阶段发动() -> void:
	return


func 主要阶段判断(cards1:Array[战斗_单位管理系统.Card_sys], cards2:Array[战斗_单位管理系统.Card_sys], cards3:Dictionary) -> void:
	发动cards = cards1
	打出cards = cards2
	合成cards = cards3
	
	for card in 打出cards:
		var card_gui:Card = 动画系统._data转换(card)
		if 可进行的卡牌.has(card_gui):
			可进行的卡牌[card_gui] += 2
		else :
			可进行的卡牌[card_gui] = 2
		if card.pos in ["白区", "绿区", "蓝区", "红区"]:
			可进行的区[card.pos][1].append(card)
			可进行的区[card.pos][-1] = 2
	
	for card in 合成cards:
		var card_gui:Card = 动画系统._data转换(card)
		if 可进行的卡牌.has(card_gui):
			可进行的卡牌[card_gui] += 4
		else :
			可进行的卡牌[card_gui] = 4
		if card.pos in ["白区", "绿区", "蓝区", "红区"]:
			可进行的区[card.pos][2].append(card)
			可进行的区[card.pos][-1] = 2
		
	for card in 发动cards:
		var card_gui:Card = 动画系统._data转换(card)
		if 可进行的卡牌.has(card_gui):
			可进行的卡牌[card_gui] += 1
		else :
			可进行的卡牌[card_gui] = 1
		if card.pos in ["白区", "绿区", "蓝区", "红区"]:
			可进行的区[card.pos][0].append(card)
			可进行的区[card.pos][-1] = 1
	
	回合结束.disabled = false
	set_card_mode()


func 结束阶段弃牌() -> Array[战斗_单位管理系统.Card_sys]:
	return []




func 选择效果发动(card:战斗_单位管理系统.Card_sys, arr_int:Array[int]) -> int:
	if arr_int.size() <= 1:
		return arr_int[0]
	
	gui效果选择.set_card(card.data["文本"], arr_int)
	await gui效果选择.确认按下
	return gui效果选择.select


func 对象选择(arr:Array, 描述:String = "无", count_max:int = 1, count_min:int = 1) -> Array:
	var cards_gui:Array
	for card in arr:
		cards_gui.append(动画系统.对照表["card"][card])
	可选卡牌容器.set_cards(cards_gui, 描述, count_max, count_min)
	可选卡牌容器.visible = true
	
	await 可选卡牌容器.按下
	var ret:Array
	for i in 可选卡牌容器.free_cards():
		ret.append(i.card_sys)
	
	return ret


func 选择一格(arr:Array, 描述:String = "无", count_max:int = 1, count_min:int = 0) -> Array:
	gui_场上.set_cards(arr, 描述, count_max, count_min)
	
	await gui_场上.按下
	var ret:Array
	for i in gui_场上.free_cards():
		ret.append(i)
	
	return ret


func 选择单位(arr:Array) -> 战斗_单位管理系统.Life_sys:
	return






func _process(delta: float) -> void:
	if 被点击卡牌:
		if 被点击卡牌 is Card:
			按钮.global_position = 被点击卡牌.顶部.global_position + Vector2(0, -30)
		elif 被点击卡牌 is String:
			按钮.global_position = 动画系统._data转换(life_sys).get_posi(被点击卡牌) + Vector2(0, -20)


var 可进行的卡牌:Dictionary
var 可进行的区:Dictionary = {"白区":[[],[],[],0], "绿区":[[],[],[],0], "蓝区":[[],[],[],0], "红区":[[],[],[],0]}
var 被点击卡牌
func _卡牌_被点击(card:Card) -> void:
	_手牌锁定(false)
	if !可进行的卡牌.has(card):
		return
	被点击卡牌 = card
	
	var num:int = 可进行的卡牌[card]
	var arr:Array
	while num > 0:
		arr.append((num & 1) == 1)
		num = num >> 1
	
	发动按钮.visible = false
	打出按钮.visible = false
	合成按钮.visible = false
	for i in arr.size():
		if arr[i]:
			[发动按钮, 打出按钮, 合成按钮][i].visible = true
	
	_手牌锁定(true)


func _手牌锁定(b:bool) -> void:
	按钮.visible = b
	event_bus.push_event("战斗_gui_手牌锁定", [b])


func _卡牌_被点击_取消() -> void:
	_手牌锁定(false)
	被点击卡牌 = null


func _清除卡牌颜色() -> void:
	for i:Card in 可进行的卡牌:
		i.光圈改变(0)
	可进行的卡牌 = {}
	可进行的区 = {"白区":[[],[],[],0], "绿区":[[],[],[],0], "蓝区":[[],[],[],0], "红区":[[],[],[],0]}
	动画系统._data转换(life_sys).卡牌五区.光圈([0,0,0,0])



func set_card_mode() -> void:
	for card:Card in 可进行的卡牌:
		if 可进行的卡牌[card]%2 == 1:
			card.光圈改变(1)
		else :
			card.光圈改变(2)
	动画系统._data转换(life_sys).卡牌五区.光圈([可进行的区["白区"][-1], 可进行的区["绿区"][-1], 可进行的区["蓝区"][-1], 可进行的区["红区"][-1]])
	

func _卡牌四区的按钮按下(pos:String) -> void:
	_手牌锁定(false)
	被点击卡牌 = pos
	
	发动按钮.visible = false
	打出按钮.visible = false
	合成按钮.visible = false
	
	if 可进行的区[pos][0]:
		发动按钮.visible = true
	if 可进行的区[pos][1]:
		打出按钮.visible = true
	if 可进行的区[pos][2]:
		合成按钮.visible = true
	
	按钮.visible = true
	



func _on_发动_button_up() -> void:
	var card:战斗_单位管理系统.Card_sys
	if 被点击卡牌 is Card:
		card = 被点击卡牌.card_sys
	elif 被点击卡牌 is String:
		card = await 发动(可进行的区[被点击卡牌][0])
	if card:
		动画系统._data转换(card).光圈改变(0)
		emit_signal("主要阶段发动的信号", card)
		回合结束.disabled = true
		_清除卡牌颜色()
		_卡牌_被点击_取消()

func _on_打出_button_up() -> void:
	var card:战斗_单位管理系统.Card_sys
	if 被点击卡牌 is Card:
		card = 被点击卡牌.card_sys
	elif 被点击卡牌 is String:
		card = await 发动(可进行的区[被点击卡牌][1])
	if card:
		动画系统._data转换(card).光圈改变(0)
		emit_signal("主要阶段打出的信号", card)
		回合结束.disabled = true
		_清除卡牌颜色()
		_卡牌_被点击_取消()

func _on_合成按钮_button_up() -> void:
	var card:战斗_单位管理系统.Card_sys
	var cards:Array
	if 被点击卡牌 is Card:
		card = 被点击卡牌.card_sys
		cards = await 合成({card:合成cards[card]})
		if !cards:
			card = null
	elif 被点击卡牌 is String:
		var dic:Dictionary
		for i in 可进行的区[被点击卡牌][2]:
			dic[i] = 合成cards[i]
		cards = await 合成(dic)
		if cards:
			card = cards[0]
	if card:
		动画系统._data转换(card).光圈改变(0)
		emit_signal("合成的信号", cards)
		回合结束.disabled = true
		_清除卡牌颜色()
		_卡牌_被点击_取消()

func _on_回合结束_button_up() -> void:
	for i:Card in 可进行的卡牌:
		i.光圈改变(0)
	可进行的卡牌 = {}
	回合结束.disabled = true
	_清除卡牌颜色()
	_卡牌_被点击_取消()
	emit_signal("结束")
