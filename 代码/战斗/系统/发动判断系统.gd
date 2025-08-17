extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var buff系统: Node = %buff系统
@onready var 回合系统: Node = %回合系统
@onready var 卡牌打出与发动系统: Node = %卡牌打出与发动系统
@onready var 连锁系统: Node = %连锁系统
@onready var 最终行动系统: Node = %最终行动系统
@onready var 单位控制系统: Node = %单位控制系统
@onready var 发动判断系统: Node = %发动判断系统
@onready var 日志系统: 战斗_日志系统 = %日志系统


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

	

	
	日志系统.callv("录入信息", [name, "单位主要阶段发动判断", [life, speed], ret可发动的卡牌])
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
				if !卡牌打出与发动系统.get_可用的格子(life.cards_pos["场上"], ["纵向"]):
					continue
				var pos = "场上"
				if await 卡牌发动判断(life, card, pos, speed):
					if !ret可打出的卡牌.has(card):
						ret可打出的卡牌.append(card)

	
	日志系统.callv("录入信息", [name, "单位主要阶段打出判断", [life, speed], ret可打出的卡牌])
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
	
	
	日志系统.callv("录入信息", [name, "单位非主要阶段发动判断", [life, speed], ret可发动的卡牌])
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
		if card.appear and await card.get_value("mp") >= mp:
			var 种类:String = await card.get_value("种类")
			var state:Array[String] = await life.get_value("state")
			if 种类 in ["攻击", "防御"] and (state == [] or state.has(种类)):
				if _打出消耗判断(life, card):
					if !ret可打出的卡牌.has(card):
						ret可打出的卡牌.append(card)
	
	
	日志系统.callv("录入信息", [name, "单位行动阶段打出判断", [life], ret可打出的卡牌])
	return ret可打出的卡牌


func 合成构造判断(cards目标:Array, cards核心:Array, cards素材:Array) -> Dictionary:
	var dic_cards:Dictionary = {}
	cards目标 = cards目标.filter(func(card:战斗_单位管理系统.Card_sys):
		return card.get_value("种类") == "仪式")
	cards核心 = cards素材.filter(func(card:战斗_单位管理系统.Card_sys):
		return !card.get_value("种类") in ["环境", "特殊"] and card.appear >= 2)
	cards素材 = cards素材.filter(func(card:战斗_单位管理系统.Card_sys):
		return !card.get_value("种类") in ["环境", "特殊"] and card.appear >= 2)
	
	
	for arr:Array in [cards目标, cards核心, cards素材]:
		for card:战斗_单位管理系统.Card_sys in arr:
			if !dic_cards.has(card):
				dic_cards[card] = card.get_value("卡名")
	
	var ret:Dictionary
	for card in cards目标:
		var card目标:String = dic_cards[card]
		for card1 in cards核心:
			if card1 == card:
				continue
			var card核心:String = dic_cards[card1]
			if card目标 == card核心:
				continue
			var card目标1:Array = card目标.split()
			var card目标2:Array = card目标.split()
			for i in card核心:
				card目标1.erase(i)
			
			var cards素材1:Array
			for i in cards素材:
				if card目标2.any(func(a):return dic_cards[i].find(a) != -1):
					cards素材1.append(i)
			cards素材1.erase(card)
			cards素材1.erase(card1)
			if cards素材1.size() >= card目标1.size():
				if !ret.has(card):
					ret[card] = {}
				ret[card][card1] = [card目标1.size(), cards素材1]
	
	日志系统.callv("录入信息", [name, "合成构造判断", [cards目标, cards核心, cards素材], ret])
	return ret



##不在场上
func 卡牌发动与消耗判断(card:战斗_单位管理系统.Card_sys, speed:int) -> bool:
	var pos:String = card.get_parent().nam
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	if await _发动消耗判断(life, card):
		if await 卡牌发动判断(life, card, card.get_parent().nam, speed):
			
			日志系统.callv("录入信息", [name, "卡牌发动与消耗判断", [card, speed], true])
			return true
	
	日志系统.callv("录入信息", [name, "卡牌发动与消耗判断", [card, speed], true])
	return false



##在场上
func 卡牌发动判断(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:String, speed:int) -> Array:
	
	if !card.appear:
		
		日志系统.callv("录入信息", [name, "卡牌发动判断", [card, speed], []])
		return []
	
	#无效
	if card.is_无效():
		
		日志系统.callv("录入信息", [name, "卡牌发动判断", [card, speed], []])
		return []
	
	
	var ret可发动的效果:Array = []
	
	for effect:战斗_单位管理系统.Effect_sys in card.effects:
		if await 卡牌发动判断_单个效果(life, card, pos, effect, speed):
			ret可发动的效果.append(effect)
	
	日志系统.callv("录入信息", [name, "卡牌发动判断", [card, speed], ret可发动的效果])
	return ret可发动的效果



func _发动消耗判断(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	var i:int = buff系统.单位与全部buff判断("打出消耗判断", [null, life, card])
	if i == -1:
		
		if card.data["种类"] in ["攻击", "防御"]:
			if int(card.data["mp"]) <= len(life.cards_pos["蓝区"].cards):
				
				日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], true])
				return true
			else:
				
				日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], false])
				return false
		if card.data["种类"] in ["法术", "仪式"]:
			if int(card.data["sp"]) <= len(单位管理系统.get_给定显示以上的卡牌(life.cards_pos["绿区"].cards)):
				
				日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], true])
				return true
			else:
				
				日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], false])
				return false
	elif i == 1:
		
		日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], true])
		return true
	
	日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], false])
	return false



func _打出消耗判断(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	var i:int = buff系统.单位与全部buff判断("打出消耗判断", [null, life, card])
	if i == -1:
		
		if card.data["种类"] in ["攻击", "防御"]:
			if int(card.data["sp"]) <= len(单位管理系统.get_给定显示以上的卡牌(life.cards_pos["绿区"].cards)):
				
				日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], true])
				return true
			else:
				
				日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], false])
				return false
		if card.data["种类"] in ["法术", "仪式"]:
			if int(card.data["mp"]) <= len(life.cards_pos["蓝区"].cards):
				
				日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], true])
				return true
			else:
				
				日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], false])
				return false
	elif i == 1:
		
		日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], true])
		return true
	
	日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], false])
	return false



func 卡牌发动判断_单个效果(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:String, effect:战斗_单位管理系统.Effect_sys, speed:int, more_data:Array = []) -> bool:
	assert(连锁系统.chain_state != 2, "连锁处理中")
	
	var features:Array = await effect.get_value("features")
	
	if 卡牌打出与发动系统.自然下降的卡牌.has(card):
		
		日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	#次数
	if effect.count <= 0:
		
		日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	#启动
	if effect.features.has("启动"):
		if !连锁系统.now_可发动的效果.has(effect) and !more_data.has("启动"):
			
			日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
			return false
	
	#触发
	if effect.features.has("触发"):
		if !连锁系统.now_可发动的效果.has(effect):
			
			日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
			return false
	
	#空格
	if !_空格判断(features, life):
		
		日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	#位置
	if pos != "":
		if !_位置判断(features, pos):
			
			日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
			return false
	
	
	#状态
	if !_状态判断(features, await life.get_value("state")):
		
		日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	#模式
	if !_模式判断(features, await life.get_value("att_mode")):
		
		日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	
	#时差
	if !await _时差判断(card, speed):
		
		日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	
	if !buff系统.单位与全部buff判断("发动判断", [null, life, effect]):
		
		日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	
	#cost
	var targets:Array = [card, life]
	if 连锁系统.now_可发动的效果.has(effect):
		targets = 连锁系统.now_可发动的效果[effect]
	if effect.cost_effect:
		targets = await _效果发动判断(effect.cost_effect, card, features, targets)
	if !targets:
		
		日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	
	#main
	if ! await _效果发动判断(effect.main_effect, card, features, targets):
		
		日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], false])
		return false
	
	
	日志系统.callv("录入信息", [name, "_卡牌发动判断_单个效果", [life, card, pos, effect, speed], true])
	return true


func _空格判断(features:Array, life:战斗_单位管理系统.Life_sys) -> bool:
	if !features.has("启动"):
		if len(卡牌打出与发动系统.get_可用的格子(life.cards_pos["场上"], ["纵向"])) == 0:
			
			日志系统.callv("录入信息", [name, "_空格判断", [features, life], false])
			return false
	
	日志系统.callv("录入信息", [name, "_空格判断", [features, life], true])
	return true

func _位置判断(features:Array, pos:String) -> bool:
	if features.has("任意"):
		
		日志系统.callv("录入信息", [name, "_位置判断", [features, pos], true])
		return true
	
	if features.has("场上"):
		if pos in ["场上"]:
			
			日志系统.callv("录入信息", [name, "_位置判断", [features, pos], true])
			return true
	
	if features.has("行动"):
		if pos in ["行动"]:
			
			日志系统.callv("录入信息", [name, "_位置判断", [features, pos], true])
			return true
	
	for i:String in ["手牌", "白区", "绿区", "蓝区", "红区"]:
		if features.has(i):
			if pos == i:
				
				日志系统.callv("录入信息", [name, "_位置判断", [features, pos], true])
				return true
				
			日志系统.callv("录入信息", [name, "_位置判断", [features, pos], false])
			return false
	
	if !pos in ["场上"]:
		
		日志系统.callv("录入信息", [name, "_位置判断", [features, pos], false])
		return false
	
	日志系统.callv("录入信息", [name, "_位置判断", [features, pos], true])
	return true

func _状态判断(features:Array, state:Array[String]) -> bool:
	for i:String in ["攻击", "防御"]:
		if features.has(i):
			if !state.has(i):
				
				日志系统.callv("录入信息", [name, "_状态判断", [features, state], false])
				return false
	
	日志系统.callv("录入信息", [name, "_状态判断", [features, state], true])
	return true

func _模式判断(features:Array, mode:Array[String]) -> bool:
	for i:String in ["重击", "斩击", "刺击", "格挡", "直接攻击"]:
		if features.has(i):
			if !mode.has(i):
				
				日志系统.callv("录入信息", [name, "_模式判断", [features, mode], false])
				return false
	
	日志系统.callv("录入信息", [name, "_模式判断", [features, mode], true])
	return true

func _时差判断(card:战斗_单位管理系统.Card_sys, speed:int) -> bool:
	var ret:bool
	var 种类:String = await card.get_value("种类")
	if 种类 in ["攻击", "防御"]:
		ret = await card.get_value("sp") >= speed
	elif 种类 in ["法术"]:
		ret = await card.get_value("mp") >= speed
	elif 种类 in ["仪式"]:
		if card.get_parent().nam == "场上":
			ret = (0 >= speed)
		else :
			ret = await card.get_value("mp") >= speed
	
	日志系统.callv("录入信息", [name, "_时差判断", [card, speed], ret])
	return ret





func _效果发动判断(eff:Array, car:战斗_单位管理系统.Card_sys, fea:Array = [], tar:Array = []) -> Array:
	var effect_processing:= 战斗_发动判断系统.new(self, eff, [单位管理系统.lifes, 单位管理系统.efils], car, fea, tar)
	var ret:Array = await effect_processing.start()
	effect_processing.queue_free()
	
	日志系统.callv("录入信息", [name, "_效果发动判断", [eff, fea, tar], ret])
	return ret
