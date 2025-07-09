extends Node


@onready var 最终行动系统: Node = $"../../最终行动系统"
@onready var buff系统: Node = $"../buff系统"
@onready var 发动判断系统: Node = %发动判断系统
@onready var 连锁系统: Node = $"../../连锁系统"

signal 数据返回


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var 自然下降的卡牌:Dictionary[战斗_单位管理系统.Card_sys, Array]

func 打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "打出", [life, card], null])
	
	if card.get_value("种类") in ["攻击"]:
		var tar_life:战斗_单位管理系统.Life_sys
		event_bus.subscribe("战斗_请求选择单位返回", func(a):
			emit_signal("数据返回")
			tar_life = a
			, 1, true)
		event_bus.push_event("战斗_请求选择单位", [life])
		await 数据返回
		if !tar_life :
			event_bus.push_event("战斗_日志记录", [name, "打出", [life, card], false])
			return
		else :
			life.state = ["攻击"]
			life.att_life = tar_life
		最终行动系统.行动打出(life, card)
	elif card.get_value("种类") in ["防御"]:
		life.state = ["防御"]
		最终行动系统.行动打出(life, card)
	elif card.get_value("种类") in ["法术"]:
		var pos:战斗_单位管理系统.Card_pos_sys
		event_bus.subscribe("战斗_请求选择一格返回", func(a):
			emit_signal("数据返回")
			pos = a
			, 1, true)
		event_bus.push_event("战斗_请求选择一格", [life, life.cards_pos["场上"], "卡牌"])
		await 数据返回
		if !pos:
			event_bus.push_event("战斗_日志记录", [name, "打出", [life, card], false])
			return
		最终行动系统.非行动打出(life, card, pos)
	elif card.get_value("种类") in ["仪式"]:
		var pos:战斗_单位管理系统.Card_pos_sys
		event_bus.subscribe("战斗_请求选择一格返回", func(a):
			emit_signal("数据返回")
			pos = a
			, 1, true)
		event_bus.push_event("战斗_请求选择一格", [life, life.cards_pos["场上"], "纵向"])
		await 数据返回
		if !pos:
			event_bus.push_event("战斗_日志记录", [name, "非行动打出", [life, card], false])
			return
		最终行动系统.构造(life, card, pos)


func 发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "发动", [life, card], null])
	
	if card.get_parent().name in ["行动", "场上"]:
		最终行动系统.场上发动(life, card)
	else:
		var pos:战斗_单位管理系统.Card_pos_sys
		event_bus.subscribe("战斗_请求选择一格返回", func(a):
			emit_signal("数据返回")
			pos = a
			, 1, true)
		event_bus.push_event("战斗_请求选择一格", [life, life.cards_pos["场上"], "卡牌"])
		await 数据返回
		if !pos:
			event_bus.push_event("战斗_日志记录", [name, "发动", [life, card], false])
			return
		最终行动系统.非场上发动(life, card, pos)


func 发动场上的效果(card:战斗_单位管理系统.Card_sys, effect_mode:String) -> void:
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	var arr_eff:Array[战斗_单位管理系统.Effect_sys]
	var cost_mode:String = ""
	if effect_mode == "启动":
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has("启动"):
				if 发动判断系统.卡牌发动判断_单个效果(life, card, "", effect, 连锁系统.now_time_take):
					arr_eff.append(effect)
	elif effect_mode == "攻击前":
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has("攻击前"):
				if 发动判断系统.卡牌发动判断_单个效果(life, card, "", effect, 连锁系统.now_time_take):
					arr_eff.append(effect)		
	elif effect_mode in ["手牌", "绿区", "蓝区", "白区", "红区"]:
		cost_mode = "非打出"
		自然下降的卡牌[card] = [effect_mode, life]
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has(effect_mode):
				if 发动判断系统.卡牌发动判断_单个效果(life, card, "", effect, 连锁系统.now_time_take):
					arr_eff.append(effect)
	elif effect_mode == "打出":
		cost_mode = "打出"
		自然下降的卡牌[card] = [effect_mode, life]
		arr_eff = 发动判断系统.卡牌发动判断(card, 连锁系统.now_time_take)
	elif effect_mode == "直接":
		arr_eff = 发动判断系统.卡牌发动判断(card, 连锁系统.now_time_take)
	
	var arr_int:Array[int] = []
	for effect:战斗_单位管理系统.Effect_sys in arr_eff:
		arr_int.append(card.effects.find(effect))
	
	event_bus.push_event("战斗_日志记录", [name, "发动场上的效果", [card, effect_mode], [card, arr_int, cost_mode]])
	event_bus.push_event("战斗_选择效果并发动", [card, arr_int, cost_mode])


func get_可用的格子(pos_arr:Array[战斗_单位管理系统.Card_pos_sys], condition:Array[String]) -> Array[战斗_单位管理系统.Card_pos_sys]:
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
	for card:战斗_单位管理系统.Card_sys in 自然下降的卡牌:
		var life:战斗_单位管理系统.Life_sys = 自然下降的卡牌[card][1]
		if 自然下降的卡牌[card][0] in ["绿区"]:
			await 最终行动系统.加入(life, card, life.cards_pos["蓝区"])
		elif 自然下降的卡牌[card][0] in ["蓝区", "红区"]:
			await 最终行动系统.加入(life, card, life.cards_pos["白区"])
		else:
			await 最终行动系统.加入(life, card, life.cards_pos["绿区"])
