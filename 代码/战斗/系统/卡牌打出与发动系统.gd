extends Node


@onready var 最终行动系统: Node = $"../../最终行动系统"
@onready var buff系统: Node = $"../buff系统"
@onready var 发动判断系统: Node = %发动判断系统
@onready var 连锁系统: Node = $"../../连锁系统"

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var 等待清除的卡牌:Dictionary[战斗_单位管理系统.Card_sys, String]


func 打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> void:
	if card.get_value("种类") in ["攻击", "防御"]:
		最终行动系统.行动打出(life, card)
	elif card.get_value("种类") in ["法术"]:
		最终行动系统.非行动打出(life, card)
	
	pass

func 启动效果(card:战斗_单位管理系统.Card_sys) -> void:
	pass


func 发动场上的效果(card:战斗_单位管理系统.Card_sys, effect_mode:String) -> void:
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	var arr_eff:Array[战斗_单位管理系统.Effect_sys]
	var cost_mode:String = ""
	if effect_mode == "启动":
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has("启动"):
				if 发动判断系统.卡牌发动判断_单个效果(life, card, "", effect, 连锁系统.now_time_take):
					arr_eff.append(effect)
	elif effect_mode in ["手牌", "绿区", "蓝区", "白区", "红区"]:
		cost_mode = "非打出"
		等待清除的卡牌[card] = effect_mode
		for effect:战斗_单位管理系统.Effect_sys in card.effects:
			if effect.features.has(effect_mode):
				if 发动判断系统.卡牌发动判断_单个效果(life, card, "", effect, 连锁系统.now_time_take):
					arr_eff.append(effect)
	elif effect_mode == "打出":
		cost_mode = "打出"
		等待清除的卡牌[card] = effect_mode
		arr_eff = 发动判断系统.卡牌发动判断(card, 连锁系统.now_time_take)
	elif effect_mode == "直接":
		arr_eff = 发动判断系统.卡牌发动判断(card, 连锁系统.now_time_take)
	
	var arr_int:Array[int] = []
	for effect:战斗_单位管理系统.Effect_sys in arr_eff:
		arr_int.append(card.effects.find(effect))
	
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
					break
			
			if pos.cards == []:
				erase_pos.append(pos)
				break
			
			if i == "纵向":
				if pos.cards[0].direction:
					erase_pos.append(pos)
					break
			if i == "横向":
				if !pos.cards[-1].direction:
					erase_pos.append(pos)
					break
	
	for pos:战斗_单位管理系统.Card_pos_sys in erase_pos:
		pos_arr.erase(pos)
	
	
	return pos_arr
