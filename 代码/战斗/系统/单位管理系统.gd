extends Node
class_name 战斗_单位管理系统


@onready var buff系统: Node = %buff系统



var lifes:Array[Life_sys]
var efils:Array[Life_sys]




func create_life(life_name:String, is_positive:bool) -> Life_sys:
	var life:Life_sys = Life_sys.new(life_name, buff系统)
	#记录
	if is_positive:
		lifes.append(life)
	else :
		efils.append(life)
		

	
	return life

func create_card(card_name:String) -> Card_sys:
	return Card_sys.new(card_name, buff系统)


func 创造牌库(life:Life_sys, cards:Array[String]) -> void:
	for i:String in cards:
		life.cards_pos["白区"].add_card(Card_sys.new(i, buff系统))


func get_给定显示以上的卡牌(cards:Array[Card_sys], appear:int = 1) -> Array[Card_sys]:
	var ret:Array[Card_sys] = []
	for card:Card_sys in cards:
		if card.appear >= appear:
			ret.append(card)
	return ret


func get_life场上第一张是纵向的格子数量(life:Life_sys) -> int:
	var pos_arr:Array[战斗_单位管理系统.Card_pos_sys] = life.cards_pos["场上"]
	var ret:int = 0
	for pos:战斗_单位管理系统.Card_pos_sys in pos_arr:
		if pos.cards != [] and pos.cards[0].direction:
			ret += 1
	
	return ret



class History_sys extends Resource:
	var tapy:String
	var turn:int
	var period:String
	var data
	
	func _init(tap:String, tur:int, per:String, dat) -> void:
		tapy = tap
		turn = tur
		period = per
		data = dat


class Data_sys extends Node:
	var data:Resource
	var index:int#编号
	var history:Array[History_sys] = []
	var event_bus : CoreSystem.EventBus = CoreSystem.event_bus
	
	
	
	func free_self() -> void:
		get_parent().remove_child(self)
		event_bus.push_event("战斗_datasys被删除", [self])
		queue_free()
		
	func add_history(tap:String, tur:int, per:String, dat = null) -> void:
		history.append(History_sys.new(tap, tur, per, dat))
	
	func find_last_history(tapy:String) -> History_sys:
		var his:Array[History_sys] = history.duplicate(true)
		his.reverse()
		for i:History_sys in his:
			if i.tapy == tapy:
				return i
		return


class Effect_sys extends Data_sys:
	var buff系统: Node
	var main_effect:Array = []
	var cost_effect:Array = []
	var features:Array = []
	
	
	func _init(eff:Array, def) -> void:
		buff系统 = def
		main_effect = eff.duplicate(true)
		var remove_arr:Array
		for i:Array in main_effect:
			if i[0] == "特征":
				remove_arr.append(i)
				features = i[0].duplicate(true)
				features.remove_at(0)
				
			
			if i[0] == "条件":
				remove_arr.append(i)
				cost_effect = i[0].duplicate(true)
				cost_effect.remove_at(0)
				
			
		for i:Array in remove_arr:
			main_effect.erase(i)
			
			
		event_bus.push_event("战斗_datasys被创建", [self])
		
		
		
		
	func _has_element(arr, target) -> bool:
		for item in arr:
			if item == target:  # 找到目标元素
				return true
			elif item is Array:  # 如果是子数组，递归检查
				if _has_element(item, target):
					return true
		return false  # 遍历完未找到
	
	
	func get_value(key:String):
		var value = get(key)
		buff系统.单位与全部buff判断(key, [self, null, value])
		return value


class Life_sys extends Data_sys:
	var buff系统: Node
	var buffs:Array[Buff_sys]
	var equips:Array[Equip_sys]
	var speed:int = 10
	var cards_pos:Dictionary ={}
	var state:Array[String] =[]
	var att_life:Life_sys#攻击目标
	var face_life:Life_sys#面对目标
	
	func _init(life_name, def) -> void:
		buff系统 = def
		if life_name:
			data = DatatableLoader.get_data_model("life_data", life_name)
		
		for i:String in ["行动", "手牌", "白区", "绿区", "蓝区", "红区"]:
			cards_pos[i] = Card_pos_sys.new(i)
		cards_pos["场上"] = []
		for i:int in 6:
			cards_pos["场上"].append(Card_pos_sys.new("场上"))
		
		for i:String in data["装备"]:
			var equip:Equip_sys = Equip_sys.new(i)
			equips.append(equip)
			for i1:String in equip.data["buff"]:
				add_buff(Buff_sys.new(i1, buff系统))
		
		for i:Equip_sys in equips:
			speed -= int(i.data["重量"])
		if speed <= 0:
			speed = 1
		
		event_bus.push_event("战斗_datasys被创建", [self])
	
	func add_buff(buff:Buff_sys) -> void:
		buffs.append(buff)
		add_child(buff)
		event_bus.push_event("战斗_单位添加了buff", [self, buff])
		
	func remove_buff(buff:Buff_sys) -> void:
		buffs.erase(buff)
		event_bus.push_event("战斗_单位移除了buff", [self, buff])
		buff.free_self()
		
	func get_all_cards() -> Array[Card_sys]:
		var ret:Array[Card_sys]
		for i:String in cards_pos:
			if i == "场上":
				for i1:Card_pos_sys in cards_pos[i]:
					ret.append_array(i1.cards)
			else :
				ret.append_array(cards_pos[i].cards)
		return ret
		
	func find_card(card:Card_sys) -> String:
		for i:String in cards_pos:
			if cards_pos[i].cards.has(card):
				return i
		return ""
	
	func get_value(key:String):
		var value = get(key)
		buff系统.单位与全部buff判断(key, [self, null, value])
		return value

	func set_state(sta:String) -> void:
		state = [sta]
		event_bus.push_event("战斗_请求检查行动冲突", [self])


class Card_pos_sys extends Data_sys:
	var cards:Array[Card_sys]
	
	func _init(pos:String) -> void:
		name = pos
		
		event_bus.push_event("战斗_datasys被创建", [self])
		
	func add_card(card:Card_sys) -> void:
		if name != "手牌":
			cards.insert(0, card)
		else :
			cards.append(card)
		add_child(card)
		
	func remove_card(card:Card_sys) -> void:
		cards.erase(card)
		remove_child(card)


class Card_sys extends Data_sys:
	var buff系统: Node
	var effects:Array[Effect_sys] = []
	var direction:int = 1
	var appear:int = 0
	var time_take:int
	
	func _init(card_name:String, def) -> void:
		name = card_name
		if card_name:
			data = DatatableLoader.get_data_model("card_data", card_name)
		buff系统 = def
		event_bus.push_event("战斗_datasys被创建", [self])
		
	
	func face_up() -> void:
		if appear:
			return
		
		if name:
			data = DatatableLoader.get_data_model("card_data", name)
		
		for i:Array in data["效果"]:
			var effect = Effect_sys.new(i, buff系统)
			effects.append(effect)
			add_child(effect)
		
		appear = true
	
	func reset_emerde() -> int:
		if direction == 0:
			appear = 2
		
		var pos:Card_pos_sys = get_parent()
		if pos.name == "场上":
			if direction == 0:
				appear = 2
			elif pos.cards.find(self) == 0:
				appear = 4
			else :
				appear = 1
		elif pos.name == "行动":
			appear = 4
		else:
			appear = 3
		
		
		return appear
	
	
	
	func face_down() -> void:
		if !appear:
			return
			
		effects = []
		direction = 1
		
		appear = 0
		


	func get_value(key:String):
		if !appear:
			return
		
		var value = data[key].duplicate(true)
		buff系统.单位与全部buff判断(key, [self, null, value])
		return value


class Buff_sys extends Data_sys:
	var buff系统: Node
	var effect:Effect_sys
	var card:Card_sys#这个buff依赖的卡牌
	
	func _init(buff_name, def, car:Card_sys = null, 结束时间:String = "", 结束次数:int = 1) -> void:
		buff系统 = def
		if buff_name:
			data = DatatableLoader.get_data_model("buff_data", buff_name)
		
		effect = Effect_sys.new(data["效果"], buff系统)
		add_child(effect)
		
		card = car
		
		if 结束时间:
			event_bus.push_event("战斗_录入按时间结束的buff", [self, 结束时间, 结束次数])
		
		event_bus.push_event("战斗_datasys被创建", [self])


class Equip_sys extends Data_sys:
	
	
	func _init(equip_name) -> void:
		if equip_name:
			data = DatatableLoader.get_data_model("equip_data", equip_name)
		event_bus.push_event("战斗_datasys被创建", [self])
