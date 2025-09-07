extends Node
class_name 战斗_单位管理系统


@onready var buff系统: Node = %buff系统
@onready var 日志系统: 战斗_日志系统 = %日志系统
@onready var 最终行动系统: Node = %最终行动系统


var all_lifes:Array[Life_sys]
var lifes:Array[Life_sys]
var efils:Array[Life_sys]
var 数据改变唯一标识:int = -1



func create_life(life_cont:战斗_单位控制, is_positive:bool) -> Life_sys:
	var life:Life_sys = Life_sys.new(life_cont, buff系统, is_positive)
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


func 创造牌库(life:Life_sys, cards:Array) -> void:
	for i:String in cards:
		var card := Card_sys.new(i, buff系统)
		life.cards_pos["白区"].add_card(card)
		card.own = life
		card.所属life = life


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
	var 临时buff_effect:Array = [[]]
	var main_effect:Array = []
	var cost_effect:Array = []
	var features:Array = []
	var count:int = 0#发动次数
	var 颜色信息:String
	
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
			
			elif i[0] == "临时buff":
				remove_arr.append(i)
				i = i.duplicate(true)
				i.remove_at(0)
				
				var 影响:Array
				var buff_eff:Array
				for i2 in i:
					if i2 is Array:
						buff_eff.append(i2)
					else :
						影响.append(i2)
				临时buff_effect[0].append_array(影响)
				临时buff_effect.append_array(buff_eff)
			
			elif i[0] == "特征":
				remove_arr.append(i)
				i = i.duplicate(true)
				i.remove_at(0)
				features.append_array(i)
			
			elif i[0] == "条件":
				remove_arr.append(i)
				i = i.duplicate(true)
				i.remove_at(0)
				cost_effect.append_array(i)
			
			
		for i:Array in remove_arr:
			main_effect.erase(i)
		
		
		event_bus.push_event("战斗_datasys被创建", [self])
	
	
	func add_buffs() -> void:
		for i:String in buff_effect:
			var buff:Buff_sys = buff系统.create_buff(i, get_parent())
			if features.has("触发") or features.has("固有"):
				buff.触发 = self
			buffs.append(buff)
		
		if 临时buff_effect != [[]]:
			var buff_arr:Array = 临时buff_effect.duplicate(true)
			var 影响:Array = buff_arr.pop_front()
			var buff:Buff_sys = buff系统.create_buff_noname(影响, buff_arr, get_parent())
			if features.has("触发") or features.has("固有"):
				buff.触发 = self
			buffs.append(buff)
			
	
	#寻找特定字符
	func _has_element(arr, target) -> bool:
		for item in arr:
			if item == target:  # 找到目标元素
				return true
			elif item is Array:  # 如果是子数组，递归检查
				if _has_element(item, target):
					return true
		return false  # 遍历完未找到
	
	func set_颜色信息(s:String) -> void:
		if s:
			颜色信息 = s
			return
		if count <= 0:
			颜色信息 = "发动次数小于一"
		else:
			颜色信息 = ""
	
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
	var cards_pos:Dictionary ={}
	var is_positive:bool
	var att_life:Life_sys#攻击目标
	var face_life:Life_sys#面对目标
	
	var speed:int = 10
	var state:Array[String] =[]
	var 信息state:Array[String] =[]
	var att_mode:Array[String] =[]
	var 卡名无效:Array =[]
	var 数据改变:Dictionary = {"speed":[], "state":[], "att_mode":[], "卡名无效":[]}
	
	func _init(life_cont:战斗_单位控制, def, p_is_positive:bool) -> void:
		_set_index()
		nam = life_cont.life_nam
		group = life_cont.组
		种类 = life_cont.种类
		buff系统 = def
		is_positive = p_is_positive
		
		for i:String in ["行动", "手牌", "白区", "绿区", "蓝区", "红区", "源区"]:
			cards_pos[i] = Card_pos_sys.new(i)
			add_child(cards_pos[i])
		cards_pos["场上"] = []
		
		for i:String in life_cont.装备:
			var equip:Equip_sys = Equip_sys.new(i)
			equips.append(equip)
			for i1:String in equip.data["buff"]:
				add_buff(buff系统.create_buff(i1))
		
		for i:Equip_sys in equips:
			speed -= int(i.data["重量"])
		if speed <= 0:
			speed = 1
		
		event_bus.push_event("战斗_datasys被创建", [self])

	func add_场上(pos:Card_pos_sys) -> bool:
		if cards_pos["场上"].has(pos):
			return false
		if pos.get_parent():
			pos.get_parent().remove_场上(pos)
		cards_pos["场上"].append(pos)
		add_child(pos)
		return true
	
	func remove_场上(pos:Card_pos_sys) -> bool:
		if !cards_pos["场上"].has(pos):
			return false
		cards_pos["场上"].erase(pos)
		remove_child(pos)
		return true

	func add_buff(buff:Buff_sys) -> void:
		assert(!buffs.has(buff))
		buffs.append(buff)
		add_child(buff)
		
	func remove_buff(buff:Buff_sys) -> void:
		buffs.erase(buff)
		buff.free_self()
		
	func get_all_cards() -> Array[Card_sys]:
		var ret:Array[Card_sys]
		for i:String in cards_pos:
			if i == "场上":
				for i1:Card_pos_sys in cards_pos[i]:
					ret.append_array(i1.cards)
			elif i == "源区":
				pass
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
		if value is Dictionary or value is Array:
			value = value.duplicate(true)
		
		if key in ["speed"]:
			for arr:Array in 数据改变[key]:
				if arr[0] == "加":
					value += arr[1]
				elif arr[0] == "减":
					value -= arr[1]
				elif arr[0] == "等":
					value = arr[1]
		elif key in ["att_mode", "state", "卡名无效"]:
			for arr:Array in 数据改变[key]:
				if arr[0] == "加":
					value.append_array(arr[1])
				elif arr[0] == "减":
					for i in arr[1]:
						value.erase(i)
				elif arr[0] == "等":
					value = arr[1].duplicate(true)
		
		if key in ["state"]:
			value.append_array(信息state)
		
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

	func set_state(sta:String) -> void:
		state = [sta]
		event_bus.push_event("战斗_请求检查行动冲突", [self])

	func reset_卡名无效() -> void:
		var cards:Array[Card_sys] = cards_pos["红区"].cards
		var ret:Array
		for card in cards:
			if card.appear >= 1:
				if !ret.has(card.nam):
					ret.append(card.nam)
		卡名无效 = ret

	func remove_data_sys(data_sys:Data_sys) -> void:
		if data_sys is Buff_sys:
			buffs.erase(data_sys)


class Card_pos_sys extends Data_sys:
	var cards:Array[Card_sys]
	
	func _init(pos:String) -> void:
		_set_index()
		nam = pos
		
		event_bus.push_event("战斗_datasys被创建", [self])
		
	func add_card(card:Card_sys, is_插入:bool = false) -> void:
		if is_插入:
			cards.append(card)
		else:
			if nam in ["手牌", "白区"]:
				cards.append(card)
			else :
				cards.insert(0, card)
				
		card.pos = nam
		card.his_pos.append(card.pos)
		add_child(card)
		
		#红区组无效
		if nam == "红区":
			get_parent().reset_卡名无效()
		
		card.reset_appear()
		
		if get_parent():
			card.所属life = get_parent()
		
		
	
	
	
	
	func move_card(card:Card_sys, ind:int) -> bool:
		if !cards.has(card):
			return false
		
		move_child(card, ind)
		
		cards.erase(card)
		if ind <= cards.size():
			cards.insert(ind, card)
		else :
			cards.append(card)
		
		
		return true
	
	
	func remove_card(card:Card_sys) -> void:
		cards.erase(card)
		remove_child(card)


class Pos_cs_sys extends Card_pos_sys:
	var glo_x:int
	var x:int
	var y:int
	var appear:int = -1
	var 流区:Pos_y_sys
	
	func _init(pos:String) -> void:
		_set_index()
		nam = pos
		
		event_bus.push_event("战斗_datasys被创建", [self])
		
	func add_card(card:Card_sys, is_插入:bool = false) -> void:
		if is_插入:
			cards.append(card)
		else:
			cards.insert(0, card)
		
		
		card.pos = nam + str(glo_x) + str(y)
		card.his_pos.append(card.pos)
		add_child(card)
		
		reset_life_and_appear()
		
		if get_parent():
			card.所属life = get_parent()
	
	func reset_life_and_appear() -> void:
		for i in cards:
			i.reset_appear()
		
		if len(cards) == 0:
			appear = -1
			if get_parent():
				get_parent().remove_场上(self)
			return
		var card:Card_sys = cards[0]
		if card.appear >= 3:
			appear = 4
		else:
			appear = card.appear
		assert(appear in [-1,0,2,4])
		
		if appear == 2:
			pass
		if appear != -1 and card.get_所属life():
			if card.get_所属life() != get_parent():
				card.get_所属life().add_场上(self)
			return
		if get_parent():
			get_parent().remove_场上(self)
	
	func move_card(card:Card_sys, ind:int) -> bool:
		if !cards.has(card):
			return false
		
		move_child(card, ind)
		
		cards.erase(card)
		if ind <= cards.size():
			cards.insert(ind, card)
		else :
			cards.append(card)
		
		reset_life_and_appear()
		
		return true
	
	func remove_card(card:Card_sys) -> void:
		cards.erase(card)
		remove_child(card)
		
		reset_life_and_appear()
	
	func get_流() -> int:
		return 流区.正流 - 流区.反流 + len(流区.正流cards) - len(流区.反流cards)
	
	func add_源(card:Card_sys, is_正:bool) -> void:
		流区.add_源(card, is_正)


class Pos_y_sys extends Card_pos_sys:
	var 正流cards:Array[Card_sys]
	var 反流cards:Array[Card_sys]
	var 正流:int
	var 反流:int
	
	func add_源(card:Card_sys, is_正:bool) -> void:
		card.remove_self()
		add_card(card)
		card.作为源时的所属 = self
		
		if is_正:
			正流cards.append(card)
		else:
			反流cards.append(card)
		
	
	func remove_源(card:Card_sys) -> void:
		card.作为源时的所属 = null
		remove_card(card)
		正流cards.erase(card)
		正流cards.erase(card)


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
	var test:int
	var pos:String
	var 所属life:Life_sys
	var 作为源时的所属:Data_sys
	var his_pos:Array
	var 数据改变:Dictionary = {"卡名":[], "种类":[], "sp":[], "mp":[], "特征":[], "组":[]}
	var 信息特征:Array = []
	var 活性源:Array
	var 惰性源:Array
	
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
			if pos.cards.find(self) in [0]:
				if direction == 0:
					appear = 2
				else:
					appear = 4
			elif pos.cards.find(self) in [1] and direction != pos.cards[0].direction:
				if direction == 0:
					appear = 2
				else:
					appear = 4
			else :
				appear = 1
		elif pos.nam == "源区":
			appear == 1
		elif pos.nam == "行动":
			appear = 4
		elif pos.nam == "临时":
			appear == 1
		else:
			appear = 3
		if !is_inside_tree():
			await tree_entered
		buff系统.add_触发与固有buff(self)
		
		return appear

	func face_down() -> void:
		if !appear:
			return
		
		数据改变 = {"卡名":[], "种类":[], "sp":[], "mp":[], "特征":[], "组":[]}
		信息特征 = []
		
		data = null
		for i in effects:
			i.free_self()
		effects = []
		
		appear = 0

	func add_源(card:Card_sys) -> void:
		card.remove_self()
		get_所属life().cards_pos["源区"].add_card(card)
		card.作为源时的所属 = self
		if card.appear == 0:
			惰性源.append(card)
		else:
			活性源.append(card)
		
	
	func remove_源(card:Card_sys) -> void:
		card.作为源时的所属 = null
		card.get_parent().remove_card(card)
		活性源.erase(card)
		惰性源.erase(card)
	
	func get_源(is_活性) -> Array:
		if is_活性:
			return 活性源.duplicate(true)
		else:
			return 惰性源.duplicate(true)
	
	func remove_self() -> void:
		if 作为源时的所属:
			作为源时的所属.remove_源(self)
		else:
			get_parent().remove_card(self)
	
	
	func get_value(key:String):
		if !appear:
			return
		var is_显示卡名:bool = false
		if key == "显示卡名":
			is_显示卡名 = true
			key = "卡名"
		elif key == "有效卡名":
			key = "卡名"
		
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
					value = arr[1].duplicate(true)
		elif key in ["卡名"]:
			value = value.split()
			if !is_显示卡名:
				while value.has("·"):
					value.eraes("·")
			for arr:Array in 数据改变[key]:
				if arr[0] == "加":
					value.append_array(arr[1])
				elif arr[0] == "减":
					for i in arr[1]:
						value.erase(i)
				elif arr[0] == "等":
					value = arr[1].duplicate(true)
			value = "".join(value)
		elif key in ["种类"]:
			for arr:Array in 数据改变[key]:
				value = arr[1]
		
		if key in ["特征"]:
			value.append_array(信息特征)
		
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
			if erase:
				数据改变[key].erase(erase)
				return key
		return ""
	
	func add_信息特征(s:String) -> void:
		信息特征.append(s)
	
	func remove_信息特征(s:String) -> void:
		信息特征.erase(s)
	
	func is_无效() -> bool:
		if appear == 0:
			return false
		if pos == "红区":
			return false
		
		if get_value("特征").has("无效"):
			return true
		
		var arr:Array = get_所属life().get_value("卡名无效")
		if arr.has(nam):
			return true
		
		return false
	
	func get_所属life() -> Life_sys:
		return 所属life
	
	func get_own() -> Life_sys:
		if appear:
			return own
		else :
			return get_所属life()


class Buff_sys extends Data_sys:
	var buff系统: Node
	var effect:Effect_sys
	var 触发:Effect_sys
	var card:Card_sys#这个buff依赖的卡牌
	var targets:Array = [null, null, null, null, null, null, null, null, null, null]
	var 影响:Array
	
	func _init(buff_name, def, car:Card_sys = null) -> void:
		_set_index()
		buff系统 = def
		if buff_name:
			data = DatatableLoader.get_data_model("buff_data", buff_name)
			nam = buff_name
			影响 = data.影响
			if data["效果"]:
				effect = Effect_sys.new(data["效果"][0], buff系统)
				add_child(effect)
		
		card = car
		
		event_bus.push_event("战斗_datasys被创建", [self])
		
	func remove_data_sys(data_sys) -> void:
		if data_sys == card:
			free_self()


class Equip_sys extends Data_sys:
	func _init(equip_name) -> void:
		_set_index()
		if equip_name:
			data = DatatableLoader.get_data_model("equip_data", equip_name)
		event_bus.push_event("战斗_datasys被创建", [self])
