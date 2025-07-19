extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var buff系统: Node = %buff系统
@onready var 回合系统: Node = %回合系统
@onready var 卡牌打出与发动系统: Node = %卡牌打出与发动系统
@onready var 连锁系统: Node = %连锁系统


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func 单位主要阶段发动判断(life:战斗_单位管理系统.Life_sys) -> Array[战斗_单位管理系统.Card_sys]:
	var speed:int = 连锁系统.now_speed
	var ret可发动的卡牌:Array[战斗_单位管理系统.Card_sys] = []
	#发动
	var cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards(), 3)
	for card:战斗_单位管理系统.Card_sys in cards:
		if await 卡牌发动与消耗判断(card, speed):
			if !ret可发动的卡牌.has(card):
				ret可发动的卡牌.append(card)

	

	
	event_bus.push_event("战斗_日志记录", [name, "单位主要阶段发动判断", [life, speed], ret可发动的卡牌])
	return ret可发动的卡牌


func 单位主要阶段打出判断(life:战斗_单位管理系统.Life_sys) -> Array[战斗_单位管理系统.Card_sys]:
	var speed:int = 连锁系统.now_speed
	var ret可打出的卡牌:Array[战斗_单位管理系统.Card_sys] = []
	#打出
	for card:战斗_单位管理系统.Card_sys in life.cards_pos["手牌"].cards:
		if _打出消耗判断(life, card):
			if card.data["种类"] in ["仪式"]:
				if !卡牌打出与发动系统.get_可用的格子(life.cards_pos["场上"], ["纵向"]):
					continue
				if !ret可打出的卡牌.has(card):
					ret可打出的卡牌.append(card)
			elif card.data["种类"] in ["法术"]:
				if !卡牌打出与发动系统.get_可用的格子(life.cards_pos["场上"], ["卡牌"]):
					continue
				var pos = "场上"
				if await 卡牌发动判断(life, card, pos, speed):
					if !ret可打出的卡牌.has(card):
						ret可打出的卡牌.append(card)

	
	event_bus.push_event("战斗_日志记录", [name, "单位主要阶段打出判断", [life, speed], ret可打出的卡牌])
	return ret可打出的卡牌


func 单位非主要阶段发动判断(life:战斗_单位管理系统.Life_sys) -> Array[战斗_单位管理系统.Card_sys]:
	var speed:int = 连锁系统.now_speed
	var ret可发动的卡牌:Array[战斗_单位管理系统.Card_sys] = []
	#发动
	var cards:Array[战斗_单位管理系统.Card_sys]
	if life.state.has("防御"):
		cards = 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards(), 3)
	else :
		cards = 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards(), 4)
	for card:战斗_单位管理系统.Card_sys in cards:
		if await 卡牌发动与消耗判断(card, speed):
			if !ret可发动的卡牌.has(card):
				ret可发动的卡牌.append(card)
	
	
	event_bus.push_event("战斗_日志记录", [name, "单位非主要阶段发动判断", [life, speed], ret可发动的卡牌])
	return ret可发动的卡牌


func 单位行动阶段打出判断(life:战斗_单位管理系统.Life_sys) -> Array[战斗_单位管理系统.Card_sys]:
	var ret可打出的卡牌:Array[战斗_单位管理系统.Card_sys] = []
	
	#打出
	var mp:int 
	if life.att_life:
		mp = 单位管理系统.get_life场上第一张是纵向的格子数量(life.att_life)
	else :
		mp = 单位管理系统.get_life场上第一张是纵向的格子数量(life.face_life)
	for card:战斗_单位管理系统.Card_sys in life.cards_pos["手牌"].cards:
		if card.get_value("mp") >= mp:
			var 种类:String = card.get_value("种类")
			var state:Array[String] = await life.get_value("state")
			if 种类 in ["攻击", "防御"] and (state == [] or state.has(种类)):
				if _打出消耗判断(life, card):
					if !ret可打出的卡牌.has(card):
						ret可打出的卡牌.append(card)
	
	
	event_bus.push_event("战斗_日志记录", [name, "单位行动阶段打出判断", [life], ret可打出的卡牌])
	return ret可打出的卡牌


##不在场上
func 卡牌发动与消耗判断(card:战斗_单位管理系统.Card_sys, speed:int) -> bool:
	var pos:String = card.get_parent().nam
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	if await _发动消耗判断(life, card):
		if await 卡牌发动判断(life, card, card.get_parent().nam, speed):
			
			event_bus.push_event("战斗_日志记录", [name, "卡牌发动与消耗判断", [card, speed], true])
			return true
	
	event_bus.push_event("战斗_日志记录", [name, "卡牌发动与消耗判断", [card, speed], true])
	return false


##在场上
func 卡牌发动判断(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:String, speed:int) -> Array:
	
	if !card.appear:
		
		event_bus.push_event("战斗_日志记录", [name, "卡牌发动判断", [card, speed], []])
		return []
	
	
	
	
	var ret可发动的效果:Array = []
	
	for effect:战斗_单位管理系统.Effect_sys in card.effects:
		if await 卡牌发动判断_单个效果(life, card, pos, effect, speed):
			ret可发动的效果.append(effect)
	
	event_bus.push_event("战斗_日志记录", [name, "卡牌发动判断", [card, speed], ret可发动的效果])
	return ret可发动的效果



func _发动消耗判断(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	var i:int = buff系统.单位与全部buff判断("打出消耗判断", [null, life, card])
	if i == -1:
		
		if card.data["种类"] in ["攻击", "防御"]:
			if int(card.data["mp"]) <= len(life.cards_pos["蓝区"].cards):
				
				event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], true])
				return true
			else:
				
				event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], false])
				return false
		if card.data["种类"] in ["法术", "仪式"]:
			if int(card.data["sp"]) <= len(单位管理系统.get_给定显示以上的卡牌(life.cards_pos["绿区"].cards)):
				
				event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], true])
				return true
			else:
				
				event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], false])
				return false
	elif i == 1:
		
		event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], true])
		return true
	
	event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], false])
	return false



func _打出消耗判断(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	var i:int = buff系统.单位与全部buff判断("打出消耗判断", [null, life, card])
	if i == -1:
		
		if card.data["种类"] in ["攻击", "防御"]:
			if int(card.data["sp"]) <= len(单位管理系统.get_给定显示以上的卡牌(life.cards_pos["绿区"].cards)):
				
				event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], true])
				return true
			else:
				
				event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], false])
				return false
		if card.data["种类"] in ["法术", "仪式"]:
			if int(card.data["mp"]) <= len(life.cards_pos["蓝区"].cards):
				
				event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], true])
				return true
			else:
				
				event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], false])
				return false
	elif i == 1:
		
		event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], true])
		return true
	
	event_bus.push_event("战斗_日志记录", [name, "_打出消耗判断", [life, card], false])
	return false



func 卡牌发动判断_单个效果(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:String, effect:战斗_单位管理系统.Effect_sys, speed:int) -> bool:
	assert(连锁系统.chain_state != 2, "连锁处理中")
	
	if 卡牌打出与发动系统.自然下降的卡牌.has(card):
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	#次数
	if effect.count <= 0:
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	#触发
	if effect.features.has("触发"):
		if !连锁系统.now_可发动的效果.has(effect):
			
			event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
			return false
		else :
			pass
	
	
	#位置
	if pos != "":
		if !_位置判断(effect, pos):
			
			event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
			return false
	
	
	#状态
	if !_状态判断(effect, await life.get_value("state")):
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	
	#时差
	if !_时差判断(card, speed):
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	
	if !buff系统.单位与全部buff判断("发动判断", [null, life, effect]):
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	
	#cost
	var targets:Array = [card, life]
	if 连锁系统.now_可发动的效果.has(effect):
		targets = 连锁系统.now_可发动的效果[effect]
	targets = await _效果发动判断(effect.cost_effect, effect.get_value("features"), targets)
	if !targets:
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	
	#main
	if ! await _效果发动判断(effect.main_effect, effect.get_value("features"), targets):
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	
	event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], true])
	return true



func _位置判断(effect:战斗_单位管理系统.Effect_sys, pos:String) -> bool:
	if effect.get_value("features").has("任意"):
		
		event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], true])
		return true
	
	if effect.get_value("features").has("场上"):
		if pos in ["场上"]:
			
			event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], true])
			return true
	
	if effect.get_value("features").has("行动"):
		if pos in ["行动"]:
			
			event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], true])
			return true
	
	for i:String in ["手牌", "白区", "绿区", "蓝区", "红区"]:
		if effect.get_value("features").has(i):
			if pos == i:
				
				event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], true])
				return true
				
			event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], false])
			return false
	
	if !pos in ["场上"]:
		
		event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], false])
		return false
	
	event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], true])
	return true



func _状态判断(effect:战斗_单位管理系统.Effect_sys, state:Array[String]) -> bool:
	if effect.get_value("features").has("攻击"):
		if !state.has("攻击"):
			
			event_bus.push_event("战斗_日志记录", [name, "_状态判断", [effect, state], false])
			return false
	
	if effect.get_value("features").has("防御"):
		if !state.has("防御"):
			
			event_bus.push_event("战斗_日志记录", [name, "_状态判断", [effect, state], false])
			return false
	
	event_bus.push_event("战斗_日志记录", [name, "_状态判断", [effect, state], true])
	return true



func _时差判断(card:战斗_单位管理系统.Card_sys, speed:int) -> bool:
	var ret:bool
	if card.get_value("种类") in ["攻击", "防御"]:
		ret = card.get_value("sp") >= speed
	if card.get_value("种类") in ["法术", "仪式"]:
		ret = card.get_value("mp") >= speed
	
	event_bus.push_event("战斗_日志记录", [name, "_时差判断", [card, speed], ret])
	return ret



func _效果发动判断(eff:Array, fea:Array = [], tar:Array = []) -> Array:
	var effect_processing:= 战斗_发动判断系统.new(eff, [单位管理系统.lifes, 单位管理系统.efils], fea, tar)
	var ret:Array = await effect_processing.start()
	
	event_bus.push_event("战斗_日志记录", [name, "_效果发动判断", [eff, fea, tar], ret])
	return ret
