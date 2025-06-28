extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var buff系统: Node = $"../../单位管理系统/buff系统"

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func 单位发动判断(life:战斗_单位管理系统.Life_sys) -> Array:
	var ret可发动的卡牌:Array = []
	var ret可打出的卡牌:Array = []
	#发动
	for pos:String in life.cards_pos:
		if pos != "场上":
			for card:战斗_单位管理系统.Card_sys in life.cards_pos[pos].cards:
				if 卡牌发动与消耗判断(card):
					ret可发动的卡牌.append(card)
		else :
			for card_pos:战斗_单位管理系统.Card_pos_sys in life.cards_pos[pos].cards:
				var card:战斗_单位管理系统.Card_sys = card_pos.cards[0]
				if 卡牌发动与消耗判断(card):
					ret可发动的卡牌.append(card)

	
	#打出
	for card:战斗_单位管理系统.Card_sys in life.cards_pos["手牌"].cards:
		if _打出消耗判断(life, card):
			var pos:String
			if card.data["种类"] in ["攻击", "防御"]:
				pos = "行动"
			elif card.data["种类"] in ["法术", "仪式"]:
				pos = "场上"
			assert(pos, "未识别的种类")
			if 卡牌发动判断(card, pos):
				ret可打出的卡牌.append(card)

	
	event_bus.push_event("战斗_日志记录", [name, "单位发动判断", [life], [ret可发动的卡牌, ret可打出的卡牌]])
	return [ret可发动的卡牌, ret可打出的卡牌]


##不在场上
func 卡牌发动与消耗判断(card:战斗_单位管理系统.Card_sys) -> bool:
	var pos:String = card.get_parent().name
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	if _发动消耗判断(life, card):
		if 卡牌发动判断(card):
			
			event_bus.push_event("战斗_日志记录", [name, "卡牌发动与消耗判断", [card], true])
			return true
	
	event_bus.push_event("战斗_日志记录", [name, "卡牌发动与消耗判断", [card], true])
	return false


##在场上
func 卡牌发动判断(card:战斗_单位管理系统.Card_sys, pos:String = "") -> Array:
	if !card.is_face_up:
		
		event_bus.push_event("战斗_日志记录", [name, "卡牌发动判断", [card, pos], []])
		return []
	
	if pos == "":
		pos = card.get_parent().name
	
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	
	var ret可发动的效果:Array = []
	
	for effect:战斗_单位管理系统.Effect_sys in card.effects:
		if _卡牌发动判断_单个效果(life, card, pos, effect):
			ret可发动的效果.append(ret可发动的效果)
	
	event_bus.push_event("战斗_日志记录", [name, "卡牌发动判断", [card, pos], ret可发动的效果])
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



func _卡牌发动判断_单个效果(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:String, effect:战斗_单位管理系统.Effect_sys) -> bool:
	#位置
	if !_位置判断(effect, pos):
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect], false])
		return false
	#记录
	
	
	if !buff系统.单位与全部buff判断("发动判断", [null, life, effect]):
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect], false])
		return false
	
	
	#cost
	if !_效果发动判断(effect.cost_effect, effect.features, [card, life]):
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect], false])
		return false
	
	
	#main
	if !_效果发动判断(effect.main_effect, effect.features, [card, life]):
		
		event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect], false])
		return false
	
	
	event_bus.push_event("战斗_日志记录", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect], true])
	return true



func _位置判断(effect:战斗_单位管理系统.Effect_sys, pos:String) -> bool:
	if effect.features.has("任意"):
		
		event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], true])
		return true
	
	if effect.features.has("场上"):
		if pos in ["场上"]:
			
			event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], true])
			return true
	
	if effect.features.has("行动"):
		if pos in ["行动"]:
			
			event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], true])
			return true
	
	for i:String in ["手牌", "白区", "绿区", "蓝区", "红区"]:
		if effect.features.has(i):
			if pos == i:
				
				event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], true])
				return true
				
			event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], false])
			return false
	
	event_bus.push_event("战斗_日志记录", [name, "_位置判断", [effect, pos], true])
	return true



func _效果发动判断(eff:Array, fea:Array = [], tar:Array = []) -> bool:
	var effect_processing:= 战斗_发动判断系统.new(eff, [单位管理系统.lifes, 单位管理系统.efils], fea, tar)
	var ret:bool = effect_processing.start()
	
	event_bus.push_event("战斗_日志记录", [name, "_效果发动判断", [eff, fea, tar], ret])
	return ret
