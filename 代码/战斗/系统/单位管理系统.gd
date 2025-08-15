extends Node
class_name 战斗_单位管理系统


@onready var buff系统: Node = %buff系统
@onready var 日志系统: 战斗_日志系统 = %日志系统


var all_lifes:Array[Life_sys]
var lifes:Array[Life_sys]
var efils:Array[Life_sys]
var 数据改变唯一标识:int = -1



func create_life(life_cont:战斗_单位控制, is_positive:bool) -> Life_sys:
	var life:Life_sys = Life_sys.new(life_cont, buff系统)
	add_child(life)
	#记录
	all_lifes.append(life)
	if is_positive:
		lifes.append(life)
	else :
		efils.append(life)
	
	return life

func create_card(card_name:String) -> Card_sys:
	return Card_sys.new(card_name, buff系统)

func create_buff(buff_name, car:Card_sys = null, 结束时间:String = "", 结束次数:int = 1) -> Buff_sys:
	return Buff_sys.new(buff_name, buff系统, car, 结束时间, 结束次数)

func 创造牌库(life:Life_sys, cards:Array) -> void:
	for i:String in cards:
		var card := Card_sys.new(i, buff系统)
		life.cards_pos["白区"].add_card(card)
		card.own = life


func get_给定显示以上的卡牌(cards:Array[Card_sys], appear:int = 1) -> Array[Card_sys]:
	var ret:Array[Card_sys] = []
	for card:Card_sys in cards:
		if card.appear >= appear:
			ret.append(card)
	return ret

func get_life场上第一张是纵向的格子数量(life:Life_sys) -> int:
	var pos_arr:Array = life.cards_pos["场上"]
	var ret:int = 0
	for pos:战斗_单位管理系统.Card_pos_sys in pos_arr:
		if pos.cards != [] and pos.cards[0].direction:
			ret += 1
	
	return ret

func get_数据改变唯一标识() -> int:
	数据改变唯一标识 += 1
	return 数据改变唯一标识



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
	var nam:String
	var data:Resource
	var 编号:int#编号
	var history:Array[History_sys] = []
	var event_bus : CoreSystem.EventBus = CoreSystem.event_bus
	
	
	func _set_index() -> void:
		event_bus.push_event("战斗_datasys被创造", [self])
		event_bus.subscribe("战斗_datasys被删除", remove_data_sys)
	
	func free_self() -> void:
		if get_parent():
			get_parent().remove_child(self)
		event_bus.push_event("战斗_datasys被删除", [self])
		queue_free()
	
	func remove_data_sys(data_sys:Data_sys) -> void:
		pass
	
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
	var buffs:Array[Buff_sys] = []
	var buff_effect:Array = []
	var main_effect:Array = []
	var cost_effect:Array = []
	var features:Array = []
	var count:int = 0#发动次数
	
	func _init(eff:Array, def) -> void:
		_set_index()
		buff系统 = def
		main_effect = eff.duplicate(true)
		var remove_arr:Array
		for i:Array in main_effect:
			if i[0] == "buff":
				remove_arr.append(i)
				i = i.duplicate(true)
				i.remove_at(0)
				buff_effect.append_array(i)
			
			if i[0] == "特征":
				remove_arr.append(i)
				i = i.duplicate(true)
				i.remove_at(0)
				features.append_array(i)
			
			if i[0] == "条件":
				remove_arr.append(i)
				i = i.duplicate(true)
				i.remove_at(0)
				cost_effect.append_array(i)
			
			
		for i:Array in remove_arr:
			main_effect.erase(i)
		
		
		event_bus.push_event("战斗_datasys被创建", [self])
	
	
	func add_buffs() -> void:
		for i:String in buff_effect:
			var buff := Buff_sys.new(i, buff系统, get_parent())
			buff.触发 = self
			buffs.append(buff)
			get_parent().get_parent().get_parent().add_buff(buff)
	
	
	#寻找特定字符
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
		return value
	
	func remove_data_sys(data_sys:Data_sys) -> void:
		if data_sys is Buff_sys:
			buffs.erase(data_sys)


class Life_sys extends Data_sys:
	var buff系统: Node
	var buffs:Array[Buff_sys]
	var equips:Array[Equip_sys]
	var group:Array
	var 种类:String
	var speed:int = 10
	var cards_pos:Dictionary ={}
	var state:Array[String] =[]
	var att_mode:Array[String] =[]
	var att_life:Life_sys#攻击目标
	var face_life:Life_sys#面对目标
	
	func _init(life_cont:战斗_单位控制, def) -> void:
		_set_index()
		nam = life_cont.life_nam
		group = life_cont.组
		种类 = life_cont.种类
		buff系统 = def
		
		for i:String in ["行动", "手牌", "白区", "绿区", "蓝区", "红区"]:
			cards_pos[i] = Card_pos_sys.new(i)
			add_child(cards_pos[i])
		cards_pos["场上"] = []
		for i:int in 6:
			cards_pos["场上"].append(Card_pos_sys.new("场上"))
			cards_pos["场上"][-1].场上index = i
			add_child(cards_pos["场上"][-1])
		
		for i:String in life_cont.装备:
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
		if key in ["speed", "state", "att_mode"]:
			await buff系统.单位与全部buff判断(key, [null, self, self, value])
		return value

	func set_state(sta:String) -> void:
		state = [sta]
		event_bus.push_event("战斗_请求检查行动冲突", [self])
	
	func remove_data_sys(data_sys:Data_sys) -> void:
		if data_sys is Buff_sys:
			buffs.erase(data_sys)


class Card_pos_sys extends Data_sys:
	var cards:Array[Card_sys]
	var 场上index:int
	
	func _init(pos:String) -> void:
		_set_index()
		nam = pos
		
		event_bus.push_event("战斗_datasys被创建", [self])
		
	func add_card(card:Card_sys) -> void:
		if nam in ["手牌", "白区"]:
			cards.append(card)
		else :
			cards.insert(0, card)
		if nam in ["场上"]:
			card.pos = nam + str(场上index)
		else:
			card.pos = nam
		card.his_pos.append(card.pos)
		add_child(card)
		card.reset_appear()
		
		
	
	
	func move_card(card:Card_sys, ind:int) -> bool:
		if !cards.has(card):
			return false
		
		move_child(card, ind)
		
		cards.erase(card)
		if ind <= cards.size():
			cards.insert(ind, card)
		else :
			cards.append(card)
		
		card.reset_appear()
		
		return true
	
	
	func remove_card(card:Card_sys) -> void:
		cards.erase(card)
		remove_child(card)
		for i in cards:
			i.reset_appear()


class Card_sys extends Data_sys:
	var own:Life_sys
	var buff系统: Node
	var effects:Array[Effect_sys] = []
	var direction:int = 1
	var appear:int = 0:
		set(value):
			appear = value
			if appear > 0:
				assert(data, "")
	var state:bool = false
	var time_take:int
	var pos:String
	var his_pos:Array
	var 数据改变:Dictionary = {"卡名":[], "种类":[], "sp":[], "mp":[], "特征":[], "组":[]}
	
	func _init(card_name:String, def) -> void:
		_set_index()
		nam = card_name
		buff系统 = def
		event_bus.push_event("战斗_datasys被创建", [self])


	func face_up() -> void:
		if appear:
			return
	
		if nam:
			data = DatatableLoader.get_data_model("card_data", nam)
		
		
		appear = 1
		reset_appear()
		
		for i:Array in data["效果"]:
			var effect = Effect_sys.new(i, buff系统)
			effects.append(effect)
			add_child(effect)
			if get_parent().nam == "场上" and effect.features.has("反转"):
				if effect.count <= 0:
					effect.count += 1


	func reset_appear() -> int:
		if appear == 0:
			return 0
		var pos:Card_pos_sys = get_parent()
		if pos.nam == "场上":
			if direction == 0:
				appear = 2
			elif pos.cards.find(self) == 0:
				appear = 4
			else :
				appear = 1
		elif pos.nam == "行动":
			appear = 4
		else:
			appear = 3
		
		event_bus.push_event("战斗_添加触发与固有buff", self)
		
		return appear

	func face_down() -> void:
		if !appear:
			return
		
		数据改变 = {"卡名":[], "种类":[], "sp":[], "mp":[], "特征":[], "组":[]}
		
		data = null
		for i in effects:
			i.free_self()
		effects = []
		
		appear = 0


	func get_value(key:String):
		if !appear:
			return
		
		var value = data.get(key)
		if value is Dictionary or value is Array:
			value = value.duplicate(true)
		
		if key in ["sp", "mp"]:
			for arr:Array in 数据改变[key]:
				if arr[0] == "加":
					value += arr[1]
				elif arr[0] == "减":
					value -= arr[1]
				elif arr[0] == "等":
					value = arr[1]
		elif key in ["特征", "组"]:
			for arr:Array in 数据改变[key]:
				if arr[0] == "加":
					value.append_array(arr[1])
				elif arr[0] == "减":
					for i in arr[1]:
						value.erase(i)
				elif arr[0] == "等":
					value = arr[1]
		elif key in ["卡名"]:
			value = value.split()
			for arr:Array in 数据改变[key]:
				if arr[0] == "加":
					value.append_array(arr[1])
				elif arr[0] == "减":
					for i in arr[1]:
						value.erase(i)
				elif arr[0] == "等":
					value = arr[1]
			value = "".join(value)
		elif key in ["种类"]:
			for arr:Array in 数据改变[key]:
				value = arr[1]
		
		return value

	func add_value(key:String, arr:Array) -> void:
		数据改变[key].append(arr)

	func remove_value(ind:int) -> String:
		for key:String in 数据改变.keys():
			var erase:Array
			for arr:Array in 数据改变[key]:
				if arr[2] == ind:
					erase = arr
					break
			数据改变[key].erase(erase)
			return key
		return ""



class Buff_sys extends Data_sys:
	var buff系统: Node
	var effect:Effect_sys
	var 触发:Effect_sys
	var card:Card_sys#这个buff依赖的卡牌
	var targets:Array = [null, null, null, null, null, null, null, null, null, null]
	
	func _init(buff_name, def, car:Card_sys = null, 结束时间:String = "", 结束次数:int = 1) -> void:
		_set_index()
		buff系统 = def
		if buff_name:
			data = DatatableLoader.get_data_model("buff_data", buff_name)
		nam = buff_name
		
		effect = Effect_sys.new(data["效果"][0], buff系统)
		add_child(effect)
		
		card = car
		
		if 结束时间:
			event_bus.push_event("战斗_录入按时间结束的buff", [self, 结束时间, 结束次数])
		
		event_bus.push_event("战斗_datasys被创建", [self])


class Equip_sys extends Data_sys:
	
	
	func _init(equip_name) -> void:
		_set_index()
		if equip_name:
			data = DatatableLoader.get_data_model("equip_data", equip_name)
		event_bus.push_event("战斗_datasys被创建", [self])
