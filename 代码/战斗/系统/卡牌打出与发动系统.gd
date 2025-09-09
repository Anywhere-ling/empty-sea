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
@onready var 场地系统: Node = %场地系统
@onready var 二级行动系统: Node = %二级行动系统




var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var 自然下降的卡牌:Dictionary



func 打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys = null) -> bool:
	日志系统.callv("录入信息", [name, "打出", [life, card], null])
	
	var ret:String = ""
	if await card.get_value("种类") in ["攻击"]:
		var att_poss:Array = 场地系统.get_可攻击场上(life)
		if att_poss:
			var poss:Array = await 单位控制系统.请求选择多格(life, "攻击!", att_poss, 1, 0)
			if poss:
				life.state = ["攻击"]
				life.att_life = poss[0].get_parent()
		ret = "启动"
		_检查行动冲突(life)
		await 最终行动系统.行动打出(life, card)
	elif await card.get_value("种类") in ["防御"]:
		life.state = ["防御"]
		_检查行动冲突(life)
		await 最终行动系统.行动打出(life, card)
		ret = "启动"
	elif await card.get_value("种类") in ["法术"]:
		if !pos:
			pos = await 单位控制系统.请求选择一格(life, 场地系统.get_可用场上(life, "手牌", 0))
		if !pos:
			return false
		await 最终行动系统.非行动打出(life, card, pos)
		ret = "打出"
	elif await card.get_value("种类") in ["仪式"]:
		if !await 构造(life, card, true, pos):
			return false
		ret = "启动"
	eraes_自动下降(card)
	await 发动场上的效果(life, card, ret)
	
	return true



func 发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	日志系统.callv("录入信息", [name, "发动", [life, card], null])
	
	if card.get_parent().nam in ["行动", "场上"]:
		await 最终行动系统.场上发动(life, card)
		await 发动场上的效果(life, card, "直接")
	else:
		var o_pos:String = card.get_parent().nam
		var pos:战斗_单位管理系统.Card_pos_sys = await 单位控制系统.请求选择一格(life, 场地系统.get_可用场上(life, card.pos, card.get_value("mp")))
		if !pos:
			return false
		await 最终行动系统.非场上发动(life, card, pos)
		await 发动场上的效果(life, card, o_pos)
	
	return true



func 发动场上的效果(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, effect_mode:String) -> void:
	var arr_eff:Array
	if effect_mode == "启动":
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has("启动"):
				连锁系统.add_可发动的效果(effect, [card, life, null])
		
	elif effect_mode == "攻击前":
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has("攻击前"):
				if await 发动判断系统.卡牌发动判断_单个效果(life, card, "", effect):
					arr_eff.append(effect)		
	
	elif effect_mode in ["手牌", "绿区", "蓝区", "白区", "红区"]:
		if card.get_value("种类") == "仪式":
			var ind:int = 单位管理系统.get_数据改变唯一标识()
			card.add_value("种类", ["等", "法术", ind])
			await 最终行动系统.图形化数据改变(card.get_所属life(), card, "种类")
		
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has(effect_mode):
				if await 发动判断系统.卡牌发动判断_单个效果(life, card, effect_mode, effect):
					arr_eff.append(effect)
		add_自动下降(card, effect_mode, life)
		card.add_history("自然下降", 回合系统.turn, 回合系统.period, effect_mode)
	
	elif effect_mode == "打出":
		arr_eff = await 发动判断系统.卡牌发动判断(life, card, "场上")
		add_自动下降(card, effect_mode, life)
		card.add_history("自然下降", 回合系统.turn, 回合系统.period, effect_mode)
	
	elif effect_mode == "直接":
		arr_eff = await 发动判断系统.卡牌发动判断(life, card, "场上")
	
	var arr_int:Array[int] = []
	for effect:战斗_单位管理系统.Effect_sys in arr_eff:
		arr_int.append(card.effects.find(effect))
	
	日志系统.callv("录入信息", [name, "发动场上的效果", [card, effect_mode], [card, arr_int, effect_mode]])
	
	if 连锁系统.chain_state != 2:
		await 选择效果并发动(life, card, arr_int, effect_mode)



func _处理卡牌消耗(card:战斗_单位管理系统.Card_sys, effect_mode:String) -> int:
	var life:战斗_单位管理系统.Life_sys = card.get_所属life()
	var ret:int = 0
	if effect_mode in ["直接", "攻击前"]:
		pass
	
	var cost:int
	if card.get_value("种类") in ["攻击", "防御"]:
		cost = card.get_value("sp")
	elif card.get_value("种类") in ["法术", "仪式"]:
		cost = card.get_value("mp")
	else:
		assert(true, "超出可处理类型")
	
	if effect_mode in ["启动"]:
		var cards:Array[战斗_单位管理系统.Card_sys]
		for i:战斗_单位管理系统.Card_sys in life.cards_pos["绿区"].cards:
			if i.appear != 0:
				cards.append(i)
		
		cards.shuffle()
		if cost >= len(cards):
			for i:战斗_单位管理系统.Card_sys in cards:
				await 最终行动系统.反转(life, i)
				ret += 1
		else :
			for i:int in cost:
				await 最终行动系统.反转(life, cards[i])
				ret += 1
	
	elif effect_mode in ["打出", "手牌", "白区"]:
		var cards:Array[战斗_单位管理系统.Card_sys]
		for i:战斗_单位管理系统.Card_sys in life.cards_pos["白区"].cards:
			if i.appear == 0:
				cards.append(i)
		
		cards.shuffle()
		if cost >= len(cards):
			for i:战斗_单位管理系统.Card_sys in cards:
				await 二级行动系统.填入(life, card, i)
				ret += 1
		else :
			for i:int in cost:
				await 二级行动系统.填入(life, card, cards[i])
				ret += 1
	
	elif effect_mode in ["绿区"]:
		var cards:Array[战斗_单位管理系统.Card_sys]
		for i:战斗_单位管理系统.Card_sys in life.cards_pos["绿区"].cards:
			if i.appear != 0:
				cards.append(i)
		
		cards.shuffle()
		if cost >= len(cards):
			for i:战斗_单位管理系统.Card_sys in cards:
				await 二级行动系统.填入(life, card, i)
				ret += 1
		else :
			for i:int in cost:
				await 二级行动系统.填入(life, card, cards[i])
				ret += 1
	
	elif effect_mode in ["蓝区", "红区"]:
		var cards:Array[战斗_单位管理系统.Card_sys]
		for i:战斗_单位管理系统.Card_sys in life.cards_pos["蓝区"].cards:
			if i.appear != 0:
				cards.append(i)
		
		cards.shuffle()
		if cost >= len(cards):
			for i:战斗_单位管理系统.Card_sys in cards:
				await 二级行动系统.填入(life, card, i)
				ret += 1
		else :
			for i:int in cost:
				await 二级行动系统.填入(life, card, cards[i])
				ret += 1
	
			
	
	await 最终行动系统.等待动画完成()
	日志系统.callv("录入信息", [name, "_处理卡牌消耗", [card, effect_mode], ret])
	return ret

func 选择效果并发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, arr_int:Array[int], effect_mode:String) -> void:
	日志系统.callv("录入信息", [name, "选择效果并发动", [card, arr_int, effect_mode], null])
	
	var effect_int:int = -1
	if arr_int != []:
		effect_int = await 单位控制系统.control[life].选择效果发动(card, arr_int)
	_重设效果状态(life)
	await 最终行动系统.等待动画完成
	if effect_int != -1 and await 连锁系统.add_chain(card.effects[effect_int]):
		await 连锁系统.set_now_speed(card.effects[effect_int], await _处理卡牌消耗(card, effect_mode))
		life.add_history("发动", 回合系统.turn, 回合系统.period, card)
		card.add_history("发动", 回合系统.turn, 回合系统.period)
		#buff判断
		await buff系统.单位与全部buff判断("发动", [null, life, card])
		await 连锁系统.请求进行下一连锁()
	#没有发动效果
	else :
		if effect_mode == "启动":
			await _处理卡牌消耗(card, effect_mode)
		if 连锁系统.chain_state == 1:
			await 连锁系统.start()
		await 行动组结束()

func 合成(cards:Array) -> void:
	var card1:战斗_单位管理系统.Card_sys = cards[0]
	var card2:战斗_单位管理系统.Card_sys = cards[1]
	var cards3:Array = cards[2]
	var life1:战斗_单位管理系统.Life_sys = card1.get_所属life()
	var life2:战斗_单位管理系统.Life_sys = card2.get_所属life()
	
	var cards4:Array
	
	if card2.get_parent().nam == "场上":
		await 二级行动系统.加入(life2, card2, life2.cards_pos["手牌"])
	else :
		await 二级行动系统.加入(life2, card2, life2.cards_pos["绿区"])
	
	
	for card3:战斗_单位管理系统.Card_sys in cards3:
		var life3:战斗_单位管理系统.Life_sys = card3.get_所属life()
		if card2.pos == "场上":
			await 二级行动系统.加入(life3, card3, life3.cards_pos["绿区"])
			cards4.append(card3)
		else :
			await 最终行动系统.释放(life3, card3)
	
	await 构造(life1, card1, false)
	
	await buff系统.单位与全部buff判断("合成", [null, life1, card1, card2, cards4])
	await 发动场上的效果(life1, card1, "启动")

func 构造(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, 可以取消:bool = true, pos:战斗_单位管理系统.Card_pos_sys = null) -> bool:
	if !pos:
		pos = await 单位控制系统.请求选择一格(life, 场地系统.get_可用场上(life, "手牌", 0), 可以取消)
	if !pos:
		return false
	
	await 二级行动系统.构造(life, card, pos)
	
	
	return true



func _重设效果状态(life:战斗_单位管理系统.Life_sys) -> void:
	for card:战斗_单位管理系统.Card_sys in life.get_all_cards():
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			effect.set_颜色信息("")



func 行动组结束() -> void:
	await _整理()
	await 连锁系统.请求新连锁()



func 自动下降(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "自动下降", [], null])
	if !自然下降的卡牌.has(life):
		return
	
	for card:战斗_单位管理系统.Card_sys in 自然下降的卡牌[life]:
		if card.appear == 0:
			continue
		
		if !card.get_value("特征").has("下降"):
			continue
		eraes_自动下降(card)
		
		if !card.get_parent().nam in ["场上", "行动"]:
			continue
		if card.direction == 0:
			continue
		
		var pos_nam:String = 自然下降的卡牌[life][card]
		if !card.get_own():
			await 最终行动系统.释放(自然下降的卡牌[card][1], card)
			continue
		if pos_nam in ["绿区"]:
			await 二级行动系统.加入(life, card, life.cards_pos["蓝区"])
		elif pos_nam in ["蓝区", "红区"]:
			var tar_pos:战斗_单位管理系统.Pos_cs_sys = 场地系统.get_场上(3, card.get_parent().y)
			for i in card.get_源(true) + card.get_源(false):
				await 二级行动系统.流填入(life, i, tar_pos)
			
			await 二级行动系统.加入(life, card, life.cards_pos["白区"])
		else:
			await 二级行动系统.加入(life, card, life.cards_pos["绿区"])
	
	自然下降的卡牌[life] = {}
	await 最终行动系统.等待动画完成()

func eraes_自动下降(card:战斗_单位管理系统.Card_sys) -> void:
	card.remove_信息特征("下降")

func add_自动下降(card:战斗_单位管理系统.Card_sys, mode:String, life:战斗_单位管理系统.Life_sys) -> void:
	if !自然下降的卡牌.has(life):
		自然下降的卡牌[life] = {}
	if mode != "":
		自然下降的卡牌[life][card] = mode
	elif !自然下降的卡牌[life].has(card):
		自然下降的卡牌[life][card] = "绿区"
	
	if !card.get_value("特征").has("下降"):
		card.add_信息特征("下降")



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
						add_自动下降(card, "", life)
					elif !card.state:
						add_自动下降(card, "", life)

	await 最终行动系统.等待动画完成()


func _检查行动冲突(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_战斗_请求检查行动冲突的信号", [life], null])
	
	for card:战斗_单位管理系统.Card_sys in life.cards_pos["行动"].cards:
		if !await card.get_value("种类") in life.state:
			二级行动系统.破坏(life, card)
