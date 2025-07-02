extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 回合系统: Node = %回合系统
@onready var 最终行动系统: Node = $最终行动系统
@onready var 卡牌打出与发动系统: Node = $单位管理系统/卡牌打出与发动系统
@onready var 连锁系统: Node = $连锁系统
@onready var 释放与源: Node = $释放与源


var control:Dictionary[战斗_单位管理系统.Life_sys, 战斗_单位控制_nocard]

var 没有第一次抽牌的单位:Array[战斗_单位管理系统.Life_sys]



func _ready() -> void:
	_绑定信号()



func add_life(life, is_positive:bool) -> void:
	#生成life
	if life is String:
		life = 单位管理系统.create_life(life, is_positive)
	
	#绑定控制
	if life.data["种类"] == "nocard":
		control[life] = 战斗_单位控制_nocard.new(life)
	
	#加入回合
	回合系统.join_life(life)
	没有第一次抽牌的单位.append(life)
	
	#创造牌库
	单位管理系统.创造牌库(life, control[life].创造牌库())


func _第一次抽牌(life:战斗_单位管理系统.Life_sys) -> void:
	pass


func _行动阶段(life:战斗_单位管理系统.Life_sys) -> void:
	pass


func _处理卡牌消耗(card:战斗_单位管理系统.Card_sys, cost_mode:String) -> int:
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	var ret:int = 0
	
	if cost_mode == "":
		pass
	
	elif cost_mode == "打出":
		if card.get_value("种类") in ["攻击", "防御"]:
			var cards:Array[战斗_单位管理系统.Card_sys]
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["绿区"].cards:
				if i.appear != 0:
					cards.append(i)
			
			cards.shuffle()
			var sp:int = card.get_value("sp")
			if sp >= len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					最终行动系统.反转(life, i)
					ret += 1
			else :
				for i:int in sp:
					最终行动系统.反转(life, cards[i])
					ret += 1
	
		elif card.get_value("种类") in ["法术", "仪式"]:
			var cards:Array[战斗_单位管理系统.Card_sys]
			#源
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["蓝区"].cards:
				if i.get_value("卡名") == "源":
					cards.append(i)
			
			cards.shuffle()
			var mp:int = card.get_value("mp")
			if mp > len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					最终行动系统.释放(life, i)
					mp -= 1
					ret += 1
			else :
				for i:int in mp:
					最终行动系统.释放(life, cards[i])
					ret += 1
			
			#其他
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["蓝区"].cards:
				if i.get_value("卡名") != "源":
					cards.append(i)
			
			cards.shuffle()
			if mp >= len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					最终行动系统.释放(life, i)
					ret += 1
			else :
				for i:int in mp:
					最终行动系统.释放(life, cards[i])
					ret += 1
	
	elif cost_mode == "非打出":
		if card.get_value("种类") in ["法术", "仪式"]:
			var cards:Array[战斗_单位管理系统.Card_sys]
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["绿区"].cards:
				if i.appear != 0:
					cards.append(i)
			
			cards.shuffle()
			var sp:int = card.get_value("sp")
			if sp >= len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					最终行动系统.加入(life, i, life.cards_pos["蓝区"])
					ret += 1
			else :
				for i:int in sp:
					最终行动系统.加入(life, cards[i], life.cards_pos["蓝区"])
					ret += 1
	
		elif card.get_value("种类") in ["攻击", "防御"]:
			var cards:Array[战斗_单位管理系统.Card_sys]
			#源
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["蓝区"].cards:
				if i.get_value("卡名") == "源":
					cards.append(i)
			
			cards.shuffle()
			var mp:int = card.get_value("mp")
			if mp > len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					最终行动系统.释放(life, i)
					mp -= 1
					ret += 1
			else :
				for i:int in mp:
					最终行动系统.释放(life, cards[i])
					ret += 1
			
			#其他
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["蓝区"].cards:
				if i.get_value("卡名") != "源":
					cards.append(i)
			
			cards.shuffle()
			if mp >= len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					最终行动系统.释放(life, i)
					ret += 1
			else :
				for i:int in mp:
					最终行动系统.释放(life, cards[i])
					ret += 1
		
	return ret








var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func _绑定信号() -> void:
	event_bus.subscribe("战斗_回合进入行动阶段", _行动阶段)
	event_bus.subscribe("战斗_请求选择", _战斗_请求选择的信号)
	event_bus.subscribe("战斗_请求选择一格", _战斗_请求选择一格的信号)
	event_bus.subscribe("战斗_选择效果并发动", _战斗_选择效果并发动的信号)
	event_bus.subscribe("战斗_释放卡牌", _战斗_释放卡牌的信号)


func _战斗_请求选择的信号(life:战斗_单位管理系统.Life_sys, arr:Array, count:int = 1, is_all:bool = true) -> void:
	var ret:Array = control[life].对象选择(arr, count, is_all)
	event_bus.push_event("战斗_请求选择返回", [ret])


func _战斗_请求选择一格的信号(life:战斗_单位管理系统.Life_sys, arr:Array[战斗_单位管理系统.Card_pos_sys]) -> void:
	arr = 卡牌打出与发动系统.get_可用的格子(arr)
	var ret:战斗_单位管理系统.Card_pos_sys = control[life].选择一格(arr)
	
	event_bus.push_event("战斗_请求选择一格返回", [ret])


func _战斗_选择效果并发动的信号(card:战斗_单位管理系统.Card_sys, arr_int:Array[int], cost_mode:String) -> void:
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	var effect_int:int = control[life].选择效果发动(card, arr_int)
	if 连锁系统.add_chain(card.effects[effect_int]):
		连锁系统.set_now_speed([card.effects[effect_int]], _处理卡牌消耗(card, cost_mode))
	
	
func _战斗_释放卡牌的信号(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> void:
	释放与源.添加释放卡牌(life, card)
	
	
