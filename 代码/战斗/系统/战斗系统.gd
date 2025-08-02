extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 回合系统: Node = %回合系统
@onready var 最终行动系统: Node = %最终行动系统
@onready var 释放与源: Node = %释放与源
@onready var 卡牌打出与发动系统: Node = %卡牌打出与发动系统
@onready var 连锁系统: Node = %连锁系统
@onready var 发动判断系统: Node = %发动判断系统
@onready var buff系统: Node = %buff系统

signal 下一阶段

var control:Dictionary[战斗_单位管理系统.Life_sys, 战斗_单位控制]

var 没有第一次抽牌的单位:Array[战斗_单位管理系统.Life_sys]





func _ready() -> void:
	_绑定信号()
	
	最终行动系统.临时pos = 战斗_单位管理系统.Card_pos_sys.new("临时")



func add_life(life, is_positive:bool) -> void:
	event_bus.push_event("战斗_日志记录", [name, "add_life", [life, is_positive], null])
	
	
	#绑定控制
	var 控制:战斗_单位控制
	if life is String:
		控制 = 战斗_单位控制_nocard.new(life)
	if life is 战斗_单位控制:
		控制 = life
	
	控制.is_positive = is_positive
	
	life = await 最终行动系统.加入战斗(控制, is_positive)
	control[life] = 控制
	
	#加入回合
	回合系统.join_life(life)
	没有第一次抽牌的单位.append(life)
	
	#创造牌库
	await 最终行动系统.创造牌库(life)
	
	

func start() -> void:
	event_bus.push_event("战斗_日志记录", [name, "start", [], null])
	
	回合系统.start()


func _下一阶段的信号(state:String = "") -> void:
	assert(连锁系统.chain_state == 0,"连锁未处理")
	if 最终行动系统.未完成的动画 != 0:
		await 最终行动系统.全部动画完成
	
	event_bus.push_event("战斗_日志记录", [name, "_下一阶段的信号", [state], null])
	
	回合系统.call_deferred("swicth_state", state)
	


func _开始阶段(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_开始阶段", [life], null])
	
	for card:战斗_单位管理系统.Card_sys in life.get_all_cards():
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.count <= 0:
				effect.count += 1
	
	
	await 释放与源.添加源(life)
	
	await buff系统.开始阶段结算buff(life)
	emit_signal("下一阶段")




func _战斗阶段(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_战斗阶段", [life], null])
	
	for card:战斗_单位管理系统.Card_sys in life.cards_pos["行动"].cards:
		if card.get_value("种类") == "攻击":
			await 卡牌打出与发动系统.发动场上的效果(life, card, "攻击前")
			if card.get_parent().nam == "行动":
				await _攻击判断(life, card)
		卡牌打出与发动系统.自然下降的卡牌[card] = ["打出", life]
	await 卡牌打出与发动系统.自动下降()
	emit_signal("下一阶段")

func _攻击判断(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_攻击判断", [life, card], null])
	
	var mode:String = "直接攻击"
	var att_life:战斗_单位管理系统.Life_sys = life.att_life
	var def_cards:Array[战斗_单位管理系统.Card_sys]
	var att_sp:int = card.get_value("sp")
	var att_mp:int = card.get_value("mp")
	var def_sp:int = 0
	var def_mp:int = 0
	for i:战斗_单位管理系统.Card_sys in att_life.cards_pos["行动"].cards:
		if i.get_value("种类") == "防御":
			def_cards.append(i)
			def_sp += i.get_value("sp")
			def_mp += i.get_value("mp")
	
	#判断
	
	
	#处理
	await 最终行动系统.攻击(life, card, mode)
	if mode == "直接攻击":
		for i:int in att_sp:
			if len(att_life.cards_pos["白区"].cards) >= 1:
				await 最终行动系统.加入(att_life, att_life.cards_pos["白区"].cards[0], att_life.cards_pos["红区"])
			elif len(att_life.cards_pos["手牌"].cards) >= 1:
				await 最终行动系统.加入(att_life, att_life.cards_pos["手牌"].cards[0], att_life.cards_pos["红区"])
			else :
				await 最终行动系统.死亡(att_life)
	
	await buff系统.单位与全部buff判断("被攻击", [null, att_life, card])


func _抽牌阶段(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_抽牌阶段", [life], null])
	
	if 没有第一次抽牌的单位.has(life):
		没有第一次抽牌的单位.erase(life)
		await _确认face_life(life)
		await _第一次抽牌(life)
		await _第一次弃牌(life)
		await _整理手牌(life)
		if 回合系统.turn == 0:
			emit_signal("下一阶段", "结束")
			return
	else :
		if life.cards_pos["白区"].cards == [] and life.cards_pos["手牌"].cards == []:
			await 最终行动系统.死亡(life)
		else:
			await 最终行动系统.抽牌(life)
		emit_signal("下一阶段")

func _第一次抽牌(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_第一次抽牌", [life], null])
	
	var hand_cadrs:int = 0
	var speed:int = await life.get_value("speed")
	while hand_cadrs < max(speed, 1):
		if life.cards_pos["白区"].cards == []:
			return
		var card:战斗_单位管理系统.Card_sys = life.cards_pos["白区"].cards[0]
		await 最终行动系统.反转(life, card)
		if card.get_value("种类") in ["攻击", "防御"]:
			await 最终行动系统.加入(life, card, life.cards_pos["手牌"])
			hand_cadrs += 1
		else :
			await 最终行动系统.加入(life, card, life.cards_pos["蓝区"])

func _第一次弃牌(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_第一次弃牌", [life], null])
	
	var cards:Array = await control[life].第一次弃牌()
	for card:战斗_单位管理系统.Card_sys in cards:
		await 最终行动系统.加入(life, card, life.cards_pos["绿区"])
		await 最终行动系统.抽牌(life)

func _整理手牌(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_整理手牌", [life], null])
	
	var cards:Array = await control[life].整理手牌()
	if cards:
		life.cards_pos["手牌"].cards.sort_custom(func(a,b):return cards.find(a) < cards.find(b))

	最终行动系统.整理手牌(life)


func _确认face_life(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_确认face_life", [life], null])
	
	await control[life].确认目标(单位管理系统.lifes, 单位管理系统.efils)




func _行动阶段(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_行动阶段", [life], null])
	
	var cards:Array[战斗_单位管理系统.Card_sys] = 发动判断系统.单位行动阶段打出判断(life)
	var card:战斗_单位管理系统.Card_sys = await control[life].打出(cards)
	if card:
		var effect_mode = await 卡牌打出与发动系统.打出(life, card)
		卡牌打出与发动系统.发动场上的效果(life, card, effect_mode)
	emit_signal("下一阶段")




func _主要阶段(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_主要阶段", [life], null])
	
	_主要阶段判断(life)
	control[life].主要阶段发动的信号.connect(_主要阶段发动)
	control[life].主要阶段打出的信号.connect(_主要阶段打出)
	control[life].结束.connect(func():emit_signal("下一阶段"), 4)
	control[life].主要阶段()

func _主要阶段打出(card:战斗_单位管理系统.Card_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_主要阶段打出", [card], null])
	
	var life:战斗_单位管理系统.Life_sys = 回合系统.current_life
	var effect_mode = await 卡牌打出与发动系统.打出(life, card)
	卡牌打出与发动系统.发动场上的效果(life, card, effect_mode)
	
	if 连锁系统.chain_state:
		await 连锁系统.连锁处理结束
	_主要阶段判断(life)

func _主要阶段发动(card:战斗_单位管理系统.Card_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_主要阶段发动", [card], null])
	
	var life:战斗_单位管理系统.Life_sys = 回合系统.current_life
	await 卡牌打出与发动系统.发动(life, card)
	
	if 连锁系统.chain_state:
		await 连锁系统.连锁处理结束
	_主要阶段判断(life)

func _主要阶段判断(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_主要阶段判断", [life], null])
	
	var 发动cards:Array[战斗_单位管理系统.Card_sys] = await 发动判断系统.单位主要阶段发动判断(life)
	var 打出cards:Array[战斗_单位管理系统.Card_sys] = await 发动判断系统.单位主要阶段打出判断(life)
	control[life].主要阶段判断(发动cards, 打出cards)



func _结束阶段(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_结束阶段", [life], null])
	
	if 回合系统.turn != 0:
		control[life].主要阶段发动的信号.disconnect(_主要阶段发动)
		control[life].主要阶段打出的信号.disconnect(_主要阶段打出)
	
	await buff系统.结束阶段结算buff(life)
	
	var cards:Array[战斗_单位管理系统.Card_sys] = control[life].结束阶段弃牌()
	for card:战斗_单位管理系统.Card_sys in cards:
		await 最终行动系统.加入(life, card, life.cards_pos["绿区"])
	
	_恢复绿区(life)
	释放与源.释放卡牌()
	
	emit_signal("下一阶段")

func _恢复绿区(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_恢复绿区", [life], null])
	
	var cards:Array[战斗_单位管理系统.Card_sys] = life.cards_pos["绿区"].cards
	var 表侧的卡:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(cards)
	for card:战斗_单位管理系统.Card_sys in cards:
		if !card in 表侧的卡:
			await 最终行动系统.反转(life, card)



func _发动询问(life:战斗_单位管理系统.Life_sys) -> bool:
	var cards:Array[战斗_单位管理系统.Card_sys]
	var card:战斗_单位管理系统.Card_sys
	if 回合系统.period == "主要" and 回合系统.current_life == life:
		cards = 发动判断系统.单位主要阶段发动判断(life)
	else :
		cards = 发动判断系统.单位非主要阶段发动判断(life)
	
	card = await control[life].发动(cards)
	
	if !card:
		
		event_bus.push_event("战斗_日志记录", [name, "_发动询问", [life], false])
		return false
	
	卡牌打出与发动系统.发动(life, card)
	if 连锁系统.chain_state:
		await 连锁系统.连锁处理结束
	
	event_bus.push_event("战斗_日志记录", [name, "_发动询问", [life], true])
	return true


func _处理卡牌消耗(card:战斗_单位管理系统.Card_sys, cost_mode:String) -> int:
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	var ret:int = 0
	if cost_mode == "直接":
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
					释放与源.添加释放卡牌(life, i)
					mp -= 1
					ret += 1
			else :
				for i:int in mp:
					释放与源.添加释放卡牌(life, cards[i])
					ret += 1
			
			#其他
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["蓝区"].cards:
				if i.get_value("卡名") != "源":
					cards.append(i)
			
			cards.shuffle()
			if mp >= len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					释放与源.添加释放卡牌(life, i)
					ret += 1
			else :
				for i:int in mp:
					释放与源.添加释放卡牌(life, cards[i])
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
					释放与源.添加释放卡牌(life, i)
					mp -= 1
					ret += 1
			else :
				for i:int in mp:
					释放与源.添加释放卡牌(life, cards[i])
					ret += 1
			
			#其他
			for i:战斗_单位管理系统.Card_sys in life.cards_pos["蓝区"].cards:
				if i.get_value("卡名") != "源":
					cards.append(i)
			
			cards.shuffle()
			if mp >= len(cards):
				for i:战斗_单位管理系统.Card_sys in cards:
					释放与源.添加释放卡牌(life, i)
					ret += 1
			else :
				for i:int in mp:
					释放与源.添加释放卡牌(life, cards[i])
					ret += 1
	
	event_bus.push_event("战斗_日志记录", [name, "_处理卡牌消耗", [card, cost_mode], ret])
	return ret








var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func _绑定信号() -> void:
	下一阶段.connect(_下一阶段的信号)
	event_bus.subscribe("战斗_回合进入开始阶段", _开始阶段)
	event_bus.subscribe("战斗_回合进入战斗阶段", _战斗阶段)
	event_bus.subscribe("战斗_回合进入抽牌阶段", _抽牌阶段)
	event_bus.subscribe("战斗_回合进入行动阶段", _行动阶段)
	event_bus.subscribe("战斗_回合进入主要阶段", _主要阶段)
	event_bus.subscribe("战斗_回合进入结束阶段", _结束阶段)
	
	event_bus.subscribe("战斗_请求选择", _战斗_请求选择的信号)
	event_bus.subscribe("战斗_请求选择一格", _战斗_请求选择一格的信号)
	event_bus.subscribe("战斗_选择效果并发动", _战斗_选择效果并发动的信号)
	event_bus.subscribe("战斗_请求选择单位", _战斗_请求选择单位的信号)
	event_bus.subscribe("战斗_请求检查行动冲突", _战斗_请求检查行动冲突的信号)
	event_bus.subscribe("战斗_请求检查图形化数据的改变", _战斗_请求检查图形化数据的改变的信号)


func _战斗_请求选择的信号(life:战斗_单位管理系统.Life_sys, arr:Array, 描述:String = "无", count_max:int = 1, count_min:int = 1) -> void:
	var ret:Array = await control[life].对象选择(arr, 描述, count_max, count_min)
	
	event_bus.push_event("战斗_日志记录", [name, "_战斗_请求选择的信号", [life, arr, 描述, count_max, count_min], ret])
	event_bus.push_event("战斗_请求选择返回", [ret])

func _战斗_请求选择一格的信号(life:战斗_单位管理系统.Life_sys, arr:Array, condition:Array) -> void:
	arr = 卡牌打出与发动系统.get_可用的格子(arr, condition)
	var ret:战斗_单位管理系统.Card_pos_sys = await control[life].选择一格(arr)
	
	event_bus.push_event("战斗_日志记录", [name, "_战斗_请求选择一格的信号", [life, arr], ret])
	event_bus.push_event("战斗_请求选择一格返回", [ret])

func _战斗_请求选择单位的信号(life:战斗_单位管理系统.Life_sys, mp:int) -> void:
	var arr:Array[战斗_单位管理系统.Life_sys]
	if 单位管理系统.lifes.has(life):
		for i:战斗_单位管理系统.Life_sys in 单位管理系统.efils:
			if mp >= 6 - len(卡牌打出与发动系统.get_可用的格子(i.cards_pos["场上"], ["卡牌"])):
				arr.append(i)
		
	else :
		for i:战斗_单位管理系统.Life_sys in 单位管理系统.lifes:
			if mp >= 6 - len(卡牌打出与发动系统.get_可用的格子(i.cards_pos["场上"], ["卡牌"])):
				arr.append(i)
	
	var ret:战斗_单位管理系统.Life_sys = await control[life].选择单位(arr)
	
	event_bus.push_event("战斗_日志记录", [name, "_战斗_请求选择单位的信号", [life, mp], ret])
	event_bus.push_event("战斗_请求选择单位返回", [ret])

func _战斗_选择效果并发动的信号(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, arr_int:Array[int], cost_mode:String) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_战斗_选择效果并发动的信号", [card, arr_int, cost_mode], null])
	
	var effect_int:int = -1
	if arr_int != []:
		effect_int = control[life].选择效果发动(card, arr_int)
	if effect_int != -1 and 连锁系统.add_chain(card.effects[effect_int]):
		连锁系统.set_now_speed(card.effects[effect_int], _处理卡牌消耗(card, cost_mode))
		life.add_history("发动", 回合系统.turn, 回合系统.period, card)
		card.add_history("发动", 回合系统.turn, 回合系统.period)
		#buff判断
		await buff系统.单位与全部buff判断("发动", [null, life, card])
		await 请求进行下一连锁()
	#没有发动效果
	else :
		if cost_mode == "启动":
			await _处理卡牌消耗(card, cost_mode)
		if 连锁系统.chain_state == 1:
			await 连锁系统.start()
		await 卡牌打出与发动系统.自动下降()
	event_bus.push_event("战斗_选择效果并发动返回")

func 请求进行下一连锁() -> void:
	event_bus.push_event("战斗_日志记录", [name, "请求进行下一连锁", [], null])
	
	var life:战斗_单位管理系统.Life_sys = 连锁系统.current_life
	var arr_life:Array[战斗_单位管理系统.Life_sys]
	
	if 单位管理系统.lifes.has(life):
		arr_life = 单位管理系统.efils
	else :
		arr_life = 单位管理系统.lifes
	#敌对对象
	for i:战斗_单位管理系统.Life_sys in 连锁系统.frist_lifes:
		if arr_life.has(i):
			if await _发动询问(i):
				return
	#友方
	for i:战斗_单位管理系统.Life_sys in 连锁系统.frist_lifes:
		if !arr_life.has(i):
			if await _发动询问(i):
				return
	#攻击目标
	if life.att_life:
		if await _发动询问(life.att_life):
			return
	#全部
	for i:战斗_单位管理系统.Life_sys in arr_life:
		if await _发动询问(i):
			return
	if arr_life == 单位管理系统.efils:
		for i:战斗_单位管理系统.Life_sys in 单位管理系统.lifes:
			if await _发动询问(i):
				return
	else :
		for i:战斗_单位管理系统.Life_sys in 单位管理系统.efils:
			if await _发动询问(i):
				return
	
	await 连锁系统.start()

func _战斗_请求检查行动冲突的信号(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_战斗_请求检查行动冲突的信号", [life], null])
	
	for card:战斗_单位管理系统.Card_sys in life.cards_pos["行动"]:
		if !card.get_value("种类") in life.state:
			最终行动系统.加入(life, card, life.cards_pos["绿区"])

var 正在处理_战斗_请求检查图形化数据的改变的信号:bool = false
func _战斗_请求检查图形化数据的改变的信号() -> void:
	if 正在处理_战斗_请求检查图形化数据的改变的信号:
		return
	
	正在处理_战斗_请求检查图形化数据的改变的信号 = true
	event_bus.push_event("战斗_日志记录", [name, "_战斗_请求检查行动冲突的信号", [], null])
	
	for life in 单位管理系统.lifes + 单位管理系统.efils:
		var cards := 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards())
		for card in cards:
			for i:String in ["种类", "卡名", "sp", "mp"]:
				var data = card.get_value(i)
				if card.图形化数据[i] != data:
					card.图形化数据[i] =data
					最终行动系统.图形化数据改变(card)
	
	正在处理_战斗_请求检查图形化数据的改变的信号 = false
