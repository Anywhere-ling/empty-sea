extends Node

@onready var 最终行动系统: Node = %最终行动系统
@onready var buff系统: Node = %buff系统
@onready var 发动判断系统: Node = %发动判断系统
@onready var 连锁系统: Node = %连锁系统
@onready var 回合系统: Node = %回合系统
@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统

signal 数据返回


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var 自然下降的卡牌:Dictionary[战斗_单位管理系统.Card_sys, Array]



func 打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> String:
	var ret:String = ""
	if card.get_value("种类") in ["攻击"]:
		var 返回:Array = [false]
		event_bus.subscribe("战斗_请求选择单位返回", func(a):
			返回[0] = true
			返回.append(a)
			emit_signal("数据返回")
			, 1, true)
		event_bus.push_event("战斗_请求选择单位", [life, card.get_value("mp")])
		if !返回[0]:
			await 数据返回
		var tar_life:战斗_单位管理系统.Life_sys = 返回[1]
		if tar_life :
			life.state = ["攻击"]
			life.att_life = tar_life
			ret = "启动"
			最终行动系统.行动打出(life, card)
	elif card.get_value("种类") in ["防御"]:
		life.state = ["防御"]
		最终行动系统.行动打出(life, card)
		ret = "启动"
	elif card.get_value("种类") in ["法术"]:
		var 返回:Array = [false]
		event_bus.subscribe("战斗_请求选择一格返回", func(a):
			返回[0] = true
			返回.append(a)
			emit_signal("数据返回")
			, 1, true)
		event_bus.push_event("战斗_请求选择一格", [life, life.cards_pos["场上"], ["卡牌"]])
		if !返回[0]:
			await 数据返回
		var pos:战斗_单位管理系统.Card_pos_sys = 返回[1]
		if pos:
			最终行动系统.非行动打出(life, card, pos)
			ret = "打出"
	elif card.get_value("种类") in ["仪式"]:
		var 返回:Array = [false]
		event_bus.subscribe("战斗_请求选择一格返回", func(a):
			返回[0] = true
			返回.append(a)
			emit_signal("数据返回")
			, 1, true)
		event_bus.push_event("战斗_请求选择一格", [life, life.cards_pos["场上"], ["纵向"]])
		if !返回[0]:
			await 数据返回
		var pos:战斗_单位管理系统.Card_pos_sys = 返回[1]
		if pos:
			最终行动系统.构造(life, card, pos)
			ret = "启动"
	
	event_bus.push_event("战斗_日志记录", [name, "打出", [life, card], ret])
	return ret



func 发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "发动", [life, card], null])
	
	if card.get_parent().nam in ["行动", "场上"]:
		最终行动系统.场上发动(life, card)
		发动场上的效果(life, card, "直接")
	else:
		var o_pos:String = card.get_parent().nam
		var 返回:Array = [false]
		event_bus.subscribe("战斗_请求选择一格返回", func(a):
			返回[0] = true
			返回.append(a)
			emit_signal("数据返回")
			, 1, true)
		event_bus.push_event("战斗_请求选择一格", [life, life.cards_pos["场上"], ["卡牌"]])
		if !返回[0]:
			await 数据返回
		var pos:战斗_单位管理系统.Card_pos_sys = 返回[1]
		if !pos:
			event_bus.push_event("战斗_日志记录", [name, "发动", [life, card], false])
			return
		最终行动系统.非场上发动(life, card, pos)
		发动场上的效果(life, card, o_pos)


func 发动场上的效果(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, effect_mode:String) -> void:
	var arr_eff:Array
	var cost_mode:String = ""
	if effect_mode == "启动":
		自然下降的卡牌.erase(card)
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has("启动"):
				if 发动判断系统.卡牌发动判断_单个效果(life, card, "场上", effect, 连锁系统.now_speed):
					arr_eff.append(effect)
	elif effect_mode == "攻击前":
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has("攻击前"):
				if 发动判断系统.卡牌发动判断_单个效果(life, card, "", effect, 连锁系统.now_speed):
					arr_eff.append(effect)		
	elif effect_mode in ["手牌", "绿区", "蓝区", "白区", "红区"]:
		cost_mode = "非打出"
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has(effect_mode):
				if 发动判断系统.卡牌发动判断_单个效果(life, card, effect_mode, effect, 连锁系统.now_speed):
					arr_eff.append(effect)
		自然下降的卡牌[card] = [effect_mode, life]
		card.add_history("自然下降", 回合系统.turn, 回合系统.period, effect_mode)
	elif effect_mode == "打出":
		cost_mode = "打出"
		arr_eff = 发动判断系统.卡牌发动判断(life, card, "场上", 连锁系统.now_speed)
		自然下降的卡牌[card] = [effect_mode, life]
		card.add_history("自然下降", 回合系统.turn, 回合系统.period, effect_mode)
	elif effect_mode == "直接":
		cost_mode = "直接"
		arr_eff = 发动判断系统.卡牌发动判断(life, card, "场上", 连锁系统.now_speed)
	
	var arr_int:Array[int] = []
	for effect:战斗_单位管理系统.Effect_sys in arr_eff:
		arr_int.append(card.effects.find(effect))
	
	event_bus.push_event("战斗_日志记录", [name, "发动场上的效果", [card, effect_mode], [card, arr_int, cost_mode]])
	
	event_bus.push_event("战斗_选择效果并发动", [life, card, arr_int, cost_mode])


func get_可用的格子(pos_arr:Array, condition:Array) -> Array:
	pos_arr = pos_arr.duplicate(true)
	var life:战斗_单位管理系统.Life_sys = pos_arr[0].get_parent()
	var erase_pos:Array[战斗_单位管理系统.Card_pos_sys] = []
	for pos:战斗_单位管理系统.Card_pos_sys in pos_arr:
		for i:String in condition:
			if i == "卡牌":
				if !pos.cards == []:
					erase_pos.append(pos)
			
			elif pos.cards == []:
				pass
			
			elif i == "纵向":
				if pos.cards[0].direction:
					erase_pos.append(pos)
			elif i == "横向":
				if !pos.cards[0].direction:
					erase_pos.append(pos)
	
	for pos:战斗_单位管理系统.Card_pos_sys in erase_pos:
		pos_arr.erase(pos)
	
	event_bus.push_event("战斗_日志记录", [name, "get_可用的格子", [pos_arr, condition], pos_arr])
	return pos_arr


func 自动下降() -> void:
	event_bus.push_event("战斗_日志记录", [name, "自动下降", [], null])
	for card:战斗_单位管理系统.Card_sys in 自然下降的卡牌:
		if !card.own:
			最终行动系统.释放(自然下降的卡牌[card][1], card)
			continue
		if !card.get_parent().nam in ["场上", "行动"]:
			continue
		var life:战斗_单位管理系统.Life_sys = card.own
		if 自然下降的卡牌[card][0] in ["绿区"]:
			await 最终行动系统.加入(life, card, life.cards_pos["蓝区"])
		elif 自然下降的卡牌[card][0] in ["蓝区", "红区"]:
			await 最终行动系统.加入(life, card, life.cards_pos["白区"])
		else:
			await 最终行动系统.加入(life, card, life.cards_pos["绿区"])
	自然下降的卡牌 = {}
