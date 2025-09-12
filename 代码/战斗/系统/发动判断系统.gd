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
@onready var 场地系统: Node = %场地系统
@onready var 二级行动系统: Node = %二级行动系统


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func 单位活动回合发动判断(life:战斗_单位管理系统.Life_sys) -> Array[战斗_单位管理系统.Card_sys]:
	日志系统.录入日志("单位活动回合发动判断", [life])
	#冲击
	if life.get_value("state").has("冲击"):
		return []
	
	var ret可发动的卡牌:Array[战斗_单位管理系统.Card_sys] = []
	var cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards(), 3)
	for card:战斗_单位管理系统.Card_sys in cards:
		#test
		if card.test == 1:
			pass
		
		
		if await _发动消耗判断(life, card):
			if await 卡牌发动判断(life, card, card.get_parent().nam):
				if !ret可发动的卡牌.has(card):
					ret可发动的卡牌.append(card)

	

	
	日志系统.callv("录入信息", [name, "单位活动回合发动判断", [life], ret可发动的卡牌])
	return ret可发动的卡牌


func 单位主要阶段打出判断(life:战斗_单位管理系统.Life_sys) -> Array[战斗_单位管理系统.Card_sys]:
	日志系统.录入日志("单位主要阶段打出判断", [life])
	var ret可打出的卡牌:Array[战斗_单位管理系统.Card_sys] = []
	#打出
	for card:战斗_单位管理系统.Card_sys in life.cards_pos["手牌"].cards:
		if !场地系统.get_可用场上(life, "手牌", 0):
			continue
		if _打出消耗判断(life, card):
			if card.data["种类"] in ["仪式"]:
				if !ret可打出的卡牌.has(card):
					ret可打出的卡牌.append(card)
			elif card.data["种类"] in ["法术"]:
				var pos = "场上"
				if await 卡牌发动判断(life, card, pos):
					if !ret可打出的卡牌.has(card):
						ret可打出的卡牌.append(card)

	
	日志系统.callv("录入信息", [name, "单位主要阶段打出判断", [life], ret可打出的卡牌])
	return ret可打出的卡牌


func 单位非活动回合发动判断(life:战斗_单位管理系统.Life_sys) -> Array[战斗_单位管理系统.Card_sys]:
	日志系统.录入日志("单位主要阶段打出判断", [life])
	#冲击
	if life.get_value("state").has("冲击"):
		return []
	
	var ret可发动的卡牌:Array[战斗_单位管理系统.Card_sys] = []
	var cards:Array[战斗_单位管理系统.Card_sys]
	if life.state.has("防御"):
		cards = 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards(), 3)
	else :
		cards = 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards(), 4)
	for card:战斗_单位管理系统.Card_sys in cards:
		#test
		if card.test == 1:
			pass
		
		if await _发动消耗判断(life, card):
			if await 卡牌发动判断(life, card, card.get_parent().nam):
				if !ret可发动的卡牌.has(card):
					ret可发动的卡牌.append(card)
	
	
	日志系统.callv("录入信息", [name, "单位非活动回合发动判断", [life], ret可发动的卡牌])
	return ret可发动的卡牌


func 单位行动阶段打出判断(life:战斗_单位管理系统.Life_sys) -> Array[战斗_单位管理系统.Card_sys]:
	日志系统.录入日志("单位主要阶段打出判断", [life])
	var ret可打出的卡牌:Array[战斗_单位管理系统.Card_sys] = []
	
	#打出
	for card:战斗_单位管理系统.Card_sys in life.cards_pos["手牌"].cards:
		var 种类:String = await card.get_value("种类")
		var state:Array[String] = await life.get_value("state")
		if 种类 in ["攻击", "防御"] and (state == [] or state.has(种类)):
			if _打出消耗判断(life, card):
				if !ret可打出的卡牌.has(card):
					ret可打出的卡牌.append(card)
	
	
	日志系统.callv("录入信息", [name, "单位行动阶段打出判断", [life], ret可打出的卡牌])
	return ret可打出的卡牌


func 合成构造判断(life:战斗_单位管理系统.Life_sys, cards目标:Array, cards核心:Array, cards素材:Array) -> Dictionary:
	if !场地系统.get_可用场上(life, "手牌", 0):
		return {}
	
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
			if len(card目标1) == len(card目标2):
				continue
			
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
	日志系统.录入日志("合成构造判断", [cards目标, cards核心, cards素材, bool(!ret.is_empty())])
	return ret





func 卡牌发动判断(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:String) -> Array:
	日志系统.录入日志("卡牌发动判断", [card, pos])
	#卡名无效检测
	if !card.get_parent().nam in ["红区"]:
		var arr:Array = life.get_value("卡名无效")
		if arr.has(card.nam):
			
			日志系统.callv("录入信息", [name, "卡牌发动判断", [life, card, pos], "卡名无效检测未通过"])
			日志系统.录入日志("卡牌发动判断_卡名无效检测", [false])
			return []
	
	#可用格检测
	if !card.get_parent().nam in ["场上", "行动"]:
		if !场地系统.get_可用场上(life, card.pos, card.get_value("mp")):
			
			日志系统.callv("录入信息", [name, "卡牌发动判断", [life, card, pos], "可用格检测未通过"])
			日志系统.录入日志("卡牌发动判断_可用格检测", [card.pos, card.get_value("mp"), false])
			return []
	
	#连接检测
	if card.get_parent().nam in ["场上"]:
		if !场地系统.get_连接场上(life).has(card.get_parent()):
			
			日志系统.callv("录入信息", [name, "卡牌发动判断", [life, card, pos], "连接检测未通过"])
			日志系统.录入日志("卡牌发动判断_连接检测", [false])
			return []
	
	#表侧检测
	if !card.appear:
		
		日志系统.callv("录入信息", [name, "卡牌发动判断", [life, card, pos], "表侧检测未通过"])
		日志系统.录入日志("卡牌发动判断_表侧检测", [false])
		return []
	
	#无效检测
	if card.is_无效():
		
		日志系统.callv("录入信息", [name, "卡牌发动判断", [life, card, pos], "无效检测未通过"])
		日志系统.录入日志("卡牌发动判断_无效检测", [false])
		return []
	
	#自然下降检测
	if card.get_value("特征").has("下降"):
		
		日志系统.callv("录入信息", [name, "卡牌发动判断", [life, card, pos], "自然下降检测未通过"])
		日志系统.录入日志("卡牌发动判断_自然下降检测", [false])
		return []
	
	var ret可发动的效果:Array = []
	
	for effect:战斗_单位管理系统.Effect_sys in card.effects:
		if await 卡牌发动判断_单个效果(life, card, pos, effect):
			ret可发动的效果.append(effect)
			effect.set_颜色信息("可以发动")
	
	if ret可发动的效果:
		日志系统.callv("录入信息", [name, "卡牌发动判断", [life, card, pos], "通过"])
	else:
		日志系统.callv("录入信息", [name, "卡牌发动判断", [life, card, pos], "未通过"])
	return ret可发动的效果



func _发动消耗判断(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	
	#日志系统.callv("录入信息", [name, "_发动消耗判断", [life, card], false])
	return true



func _打出消耗判断(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	
	#日志系统.callv("录入信息", [name, "_打出消耗判断", [life, card], false])
	return true



func 卡牌发动判断_单个效果(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:String, effect:战斗_单位管理系统.Effect_sys, more_data:Array = []) -> bool:
	assert(连锁系统.chain_state != 2, "连锁处理中")
	日志系统.录入日志("卡牌发动判断_单个效果", [card, card.effects.find(effect)])
	var features:Array = await effect.get_value("features")
	
	#次数检测
	if effect.count <= 0:
		
		日志系统.callv("录入信息", [name, "卡牌发动判断_单个效果", [life, card, pos, effect], "次数检测未通过"])
		return false
	
	#位置检测
	if pos != "":
		if !_位置判断(features, pos):
			
			日志系统.callv("录入信息", [name, "卡牌发动判断_单个效果", [life, card, pos, effect], "位置检测未通过"])
			return false
	
	#启动检测
	if effect.features.has("启动"):
		if !连锁系统.now_可发动的效果.has(effect) and !more_data.has("启动"):
			
			日志系统.callv("录入信息", [name, "卡牌发动判断_单个效果", [life, card, pos, effect], "启动检测未通过"])
			return false
	
	#触发检测
	if effect.features.has("触发"):
		if !连锁系统.now_可发动的效果.has(effect):
			
			日志系统.callv("录入信息", [name, "卡牌发动判断_单个效果", [life, card, pos, effect], "触发检测未通过"])
			return false
	
	
	#状态检测
	if !_状态判断(features, await life.get_value("state")):
		
		日志系统.callv("录入信息", [name, "卡牌发动判断_单个效果", [life, card, pos, effect], "状态检测未通过"])
		return false
	
	#模式检测
	if !_模式判断(features, await life.get_value("att_mode")):
		
		日志系统.callv("录入信息", [name, "卡牌发动判断_单个效果", [life, card, pos, effect], "模式检测未通过"])
		return false
	
	
	#buff检测
	if !buff系统.单位与全部buff判断("发动判断", [null, life, effect]):
		
		日志系统.callv("录入信息", [name, "卡牌发动判断_单个效果", [life, card, pos, effect], "buff检测未通过"])
		return false
	
	
	#cost检测
	var targets:Array = [card, life]
	if 连锁系统.now_可发动的效果.has(effect):
		targets = 连锁系统.now_可发动的效果[effect]
	if effect.cost_effect:
		targets = await _效果发动判断(effect.cost_effect, card, features, targets)
	if !targets:
		
		日志系统.callv("录入信息", [name, "卡牌发动判断_单个效果", [life, card, pos, effect], "cost检测未通过"])
		return false
	
	
	#main检测
	if targets.size() == 10:
		if ! await _效果发动判断(effect.main_effect, card, features, targets):
			
			日志系统.callv("录入信息", [name, "卡牌发动判断_单个效果", [life, card, pos, effect], "main检测未通过"])
			return false
	
	
	日志系统.callv("录入信息", [name, "卡牌发动判断_单个效果", [life, card, pos, effect], "通过"])
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
				if pos == "蓝区":
					pass
				
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





func _效果发动判断(eff:Array, car:战斗_单位管理系统.Card_sys, fea:Array = [], tar:Array = []) -> Array:
	var effect_processing:= 战斗_发动判断系统.new(self, eff, [单位管理系统.lifes, 单位管理系统.efils], car, fea, tar.duplicate(true))
	var ret:Array = await effect_processing.start()
	effect_processing.queue_free()
	
	日志系统.callv("录入信息", [name, "_效果发动判断", [eff, fea, tar], ret])
	return ret
