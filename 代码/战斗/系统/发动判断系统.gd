extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var buff系统: Node = $"../../单位管理系统/buff系统"
@onready var 回合系统: Node = %回合系统
@onready var 卡牌打出与发动系统: Node = $"../../单位管理系统/卡牌打出与发动系统"

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func 单位主要阶段发动判断(life:战斗_单位管理系统.Life_sys, speed:int) -> Array[战斗_单位管理系统.Card_sys]:
	var ret可发动的卡牌:Array = []
	#发动
	var cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards(), 3)
	for card:战斗_单位管理系统.Card_sys in cards:
		if 卡牌发动与消耗判断(card, speed):
			ret可发动的卡牌.append(card)

	

	
	event_bus.push_event("战斗_日志记录", [name, "单位发动判断", [life, speed], ret可发动的卡牌])
	return ret可发动的卡牌


func 单位主要阶段打出判断(life:战斗_单位管理系统.Life_sys, speed:int) -> Array[战斗_单位管理系统.Card_sys]:
	var ret可打出的卡牌:Array = []
	#打出
	for card:战斗_单位管理系统.Card_sys in life.cards_pos["手牌"].cards:
		if _打出消耗判断(life, card):
			if card.data["种类"] in ["仪式"]:
				if !卡牌打出与发动系统.get_可用的格子(life.cards_pos["场上"], ["纵向"]):
					continue
				ret可打出的卡牌.append(card)
			elif card.data["种类"] in ["法术"]:
				if !卡牌打出与发动系统.get_可用的格子(life.cards_pos["场上"], ["纵向"]):
					continue
				var pos = "场上"
				if 卡牌发动判断(card, speed):
					ret可打出的卡牌.append(card)

	
	event_bus.push_event("战斗_日志记录", [name, "单位发动判断", [life, speed], ret可打出的卡牌])
	return ret可打出的卡牌


func 单位非主要阶段发动判断(life:战斗_单位管理系统.Life_sys, speed:int) -> Array[战斗_单位管理系统.Card_sys]:
	var ret可发动的卡牌:Array = []
	#发动
	var cards:Array[战斗_单位管理系统.Card_sys]
	if life.state.has("防御"):
		cards = 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards(), 3)
	else :
		cards = 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards(), 4)
	for card:战斗_单位管理系统.Card_sys in cards:
		if 卡牌发动与消耗判断(card, speed):
			ret可发动的卡牌.append(card)
	
	
	event_bus.push_event("战斗_日志记录", [name, "单位发动判断", [life, speed], ret可发动的卡牌])
	return ret可发动的卡牌


func 单位行动阶段打出判断(life:战斗_单位管理系统.Life_sys) -> Array[战斗_单位管理系统.Card_sys]:
	var ret可打出的卡牌:Array = []
	
	#打出
	var mp:int 
	if life.att_life:
		mp = 单位管理系统.get_life场上第一张是纵向的格子数量(life.att_life)
	else :
		mp = 单位管理系统.get_life场上第一张是纵向的格子数量(life.face_life)
	for card:战斗_单位管理系统.Card_sys in life.cards_pos["手牌"].cards:
		if card.get_value("mp") >= mp:
			var 种类:String = card.get_value("种类")
			var state:Array[String] = life.get_value("state")
			if 种类 in ["攻击", "防御"] and (state == [] or state.has(种类)):
				if _打出消耗判断(life, card):
					ret可打出的卡牌.append(card)
	
	
	event_bus.push_event("战斗_日志记录", [name, "单位发动判断", [life], ret可打出的卡牌])
	return ret可打出的卡牌


##不在场上
func 卡牌发动与消耗判断(card:战斗_单位管理系统.Card_sys, speed:int) -> bool:
	var pos:String = card.get_parent().name
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	if _发动消耗判断(life, card):
		if 卡牌发动判断(card, speed):
			
			event_bus.push_event("战斗_日志记录", [name, "卡牌发动与消耗判断", [card, speed], true])
			return true
	
	event_bus.push_event("战斗_日志记录", [name, "卡牌发动与消耗判断", [card, speed], true])
	return false


##在场上
func 卡牌发动判断(card:战斗_单位管理系统.Card_sys, speed:int) -> Array:
	if !card.is_face_up:
		
		event_bus.push_event("战斗_日志记录", [name, "卡牌发动判断", [card, speed], []])
		return []
	
	
	var pos = card.get_parent().name
	
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	
	var ret可发动的效果:Array = []
	
	for effect:战斗_单位管理系统.Effect_sys in card.effects:
		if 卡牌发动判断_单个效果(life, card, pos, effect, speed):
			ret可发动的效果.append(ret可发动的效果)
	
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
			if int(card.data["sp"]) <= len(单位管理系统.get_表侧表示的卡牌(life.cards_pos["绿区"].cards)):
				
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
	var i:int = buff系统.卡牌与所有单位buff判断(card , "打出消耗判断", [null, life, card])
	if i == -1:
		
		if card.data["种类"] in ["攻击", "防御"]:
			if int(card.data["sp"]) <= len(单位管理系统.get_表侧表示的卡牌(life.cards_pos["绿区"].cards)):
				
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
	#位置
	if pos != "":
		if !_位置判断(effect, pos):
			
			event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
			return false
	
	
	#状态
	if !_状态判断(effect, life.get_value("state")):
		
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
	var targets:Array = _效果发动判断(effect.cost_effect, effect.get_value("features"), [card, life])
	if !targets:
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	
	#main
	if !_效果发动判断(effect.main_effect, effect.get_value("features"), targets):
		
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
	var ret:Array = effect_processing.start()
	
	event_bus.push_event("战斗_日志记录", [name, "_效果发动判断", [eff, fea, tar], ret])
	return ret
