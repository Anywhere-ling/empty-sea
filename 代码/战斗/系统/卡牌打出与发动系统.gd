extends Node

@onready var 最终行动系统: Node = %最终行动系统
@onready var buff系统: Node = %buff系统
@onready var 发动判断系统: Node = %发动判断系统
@onready var 连锁系统: Node = %连锁系统
@onready var 回合系统: Node = %回合系统
@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 单位控制系统: Node = %单位控制系统
@onready var 释放与源: Node = %释放与源
@onready var 日志系统: 战斗_日志系统 = %日志系统




var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var 自然下降的卡牌:Dictionary[战斗_单位管理系统.Card_sys, Array]



func 打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> void:
	日志系统.callv("录入信息", [name, "打出", [life, card], null])
	
	var ret:String = ""
	if await card.get_value("种类") in ["攻击"]:
		var tar_life:战斗_单位管理系统.Life_sys = life.face_life
		if tar_life :
			life.state = ["攻击"]
			life.att_life = tar_life
			ret = "启动"
			await 最终行动系统.行动打出(life, card)
	elif await card.get_value("种类") in ["防御"]:
		life.state = ["防御"]
		await 最终行动系统.行动打出(life, card)
		ret = "启动"
	elif await card.get_value("种类") in ["法术"]:
		var pos:战斗_单位管理系统.Card_pos_sys = await 单位控制系统.请求选择一格(life, life.cards_pos["场上"], ["卡牌"])
		if pos:
			await 最终行动系统.非行动打出(life, card, pos)
			ret = "打出"
	elif await card.get_value("种类") in ["仪式"]:
		var pos:战斗_单位管理系统.Card_pos_sys = await 单位控制系统.请求选择一格(life, life.cards_pos["场上"], ["卡牌"])
		if pos:
			await 最终行动系统.构造(life, card, pos)
			ret = "启动"
	await 发动场上的效果(life, card, ret)



func 发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> void:
	日志系统.callv("录入信息", [name, "发动", [life, card], null])
	
	if card.get_parent().nam in ["行动", "场上"]:
		await 最终行动系统.场上发动(life, card)
		await 发动场上的效果(life, card, "直接")
	else:
		var o_pos:String = card.get_parent().nam
		var pos:战斗_单位管理系统.Card_pos_sys = await 单位控制系统.请求选择一格(life, life.cards_pos["场上"], ["纵向"])
		if !pos:
			日志系统.callv("录入信息", [name, "发动", [life, card], null])
			return
		await 最终行动系统.非场上发动(life, card, pos)
		await 发动场上的效果(life, card, o_pos)


func 发动场上的效果(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, effect_mode:String) -> void:
	var arr_eff:Array
	var cost_mode:String = ""
	if effect_mode == "启动":
		if 连锁系统.chain_state == 2:
			for effect:战斗_单位管理系统.Effect_sys in card.effects:
				if effect.features.has("启动"):
					连锁系统.next_可发动的效果[effect] = [card, life, null]
			return
		cost_mode = "正"
		自然下降的卡牌.erase(card)
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has("启动"):
				if await 发动判断系统.卡牌发动判断_单个效果(life, card, "场上", effect, 连锁系统.now_speed, ["启动"]):
					arr_eff.append(effect)
	elif effect_mode == "攻击前":
		cost_mode = "直接"
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has("攻击前"):
				if await 发动判断系统.卡牌发动判断_单个效果(life, card, "", effect, 连锁系统.now_speed):
					arr_eff.append(effect)		
	elif effect_mode in ["手牌", "绿区", "蓝区", "白区", "红区"]:
		if effect_mode in ["白区", "蓝区"]:
			cost_mode = "正"
		else :
			cost_mode = "负"
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has(effect_mode):
				if await 发动判断系统.卡牌发动判断_单个效果(life, card, effect_mode, effect, 连锁系统.now_speed):
					arr_eff.append(effect)
		自然下降的卡牌[card] = [effect_mode, life]
		card.add_history("自然下降", 回合系统.turn, 回合系统.period, effect_mode)
	elif effect_mode == "打出":
		cost_mode = "正"
		arr_eff = await 发动判断系统.卡牌发动判断(life, card, "场上", 连锁系统.now_speed)
		自然下降的卡牌[card] = [effect_mode, life]
		card.add_history("自然下降", 回合系统.turn, 回合系统.period, effect_mode)
	elif effect_mode == "直接":
		cost_mode = "直接"
		arr_eff = await 发动判断系统.卡牌发动判断(life, card, "场上", 连锁系统.now_speed)
	
	var arr_int:Array[int] = []
	for effect:战斗_单位管理系统.Effect_sys in arr_eff:
		arr_int.append(card.effects.find(effect))
	
	日志系统.callv("录入信息", [name, "发动场上的效果", [card, effect_mode], [card, arr_int, cost_mode]])
	
	await 选择效果并发动(life, card, arr_int, cost_mode)

func _处理卡牌消耗(card:战斗_单位管理系统.Card_sys, cost_mode:String) -> int:
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	var ret:int = 0
	if cost_mode == "直接":
		pass
	
	elif cost_mode == "正":
		if await card.get_value("种类") in ["攻击", "防御"]:
			var cards:Array[战斗_单位管理系统.Card_sys]
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["绿区"].cards:
				if i.appear != 0:
					cards.append(i)
			
			cards.shuffle()
			var sp:int = await card.get_value("sp")
			if sp >= len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					await 最终行动系统.反转(life, i)
					ret += 1
			else :
				for i:int in sp:
					await 最终行动系统.反转(life, cards[i])
					ret += 1
		
		
		
		elif await card.get_value("种类") in ["法术", "仪式"]:
			var cards:Array[战斗_单位管理系统.Card_sys]
			#非源
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["蓝区"].cards:
				if await i.get_value("卡名") != "源":
					cards.append(i)
			
			cards.shuffle()
			var mp:int = await card.get_value("mp")
			if mp > len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					await 最终行动系统.加入(life, i, life.cards_pos["蓝区"])
					mp -= 1
					ret += 1
			else :
				for i:int in mp:
					await 最终行动系统.加入(life, cards[i], life.cards_pos["蓝区"])
					mp -= 1
					ret += 1
			
			#其他
			cards = life.cards_pos["蓝区"].cards.duplicate(true)
			
			cards.shuffle()
			if mp >= len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					await 最终行动系统.加入(life, i, life.cards_pos["白区"])
					ret += 1
			else :
				for i:int in mp:
					await 最终行动系统.加入(life, cards[i], life.cards_pos["白区"])
					ret += 1
	
	
	
	elif cost_mode == "负":
		if await card.get_value("种类") in ["法术", "仪式"]:
			var cards:Array[战斗_单位管理系统.Card_sys]
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["绿区"].cards:
				if i.appear != 0:
					cards.append(i)
			
			cards.shuffle()
			var sp:int = await card.get_value("sp")
			if sp >= len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					await 最终行动系统.加入(life, i, life.cards_pos["蓝区"])
					ret += 1
			else :
				for i:int in sp:
					await 最终行动系统.加入(life, cards[i], life.cards_pos["蓝区"])
					ret += 1
		
		
		
		elif await card.get_value("种类") in ["攻击", "防御"]:
			var cards:Array[战斗_单位管理系统.Card_sys]
			#源
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["蓝区"].cards:
				if await i.get_value("卡名") == "源":
					cards.append(i)
			
			cards.shuffle()
			var mp:int = await card.get_value("mp")
			if mp > len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					await 释放与源.添加释放卡牌(life, i)
					mp -= 1
					ret += 1
			else :
				for i:int in mp:
					await 释放与源.添加释放卡牌(life, cards[i])
					mp -= 1
					ret += 1
			
			#其他
			cards = []
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["蓝区"].cards:
				if i.appear:
					cards.append(i)
			
			cards.shuffle()
			if mp >= len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					await 释放与源.添加释放卡牌(life, i)
					ret += 1
			else :
				for i:int in mp:
					await 释放与源.添加释放卡牌(life, cards[i])
					ret += 1
			
	
	await 最终行动系统.等待动画完成
	日志系统.callv("录入信息", [name, "_处理卡牌消耗", [card, cost_mode], ret])
	return ret

func 选择效果并发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, arr_int:Array[int], cost_mode:String) -> void:
	日志系统.callv("录入信息", [name, "选择效果并发动", [card, arr_int, cost_mode], null])
	
	var effect_int:int = -1
	if arr_int != []:
		effect_int = await 单位控制系统.control[life].选择效果发动(card, arr_int)
	await 最终行动系统.等待动画完成
	if effect_int != -1 and await 连锁系统.add_chain(card.effects[effect_int]):
		await 连锁系统.set_now_speed(card.effects[effect_int], await _处理卡牌消耗(card, cost_mode))
		life.add_history("发动", 回合系统.turn, 回合系统.period, card)
		card.add_history("发动", 回合系统.turn, 回合系统.period)
		#buff判断
		await buff系统.单位与全部buff判断("发动", [null, life, card])
		await 连锁系统.请求进行下一连锁()
	#没有发动效果
	else :
		if cost_mode == "启动":
			await _处理卡牌消耗(card, cost_mode)
		if 连锁系统.chain_state == 1:
			await 连锁系统.start()
		await 行动组结束()

func 合成(cards:Array) -> void:
	var card1:战斗_单位管理系统.Card_sys = cards[0]
	var card2:战斗_单位管理系统.Card_sys = cards[1]
	var cards3:Array = cards[2]
	var life1:战斗_单位管理系统.Life_sys = card1.get_parent().get_parent()
	var life2:战斗_单位管理系统.Life_sys = card2.get_parent().get_parent()
	
	var cards4:Array
	
	if card2.get_parent().nam == "场上":
		await 最终行动系统.加入(life2, card2, life2.cards_pos["手牌"])
	else :
		await 最终行动系统.加入(life2, card2, life2.cards_pos["绿区"])
	
	
	for card3:战斗_单位管理系统.Card_sys in cards3:
		var life3:战斗_单位管理系统.Life_sys = card3.get_parent().get_parent()
		if card2.pos == "场上":
			await 最终行动系统.加入(life3, card3, life3.cards_pos["绿区"])
			cards4.append(card3)
		else :
			await 最终行动系统.释放(life3, card3)
	
	var pos:战斗_单位管理系统.Card_pos_sys = await 单位控制系统.请求选择一格(life1, life1.cards_pos["场上"], ["纵向"])
	await 最终行动系统.构造(life1, card1, pos)
	
	await buff系统.单位与全部buff判断("合成", [null, life1, card1, card2, cards4])
	await 发动场上的效果(life1, card1, "启动")







func 行动组结束() -> void:
	await _自动下降()
	await _整理()
	await 连锁系统.请求新连锁()


func get_可用的格子(pos_arr:Array, condition:Array) -> Array:
	pos_arr = pos_arr.duplicate(true)
	var erase_pos:Array[战斗_单位管理系统.Card_pos_sys] = []
	for pos:战斗_单位管理系统.Card_pos_sys in pos_arr:
		for i:String in condition:
			if i == "卡牌":
				if !pos.cards == []:
					erase_pos.append(pos)
			elif i == "空":
				if pos.cards == []:
					erase_pos.append(pos)
			
			if !pos.cards == []:
			
				if i == "纵向":
					if pos.cards[0].direction:
						erase_pos.append(pos)
				elif i == "横向":
					if !pos.cards[0].direction:
						erase_pos.append(pos)
	
	for pos:战斗_单位管理系统.Card_pos_sys in erase_pos:
		pos_arr.erase(pos)
	
	日志系统.callv("录入信息", [name, "get_可用的格子", [pos_arr, condition], pos_arr])
	return pos_arr


func _自动下降() -> void:
	日志系统.callv("录入信息", [name, "自动下降", [], null])
	for card:战斗_单位管理系统.Card_sys in 自然下降的卡牌:
		if !card.own:
			await 最终行动系统.释放(自然下降的卡牌[card][1], card)
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
	await 最终行动系统.等待动画完成()

func _整理() -> void:
	var lifes:Array
	lifes.append_array(单位管理系统.lifes)
	lifes.append_array(单位管理系统.efils)
	
	for life:战斗_单位管理系统.Life_sys in lifes:
		var cards:Array = life.get_all_cards()
		for card:战斗_单位管理系统.Card_sys in cards:
			if card.pos in ["白区", "绿区", "蓝区" ,"红区", "手牌", "行动"]:
				if !card.direction:
					await 最终行动系统.改变方向(life, card)
			if card.pos in ["手牌", "行动"]:
				if !card.appear:
					await 最终行动系统.反转(life, card)
			elif card.pos in ["白区"]:
				if card.appear:
					await 最终行动系统.反转(life, card)
			if card.get_parent().nam in ["场上"]:
				if card.appear >= 4:
					if !await card.get_value("种类") == "仪式":
						await 最终行动系统.加入(life, card, life.cards_pos["绿区"])
					elif !card.state:
						await 最终行动系统.加入(life, card, life.cards_pos["绿区"])

	await 最终行动系统.等待动画完成()
