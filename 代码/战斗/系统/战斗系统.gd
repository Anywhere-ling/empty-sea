extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 回合系统: Node = %回合系统
@onready var 最终行动系统: Node = %最终行动系统
@onready var 释放与源: Node = %释放与源
@onready var 卡牌打出与发动系统: Node = %卡牌打出与发动系统
@onready var 连锁系统: Node = %连锁系统
@onready var 发动判断系统: Node = %发动判断系统
@onready var buff系统: Node = %buff系统
@onready var 单位控制系统: Node = %单位控制系统
@onready var 日志系统: 战斗_日志系统 = %日志系统
@onready var 场地系统: Node = %场地系统
@onready var 效果系统: Node = %效果系统
@onready var 二级行动系统: Node = %二级行动系统

signal 下一阶段



var 没有第一次抽牌的单位:Array[战斗_单位管理系统.Life_sys]





func _ready() -> void:
	_绑定信号()
	
	场地系统.start()
	最终行动系统.临时pos = 战斗_单位管理系统.Card_pos_sys.new("临时")



func add_life(life, is_positive:bool) -> void:
	日志系统.callv("录入信息", [name, "add_life", [life, is_positive], null])
	
	
	#绑定控制
	var 控制:战斗_单位控制
	if life is String:
		控制 = 战斗_单位控制_nocard.new(life)
	if life is 战斗_单位控制:
		控制 = life
	
	控制.is_positive = is_positive
	
	
	life = await 最终行动系统.加入战斗(控制, is_positive)
	单位控制系统.control[life] = 控制
	
	#加入回合
	回合系统.join_life(life)
	没有第一次抽牌的单位.append(life)
	单位控制系统.control[life].合成的信号.connect(_合成)
	#创造牌库
	await 最终行动系统.创造牌库(life)


func start() -> void:
	日志系统.callv("录入信息", [name, "start", [], null])
	
	await 最终行动系统.开始()
	回合系统.start()


func _下一阶段的信号(state:String = "") -> void:
	await 卡牌打出与发动系统.行动组结束()
	assert(连锁系统.chain_state == 0,"连锁未处理")
	
	
	日志系统.callv("录入信息", [name, "_下一阶段的信号", [state], null])
	
	回合系统.call_deferred("swicth_state", state)




func _战斗阶段(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_战斗阶段", [life], null])
	if 没有第一次抽牌的单位.has(life):
		emit_signal("下一阶段")
		return
	
	life.att_mode = []
	if !life.get_value("state").has("阻止"):
		for card:战斗_单位管理系统.Card_sys in life.cards_pos["行动"].cards:
			if await card.get_value("种类") == "攻击":
				await 卡牌打出与发动系统.发动场上的效果(life, card, "攻击前")
				
				if life.get_value("state").has("阻止"):
					await buff系统.单位与全部buff判断("阻止", [null, life, null])
					await 最终行动系统.阻止(life)
					emit_signal("下一阶段")
					return
				
				if card.get_parent().nam == "行动" and card.get_所属life() == life:
					if life.get_value("state").has("攻击"):
						await _攻击判断(life, card)
			卡牌打出与发动系统.add_自动下降(card, "打出", life)
	
	else:
		await buff系统.单位与全部buff判断("阻止", [null, life, null])
		await 最终行动系统.阻止(life)
	
	emit_signal("下一阶段")

func _攻击判断(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> void:
	日志系统.callv("录入信息", [name, "_攻击判断", [life, card], null])
	
	var mode:String
	var att_life:战斗_单位管理系统.Life_sys = life.att_life
	var def_cards:Array[战斗_单位管理系统.Card_sys]
	var att_sp:int = await card.get_value("sp")
	var att_mp:int = await card.get_value("mp")
	var def_sp:int = 0
	var def_mp:int = 0
	for i:战斗_单位管理系统.Card_sys in att_life.cards_pos["行动"].cards:
		if await i.get_value("种类") == "防御":
			def_cards.append(i)
			def_sp += await i.get_value("sp")
			def_mp += await i.get_value("mp")
	
	#判断
	if !def_cards:
		mode = "直接攻击"
	elif def_sp/def_cards.size() > att_mp and att_sp > def_mp/def_cards.size():
		mode = "重击"
	elif def_sp/def_cards.size() > att_mp and att_sp > def_mp/def_cards.size():
		mode = "刺击"
	elif def_sp/def_cards.size() == att_mp and att_sp == def_mp/def_cards.size():
		mode = "格挡"
	else:
		mode = "斩击"
	
	if mode == "格挡":
		if !att_life.att_mode.has(mode):
			att_life.att_mode.append(mode)
	else:
		if !life.att_mode.has(mode):
			life.att_mode.append(mode)
	
	#处理
	await 最终行动系统.攻击(life, card, mode)
	if mode == "直接攻击":
		for i:int in att_sp:
			if len(att_life.cards_pos["白区"].cards) >= 1:
				var card1:战斗_单位管理系统.Card_sys = att_life.cards_pos["白区"].cards[0]
				await 二级行动系统.加入(att_life, card1, att_life.cards_pos["红区"])
			elif len(att_life.cards_pos["手牌"].cards) >= 1:
				var card1:战斗_单位管理系统.Card_sys = att_life.cards_pos["手牌"].cards[0]
				await 二级行动系统.加入(att_life, card1, att_life.cards_pos["红区"])
			else :
				await buff系统.单位与全部buff判断("被攻击", [null, att_life, card])
				await 最终行动系统.死亡(att_life)
				return
		
		#反转
		var cards:Array = att_life.cards_pos["红区"].cards
		cards = cards.duplicate(true)
		cards.shuffle()
		var count:int = len(cards)/2
		count = len(cards) - count
		for i in count:
			if !cards[i].appear:
				await 最终行动系统.反转(att_life, cards[i])
	
	await buff系统.单位与全部buff判断("被攻击", [null, att_life, card])
	#冲击
	var state:Array = att_life.get_value("state")
	if !state.has("受袭") and !state.has("冲击") and !state.has("恢复"):
		att_life.信息state.append("受袭")
		



func _抽牌阶段(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_抽牌阶段", [life], null])
	
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
	日志系统.callv("录入信息", [name, "_第一次抽牌", [life], null])
	
	var hand_cadrs:int = 0
	var speed:int = await life.get_value("speed")
	while hand_cadrs < max(speed, 1):
		if life.cards_pos["白区"].cards == []:
			return
		var card:战斗_单位管理系统.Card_sys = life.cards_pos["白区"].cards[0]
		await 最终行动系统.反转(life, card)
		if await card.get_value("种类") in ["攻击", "防御"]:
			await 二级行动系统.加入(life, card, life.cards_pos["手牌"])
			hand_cadrs += 1
		else :
			await 二级行动系统.加入(life, card, life.cards_pos["蓝区"])

func _第一次弃牌(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_第一次弃牌", [life], null])
	
	var cards:Array = await 单位控制系统.control[life].第一次弃牌()
	for card:战斗_单位管理系统.Card_sys in cards:
		await 二级行动系统.加入(life, card, life.cards_pos["绿区"])
		await 最终行动系统.抽牌(life)

func _整理手牌(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_整理手牌", [life], null])
	
	var cards:Array = await 单位控制系统.control[life].整理手牌()
	if cards:
		life.cards_pos["手牌"].cards.sort_custom(func(a,b):return cards.find(a) < cards.find(b))

	最终行动系统.整理手牌(life)


func _确认face_life(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_确认face_life", [life], null])
	
	await 单位控制系统.control[life].确认目标(单位管理系统.lifes, 单位管理系统.efils)


func _开始阶段(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_开始阶段", [life], null])
	
	for card:战斗_单位管理系统.Card_sys in life.get_all_cards():
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.count <= 0:
				effect.count += 1
	
	
	await 释放与源.添加源(life)
	await _恢复绿区(life)
	await 卡牌打出与发动系统.自动下降(life)
	await _去掉源(life)
	
	await buff系统.开始阶段结算buff(life)
	emit_signal("下一阶段")


func _行动阶段(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_行动阶段", [life], null])
	var card:战斗_单位管理系统.Card_sys
	if life.cards_pos["行动"].cards:
		card = life.cards_pos["行动"].cards[0]
		_行动阶段移动(life, [card.get_value("种类")])
	else:
		var cards:Array[战斗_单位管理系统.Card_sys] = await 发动判断系统.单位行动阶段打出判断(life)
		card = await 单位控制系统.control[life].打出(cards)
		if card:
			if await 卡牌打出与发动系统.打出(life, card):
				
				await 卡牌打出与发动系统.行动组结束()
				
				await _行动阶段移动(life, [card.get_value("种类")])
	
	#冲击
	var state:Array = life.get_value("state")
	if state.has("受袭"):
		life.信息state.erase("受袭")
		life.信息state.append("冲击")
	if state.has("冲击"):
		life.信息state.erase("冲击")
		life.信息state.append("恢复")
	if state.has("恢复"):
		life.信息state.erase("恢复")
	
	emit_signal("下一阶段")

func _行动阶段移动(life:战斗_单位管理系统.Life_sys, state:Array) -> bool:
	var 方向:Array
	if state.has("攻击"):
		方向.append(0)
	if state.has("防御"):
		方向.append(90)
		方向.append(180)
		方向.append(270)
	
	var dic:Dictionary = await 效果系统.可用移动(life, 方向, 1, 1)[0]
	if !dic:
		return false
	
	while true:
		var arr_card:Array = await 单位控制系统.请求选择(life, "要让谁移动呢", dic.keys(), 1, 0)
		if !arr_card:
			return false
		var card:战斗_单位管理系统.Card_sys = arr_card[0]
		var arr_pos:Array = dic[card]
		
		var pos:战斗_单位管理系统.Card_pos_sys = await 单位控制系统.请求选择一格(life, arr_pos)
		if !pos:
			continue
		await 二级行动系统.加入(life, card, pos)
		return true
	
	return true


func _主要阶段(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_主要阶段", [life], null])
	
	_主要阶段判断(life)
	单位控制系统.control[life].主要阶段发动的信号.connect(_主要阶段发动)
	单位控制系统.control[life].主要阶段打出的信号.connect(_主要阶段打出)
	单位控制系统.control[life].结束.connect(func():emit_signal("下一阶段"), 4)
	单位控制系统.control[life].主要阶段()

func _主要阶段打出(card:战斗_单位管理系统.Card_sys) -> void:
	日志系统.callv("录入信息", [name, "_主要阶段打出", [card], null])
	
	var life:战斗_单位管理系统.Life_sys = 回合系统.current_life
	await 卡牌打出与发动系统.打出(life, card)
	
	if 连锁系统.chain_state:
		await 连锁系统.连锁处理结束
	_主要阶段判断(life)

func _主要阶段发动(card:战斗_单位管理系统.Card_sys) -> void:
	日志系统.callv("录入信息", [name, "_主要阶段发动", [card], null])
	
	var life:战斗_单位管理系统.Life_sys = 回合系统.current_life
	await 卡牌打出与发动系统.发动(life, card)
	
	if 连锁系统.chain_state:
		await 连锁系统.连锁处理结束
	_主要阶段判断(life)

func _主要阶段判断(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_主要阶段判断", [life], null])
	
	var 发动cards:Array[战斗_单位管理系统.Card_sys] = await 发动判断系统.单位主要阶段发动判断(life)
	var 打出cards:Array[战斗_单位管理系统.Card_sys] = await 发动判断系统.单位主要阶段打出判断(life)
	
	var 合成cards:Dictionary
	if 连锁系统.chain_state == 0:
		var 蓝区cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.cards_pos["蓝区"].cards, 3)
		var 场上cards:Array[战斗_单位管理系统.Card_sys]
		for pos in life.cards_pos["场上"]:
			if pos.cards:
				场上cards.append(pos.cards[0])
		场上cards = 单位管理系统.get_给定显示以上的卡牌(场上cards, 2)
		var 手牌cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.cards_pos["手牌"].cards, 3)
		合成cards = 发动判断系统.合成构造判断(life, 蓝区cards+手牌cards, 蓝区cards+场上cards, 蓝区cards+场上cards)
		
	单位控制系统.control[life].主要阶段判断(发动cards, 打出cards, 合成cards)




func _合成(cards:Array) -> void:
	await 卡牌打出与发动系统.合成(cards)
	
	if 回合系统.period == "主要" and 连锁系统.chain_state == 0:
		await 卡牌打出与发动系统.行动组结束()
		_主要阶段判断(回合系统.current_life)


func _结束阶段(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_结束阶段", [life], null])
	
	if 回合系统.turn != 0:
		单位控制系统.control[life].主要阶段发动的信号.disconnect(_主要阶段发动)
		单位控制系统.control[life].主要阶段打出的信号.disconnect(_主要阶段打出)
	
	await buff系统.结束阶段结算buff(life)
	
	if len(life.cards_pos["手牌"].cards) > await life.get_value("speed"):
		var cards:Array[战斗_单位管理系统.Card_sys] = await 单位控制系统.control[life].结束阶段弃牌()
		for card:战斗_单位管理系统.Card_sys in cards:
			await 二级行动系统.加入(life, card, life.cards_pos["绿区"])
	
	_恢复红区(life)
	
	await 卡牌打出与发动系统.行动组结束()
	释放与源.释放卡牌()
	
	emit_signal("下一阶段")



func _恢复绿区(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_恢复绿区", [life], null])
	
	var 红区盖卡数量:int = len(life.cards_pos["红区"].cards) - len(单位管理系统.get_给定显示以上的卡牌(life.cards_pos["红区"].cards, 1))
	var 绿区盖卡数量:int = len(life.cards_pos["绿区"].cards) - len(单位管理系统.get_给定显示以上的卡牌(life.cards_pos["绿区"].cards, 1))
	var 蓝区盖卡差数量:int = len(life.cards_pos["蓝区"].cards) - 2*len(单位管理系统.get_给定显示以上的卡牌(life.cards_pos["蓝区"].cards, 1))
	
	var 可恢复上限:int = 绿区盖卡数量 - 红区盖卡数量
	var 可恢复:int = min(可恢复上限, 蓝区盖卡差数量)
	
	var cards:Array[战斗_单位管理系统.Card_sys] = life.cards_pos["绿区"].cards
	if 可恢复 >= 0:
		for card:战斗_单位管理系统.Card_sys in cards:
			if 可恢复 >= 0:
				if !card.appear:
					await 最终行动系统.反转(life, card)
					可恢复 -= 1
	
	#固定回1
	for card:战斗_单位管理系统.Card_sys in cards:
			if !card.appear:
				await 最终行动系统.反转(life, card)
				return

func _恢复红区(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "_恢复红区", [life], null])
	
	var cards:Array[战斗_单位管理系统.Card_sys] = life.cards_pos["绿区"].cards
	cards = cards.duplicate(true)
	cards.shuffle()
	
	for card:战斗_单位管理系统.Card_sys in cards:
		if card.appear:
			await 最终行动系统.反转(life, card)
			return

func _去掉源(life:战斗_单位管理系统.Life_sys) -> void:
	var cards:Array = 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards(), 4)
	for i:战斗_单位管理系统.Card_sys in cards:
		var cards1:Array = i.get_源(false)
		if !cards1:
			cards1 = i.get_源(true)
			if !cards1:
				return
			
		await 二级行动系统.去除(life, i, cards1[0], "蓝区")






var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func _绑定信号() -> void:
	下一阶段.connect(_下一阶段的信号)
	event_bus.subscribe("战斗_回合进入开始阶段", _开始阶段)
	event_bus.subscribe("战斗_回合进入战斗阶段", _战斗阶段)
	event_bus.subscribe("战斗_回合进入抽牌阶段", _抽牌阶段)
	event_bus.subscribe("战斗_回合进入行动阶段", _行动阶段)
	event_bus.subscribe("战斗_回合进入主要阶段", _主要阶段)
	event_bus.subscribe("战斗_回合进入结束阶段", _结束阶段)
	
	
