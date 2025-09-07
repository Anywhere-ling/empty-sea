extends Node
class_name 战斗_效果处理系统

signal 数据返回


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus
var 场地行数:int = C0nfig.场地行数

var targets:Array = []
#[0:这个效果/buff的依赖/对象卡牌
#1:拥有这次效果/buff的单位
#2:触发这次效果的卡牌/效果/事件
#3:buff的数据/
#]

var card_sys:战斗_单位管理系统.Card_sys

var effect:Array
var features:Array = []

var all_lifes:Array

var 最终行动系统: Node
var 单位控制系统: Node
var 发动判断系统: Node
var 卡牌打出与发动系统: Node
var 单位管理系统: 战斗_单位管理系统
var 日志系统: 战斗_日志系统
var 回合系统: Node
var 连锁系统: Node
var buff系统: Node
var 场地系统: Node
var 二级行动系统: Node

func _init(node:Node, eff:Array, lifes:Array, car:战斗_单位管理系统.Card_sys = null, fea:Array = [],  tar:Array = []) -> void:
	最终行动系统 = node.最终行动系统
	单位控制系统 = node.单位控制系统
	发动判断系统 = node.发动判断系统
	卡牌打出与发动系统 = node.卡牌打出与发动系统
	单位管理系统 = node.单位管理系统
	日志系统 = node.日志系统
	回合系统 = node.回合系统
	连锁系统 = node.连锁系统
	buff系统 = node.buff系统
	场地系统 = node.场地系统
	二级行动系统 = node.二级行动系统
	
	effect = eff
	all_lifes = lifes
	card_sys = car
	features = fea
	targets = tar

	targets.resize(10)


func start() -> Array:
	if await _effect_process(effect):
		return targets
	else :
		return []

func _effect_process(p_effect:Array) -> bool:
	for i:int in len(p_effect):
		if card_sys and card_sys.is_无效():
			await 最终行动系统.无效(card_sys.get_所属life(), card_sys)
			return false
		
		var arr:Array = p_effect[i].duplicate(true)
		if arr[0] in effect标点:
			var eff_nam:String = arr.pop_at(0)
			if !await effect标点[eff_nam].call(arr):
				
				日志系统.callv("录入信息", ["战斗_效果处理系统", eff_nam, [arr, targets], false])
				return false
		
		elif arr[0] in effect组件:
			var eff_nam:String = arr.pop_at(0)
			if !await effect组件[eff_nam].call(arr):
				
				日志系统.callv("录入信息", ["战斗_效果处理系统", eff_nam, [arr, targets], false])
				return false

	
	return true



var effect标点:Dictionary ={
	"逐一":_逐一,
	"否定":_否定,
	"如果":_如果,
	"否则":_否则,
}

var effect组件:Dictionary = {
	"改变主视角":_改变主视角,
	"初始对象":_初始对象,
	"初始区":_初始区,
	"以全局数据为对象":_以全局数据为对象,
	"以数据为对象":_以数据为对象,
	"以单位数据为对象":_以单位数据为对象,
	"以单位为对象":_以单位为对象,
	"以区为对象":_以区为对象,
	"以序号为对象":_以序号为对象,
	"以场上为对象":_以场上为对象,
	"直接存入":_直接存入,
	
	"对象处理":_对象处理,
	"数据判断":_数据判断,
	"计算数量":_计算数量,
	"计算相似度":_计算相似度,
	"效果判断":_效果判断,
	"条件卡牌筛选":_条件卡牌筛选,
	"非条件卡牌筛选":_非条件卡牌筛选,
	"格筛选":_格筛选,
	"合成检测":_合成检测,
	
	"线段取格":_线段取格,
	"两点取角":_两点取角,
	"方形取格":_方形取格,
	"视角化":_视角化,
	
	"取卡牌对象":_取卡牌对象,
	"取格对象":_取格对象,
	
	"加入":_加入,
	"破坏":_破坏,
	"反转":_反转,
	"改变方向":_改变方向,
	"盖放":_盖放,
	"释放":_释放,
	"创造":_创造,
	"填入":_填入,
	"去除":_去除,
	"插入":_插入,
	"改变可视数据":_改变可视数据,
	"改变单位可视数据":_改变单位可视数据,
	"删除可视数据改变":_删除可视数据改变,
	"阻止":_阻止,
	"合成":_合成,
	"移动":_移动,
	"构造":_构造,
	"行动打出":_行动打出,
	
	"添加buff":_添加buff,
}



func _get_array(a) -> Array:
	if !a:
		return []
	if a is Array:
		return a
	return [a]

func _get_array0(a):
	a = _get_array(a)
	return a[0]

func _get_array_sub(a) -> Array:
	if _get_sub_index(a) == -1:
		return []
	a = targets[_get_sub_index(a)]
	
	if !a:
		return []
	if a is Array:
		return a
	return [a]

func _get_array0_sub(a):
	a = _get_array_sub(a)
	if !a:
		return
	return a[0]

func _get_sub_index(sub:String) -> int:
	if sub.find("对象") == -1:
		return -1
	return int(sub.erase(0, 2))

func _get_cards(sub:String) -> Array:
	var data0 = _get_array_sub(sub).duplicate(true)
	if !data0:
		return []
	for i in data0:
		if !i is 战斗_单位管理系统.Card_sys:
			return []
	return data0

func _get_poss(sub:String) -> Array:
	var data0 = _get_array_sub(sub).duplicate(true)
	if !data0:
		return []
	for i in data0:
		if !i is 战斗_单位管理系统.Card_pos_sys:
			return []
	return data0

func _get_bool(sub:String) -> bool:
	if sub == "是":
		return true
	else:
		return false

func _has_element(arr, target) -> bool:
	for item in arr:
		if item == target:  # 找到目标元素
			return true
		elif item is Array:  # 如果是子数组，递归检查
			if _has_element(item, target):
				return true
	return false  # 遍历完未找到



func _gett(sub:String, arr:bool = false, 直接:bool = false, cla = null):
	var arr1:Array = _get_array_sub(sub)
	while arr1.has(null):
		arr1.erase(null)
	
	arr1 = arr1.duplicate(true)
	
	if cla:
		for i in arr1:
			assert(is_instance_of(i, cla), "类型不符")
	
	if arr1:
		if arr:
			return arr1
		else :
			return arr1[0]
	else :
		if 直接:
			if arr:
				return [sub]
			else :
				return sub
		else :
			if arr:
				return []
			else:
				return 



#func _(data:Array) -> bool:return true

func _逐一(data:Array) -> bool:
	var index:String = data[0]
	var data0 = _gett(data[0], true)
	
	
	if !data0:
		return false
	
	data.remove_at(0)
	var ret:bool = false
	
	for i in data0:
		targets[_get_sub_index(index)] = i
		if await  _effect_process(data):
			ret = true
	
	targets[_get_sub_index(index)] = data0
	
	return ret

func _否定(data:Array) -> bool:
	var ret:bool = true
	
	if await  _effect_process(data):
		ret = false
	
	return ret

func _如果(data:Array) -> bool:
	var 进入否则:bool = false
	
	for i in data:
		if 进入否则:
			if i is Array and i[0] == "否则":
				i.pop_at(0)
				await _effect_process(i)
		else:
			if i is Array and i[0] == "否则":
				continue
			if !await _effect_process([i]):
				进入否则 = true
	
	
	return true

func _否则(data:Array) -> bool:
	return true


func _改变主视角(data:Array) -> bool:
	var poss:Array = []
	var data0 = _gett(data[0], false, true)
	
	if data0 == "攻击目标" and !targets[1].att_life:
		return false
	match data0 :
		"攻击目标":data0 = [targets[1].att_life]
		"自己":data0 = [targets[1]]
		"对面":data0 = [targets[1].face_life]
		"敌人":data0 = all_lifes[int(all_lifes[0].has(targets[1]))]
		"友方":data0 = all_lifes[int(!all_lifes[0].has(targets[1]))]
		"全部":data0 = all_lifes[0] + all_lifes[1]
	
	
	targets[1] = data0
	
	return true

func _初始区(data:Array) -> bool:
	var poss:Array = []
	var data0:Array
	for i in data[0]:
		i = _gett(i, true, true, TYPE_STRING)
		if i:
			data0.append_array(i)
	var data1:Array = _gett(data[1], true, true)
	if !data1:
		return false
	
	#目标单位
	var lifes:Array = []
	if !data1[0] is String:
		lifes = data1
	else:
		if data1[0] == "攻击目标" and !targets[1].att_life:
			return false
			
		match data1[0] :
			"攻击目标":lifes.append_array([targets[1].att_life])
			"自己":lifes.append_array([targets[1]])
			"敌人":lifes.append_array(all_lifes[int(all_lifes[0].has(targets[1]))])
			"友方":lifes.append_array(all_lifes[int(!all_lifes[0].has(targets[1]))])
			"全部":lifes.append_array(all_lifes[0] + all_lifes[1])
		
	for life:战斗_单位管理系统.Life_sys in lifes:
		for pos:String in data0:
			if pos == "场上":
				for i in life.cards_pos[pos]:
					poss.append(i)
			else :
				poss.append(life.cards_pos[pos])
	
	#对象
	targets[_get_sub_index(data[2])] = poss
	
	return true

func _初始对象(data:Array) -> bool:
	var cards:Array = []
	
	#目标单位
	var poss:Array = _gett(data[0], true, false, 战斗_单位管理系统.Card_pos_sys)
	
	
	for pos:战斗_单位管理系统.Card_pos_sys in poss:
		cards.append_array(pos.cards)
	
	#对象
	
	targets[_get_sub_index(data[1])] = cards
	
	return true

func _以全局数据为对象(data:Array) -> bool:
	#提取数据
	
	var ret
	if data[0] == "连锁状态":
		ret = 连锁系统.chain_state
	elif data[0] == "回合阶段":
		ret = 回合系统.period
	elif data[0] == "回合单位":
		ret = 回合系统.current_life
	elif data[0] == "回合数":
		ret = 回合系统.turn
	
	if ret == null:
		return false
	targets[_get_sub_index(data[1])] = ret
		
	
	return true

func _以数据为对象(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], false, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	
	var ret
	#任意显示
	if data[1] == "位置":
		ret = data0.pos
	elif data[1] == "显现":
		ret = str(data0.appear)
	elif data[1] == "方向":
		ret = str(data0.direction)
	elif data[1] == "上一位置":
		if len(data0.his_pos) >= 2:
			ret = data0.his_pos[-2]
		else:
			return false
	#表侧
	else :
		if !data0.appear:
			pass
		elif data[1] == "构造状态":
			ret = str(data0.state)
		elif data[1] == "源数量":
			ret = str(len(data0.get_源(true) + data0.get_源(false)))
		elif data[1] == "活性源数量":
			ret = str(len(data0.get_源(true)))
		else :
			ret = data0.get_value(data[1])
			if data[1] in ["sp", "mp"]:
				ret = str(ret)
	
	if ret == null:
		return false
	targets[_get_sub_index(data[2])] = ret
		
	
	return true

func _以单位数据为对象(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], false, false, 战斗_单位管理系统.Life_sys)
	if !data0:
		return false
	
	
	var ret
	#任意显示
	if data[1] in ["speed", "state", "mode", "卡名无效"]:
		ret = data0.get_value(data[1])
	
	if ret == null:
		return false
	targets[_get_sub_index(data[2])] = ret
		
	
	return true

func _以单位为对象(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], false, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	var ret = data0.get_所属life()
	if !ret:
		return false
	
	targets[_get_sub_index(data[1])] = ret
	
	return true

func _以区为对象(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], false, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	var ret
	var pos:战斗_单位管理系统.Card_pos_sys = data0.get_parent()
	if pos.name == "临时":
		ret = []
	else :
		ret = pos
	targets[_get_sub_index(data[1])] = ret
	
	return true

func _以序号为对象(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], false, false, 战斗_单位管理系统.Card_pos_sys)
	if !data0:
		return false
	
	if data0.name != "场上":
		return false
	
	var glo_x:int = data0.glo_x
	var y:int = data0.y
	
	targets[_get_sub_index(data[1])] = glo_x
	targets[_get_sub_index(data[2])] = y
	
	return true

func _以场上为对象(data:Array) -> bool:
	#提取数据
	var data0 = int(_gett(data[0], false, true))
	var data1 = int(_gett(data[1], false, true))
	
	if !data0 or !data1:
		return false
	if data0 <1 or data0 >5 or data1 <1 or data1 > 场地行数:
		return false
	
	
	targets[_get_sub_index(data[3])] = 场地系统.get_场上(data0, data1)
	
	return true

func _直接存入(data:Array) -> bool:
	#提取数据
	var data0 = data[0]
	
	data0 = JSON.parse_string(data0)
	if !data0 is Array:
		return false
	
	targets[_get_sub_index(data[1])] = data0
	
	return true



func _对象处理(data:Array) -> bool:
	var data0 = targets[_get_sub_index(data[0])]
	var data2 = data[2]
	if _get_sub_index(data[2]) != -1:
		data2 = targets[_get_sub_index(data[2])]
	
	if data[1] == "重设":
		if data2:
			targets[_get_sub_index(data[0])] = data2
		else :
			targets[_get_sub_index(data[0])] = null
		return true
	
	elif !data0:
		if data[1] in ["复制或乘算"]:
			data0 = data2
		if data[1] in ["加"]:
			if data2 is String and data2.is_valid_float():
				data0 = data2
			else :
				data0 = [data2]
		elif data[1] == "减":
			return false
	
	elif data0 is String and data0.is_valid_float():
		assert(data2.is_valid_float())
		data0 = float(data0)
		if data[1] == "加":
			data0 += float(data2)
		elif data[1] == "减":
			data0 -= float(data2)
		elif data[1] == "复制或乘算":
			data0 = data0 * float(data2)
		data0 = str(data0)
	
	elif data0 is String:
		if !data0 is String:
			return false
		if data[1] == "加":
			data0 += data2
		elif data[1] == "减":
			for i in data2:
				data0.erase(data0.find(i))
		elif data[1] == "复制或乘算":
			data0 = data2
	
	else :
		data0 = _get_array(data0)
		data2 = _get_array(data2)
		if data[1] == "加":
			data0.append_array(data2)
		elif data[1] == "减":
			for i in data2:
				data0.erase(i)
		elif data[1] == "复制或乘算":
			for i in data0.duplicate(true):
				data0.erase(i)
			data0.append_array(data2)
	
	targets[_get_sub_index(data[0])] = data0
	return true

func _数据判断(data:Array) -> bool:
	#提取数据
	var data0 = targets[_get_sub_index(data[0])]
	if !data0:
		return false
	var data2
	if !data[2].is_valid_float() and _get_sub_index(data[2]) != -1:
		data2 = targets[_get_sub_index(data[2])]
	else :
		data2 = data[2]
	
	
	#判断
	if data0 is String and data0.is_valid_float():
		assert(data2 is String and data2.is_valid_float(), "类型不符")
		data0 = int(data0)
		data2 = int(data2)
	elif data0 is String:
		assert(data2 is String, "类型不符")
	else:
		data0 = _get_array(data0)
		data2 = _get_array(data2)
		assert(data2 is Array or typeof(data0[0]) == typeof(data2), "类型不符")
		
	if data[1] == "相等":
		if data0 is int:
			return data0 == data2
		elif data0 is String:
			return data0 == data2
		elif data0 is Array:
			return data0 == data2
	
	elif data[1] == "包含":
		if data0 is int:
			return data0 >= data2
		elif data0 is String:
			return !data0.find(data2) == -1
		elif data0 is Array:
			if data2 is Array:
				return data2.all(func(a):return data0.has(a))
			else:
				return data0.has(data2)
	
	elif data[1] == "被包含":
		if data0 is int:
			return data0 <= data2
		elif data0 is String:
			return !data2.find(data0) == -1
		elif data0 is Array:
			return data0.all(func(a):return data2.has(a))
		
	
	
	return false

func _计算数量(data:Array) -> bool:
	#提取数据
	var data0 = targets[_get_sub_index(data[0])]
	if data0 == null:
		return false
	if !data0 is Array and !data0 is String:
		return false
	
	targets[_get_sub_index(data[1])] = str(len(data0))
	return true

func _计算相似度(data:Array) -> bool:
	#提取
	var data0 = targets[_get_sub_index(data[0])]
	var data1 = _gett(data[2], false, true)
	
	if data0 is String:
		#判断
		assert(data1 is String, "类型不符")
		#分割
		data0 = data0.split()
		data1 = data1.split()
	elif data0 is Array:
		assert(data1 is Array, "类型不符")
		data0 = data0.duplicate(true)
		data1 = data1.duplicate(true)
	
	
	var o_count:int = len(data1)
	
	for i in data0:
		data1.erase(i)
	
	targets[_get_sub_index(data[0])] = o_count - len(data1)
	
	return true

func _效果判断(data:Array) -> bool:
	#提取
	var data0 = targets[_get_sub_index(data[0])].duplicate(true)
	if !data0 is Array:
		return false
	
	if !_has_element(data0, data[1]):
		return false
	
	return true

func _条件卡牌筛选(data:Array) -> bool:
	#提取
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	var data1:String = data[1]
	var data2:String = data[2]
	var o_data3
	if !data[3].is_valid_float() and _get_sub_index(data[3]) != -1:
		o_data3 = targets[_get_sub_index(data[3])]
	else :
		o_data3 = data[3]
	
	
	var ret:Array
	for i:战斗_单位管理系统.Card_sys in data0:
		var data3 = o_data3
		if data3 is Array:
			data3 = data3.duplicate(true)
		
		var 数据
		#任意显示
		if data[1] == "位置":
			数据 = i.pos
		elif data[1] == "显现":
			数据 = str(i.appear)
		elif data[1] == "方向":
			数据 = str(i.direction)
		elif data[1] == "上一位置":
			if len(i.his_pos) >= 2:
				数据 = i.his_pos[-2]
			else:
				continue
				
		#表侧
		else :
			if !i.appear:
				pass
			elif data[1] == "构造状态":
				数据 = str(i.state)
			elif data[1] == "源数量":
				数据 = str(len(i.get_源(true) + i.get_源(false)))
			elif data[1] == "活性源数量":
				数据 = str(len(i.get_源(true)))
			else :
				数据 = i.get_value(data[1])
				if data[1] in ["sp", "mp"]:
					数据 = str(数据)
		
		
		var 判断:bool = false
		if 数据 is String and 数据.is_valid_float():
			assert(data3 is String and data3.is_valid_float(), "类型不符")
			数据 = int(数据)
			data3 = int(data3)
		elif 数据 is String:
			assert(data3 is String, "类型不符")
		else:
			数据 = _get_array(数据)
			data3 = _get_array(data3)
			assert(data3 is Array or typeof(数据[0]) == typeof(data3), "类型不符")
			
		if data2 == "相等":
			if 数据 is int:
				判断 = 数据 == data3
			elif 数据 is String:
				判断 = 数据 == data3
			elif 数据 is Array:
				判断 = 数据 == data3
		
		elif data2 == "包含":
			if 数据 is int:
				判断 = 数据 >= data3
			elif 数据 is String:
				判断 = !数据.find(data3) == -1
			elif 数据 is Array:
				if data3 is Array:
					判断 = data3.all(func(a):return 数据.has(a))
				else:
					判断 = 数据.has(data3)
		
		elif data2 == "被包含":
			if 数据 is int:
				判断 = 数据 <= data3
			elif 数据 is String:
				判断 = !data3.find(数据) == -1
			elif 数据 is Array:
				判断 = 数据.all(func(a):return data3.has(a))
		
		if 判断:
			ret.append(i)
	
	
	targets[_get_sub_index(data[0])] = ret
	
	return true

func _非条件卡牌筛选(data:Array) -> bool:
	#提取
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	var data1:String = data[1]
	var data2:int = int(_gett(data[2], false, true))
	
	if data2 > data0.size():
		targets[_get_sub_index(data[0])] = data0
		return true
	
	var ret:Array
	if data1 == "随机":
		data0.shuffle()
	elif data1 == "倒序":
		data0.reverse()
	
	for i in data2:
		ret.append(data0[i])
	
	targets[_get_sub_index(data[0])] = ret
	
	return true

func _格筛选(data:Array) -> bool:
	#提取
	var data0:Array
	for i in _gett(data[0], true, false, 战斗_单位管理系统.Card_pos_sys):
		if i.nam == "场上":
			data0.append(i)
	if !data0:
		return false
	var data1:Array
	for i in data[1]:
		data1.append(int(i))
	
	
	var ret:Array = 场地系统.get_按appear筛选格(data0, data1)
	
	
	targets[_get_sub_index(data[0])] = ret
	
	return true

func _合成检测(data:Array) -> bool:
	#提取
	var life:战斗_单位管理系统.Life_sys = targets[1]
	var 蓝区cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.cards_pos["蓝区"].cards, 3)
	var 场上cards:Array[战斗_单位管理系统.Card_sys]
	for pos in life.cards_pos["场上"]:
		if pos.cards:
			场上cards.append(pos.cards[0])
	场上cards = 单位管理系统.get_给定显示以上的卡牌(场上cards, 2)
	var 手牌cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.cards_pos["手牌"].cards, 3)
	
	var data0:Array
	for i in data[0]:
		if _get_sub_index(i) != -1:
			data0.append_array(_gett(i, true, false, 战斗_单位管理系统.Card_sys))
		else :
			data0.append_array(蓝区cards)
			data0.append_array(手牌cards)
	var data1:Array
	for i in data[1]:
		if _get_sub_index(i) != -1:
			data1.append_array(_gett(i, true, false, 战斗_单位管理系统.Card_sys))
		else :
			data1.append_array(蓝区cards)
			data1.append_array(场上cards)
	var data2:Array
	for i in data[2]:
		if _get_sub_index(i) != -1:
			data2.append_array(_gett(i, true, false, 战斗_单位管理系统.Card_sys))
		else :
			data2.append_array(蓝区cards)
			data2.append_array(场上cards)
	
	
	if !发动判断系统.合成构造判断(life, data0, data1, data2):
		return false
	
	
	return true



func _线段取格(data:Array) -> bool:
	#提取
	var data0 = _gett(data[0], false, false)
	if !data0:
		return false
	if data0 is 战斗_单位管理系统.Card_sys:
		data0 = data0.get_parent()
	if data0.nam != "场上":
		return false
	
	var data1:float = float(_gett(data[1], false, true))
	var data2:float = float(_gett(data[2], false, true))
	var data3:float = float(_gett(data[3], false, true))
	
	
	var arr_ind:Array = 场地系统.线段取格(Vector2(data0.glo_x, data0.y), data1, data2, data3)
	var ret:Array
	for i in arr_ind:
		ret.append(场地系统.get_场上(i.x, i.y))
	
	
	targets[_get_sub_index(data[4])] = ret
	
	return true

func _两点取角(data:Array) -> bool:
	#提取
	var data0 = _gett(data[0], false, false)
	if !data0:
		return false
	if data0 is 战斗_单位管理系统.Card_sys:
		data0 = data0.get_parent()
	if data0.nam != "场上":
		return false
	
	var data1 = _gett(data[1], false, false)
	if !data1:
		return false
	if data1 is 战斗_单位管理系统.Card_sys:
		data1 = data1.get_parent()
	if data1.nam != "场上":
		return false
	
	var ret:float = 场地系统.两点取角(Vector2(data0.glo_x, data0.y), Vector2(data1.glo_x, data1.y))
	
	targets[_get_sub_index(data[2])] = ret
	
	return true

func _方形取格(data:Array) -> bool:
	#提取
	var data0 = _gett(data[0], false, false)
	if !data0:
		return false
	if data0 is 战斗_单位管理系统.Card_sys:
		data0 = data0.get_parent()
	if data0.nam != "场上":
		return false
	
	var data1:int = int(_gett(data[1], false, true))
	var data2:int = int(_gett(data[2], false, true))
	
	var arr_ind:Array = 场地系统.方形取格(Vector2(data0.glo_x, data0.y), data1, data2)
	var ret:Array
	for i in arr_ind:
		ret.append(场地系统.get_场上(i.x, i.y))
	
	targets[_get_sub_index(data[3])] = ret
	
	return true

func _视角化(data:Array) -> bool:
	#提取
	var data0 = _gett(data[0], false, false)
	if !data0:
		return false
	if data0 is 战斗_单位管理系统.Card_sys:
		data0 = data0.get_parent()
	if data0.nam != "场上":
		return false
	
	var data1:Array = _gett(data[1], true, false, 战斗_单位管理系统.Card_pos_sys)
	
	var mode:Array
	if data0.get_parent():
		if data0.get_parent().is_positive:
			mode.append("正")
		else:
			mode.append("反")
	else:
		if data0.glo_x >= 3:
			mode.append("反")
		if data0.glo_x <= 3:
			mode.append("正")
	
	var arr_ind:Array
	for i in data1:
		arr_ind.append_array(场地系统.视角化(Vector2(data0.glo_x, data0.y), mode, Vector2(i.glo_x, i.y)))
	
	
	var ret:Array
	for i in arr_ind:
		ret.append(场地系统.get_场上(i.x, i.y))
		
	targets[_get_sub_index(data[2])] = ret
	
	return true



func _取卡牌对象(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	
	if data0 == []:
		return false
	
	var 最小数量:int = int(_gett(data[3], false, true))
	var 最大数量:int = int(_gett(data[2], false, true))
	var 描述:String = data[1]
	if 最大数量 < 1:
		最大数量 = len(data0)
	if 最小数量 < 0:
		最小数量 = 最大数量
	assert(最大数量 > -1, "卡牌data数据错误")
	
	if len(data0) < 最小数量:
		return false
	
	for card in data0:
		var life = card.get_所属life()
		await buff系统.单位与全部buff判断("可被取为对象", [card, null, card_sys, data0])
	
	var ret:Array = await 单位控制系统.请求选择(targets[1], 描述, data0, 最大数量, 最小数量)
	
	for card in ret:
		var life = card.get_所属life()
		await buff系统.单位与全部buff判断("被取为对象", [card, null, card_sys, ret])
	
	
	
	if !ret:
		return false
	targets[_get_sub_index(data[0])] = ret
	
	return true

func _取格对象(data:Array) -> bool:
	#提取数据
	var data0:Array
	for i in _gett(data[0], true, false, 战斗_单位管理系统.Card_pos_sys):
		if i.nam == "场上":
			data0.append(i)
	
	if data0 == []:
		return false
	
	var 最小数量:int = int(_gett(data[3], false, true))
	var 最大数量:int = int(_gett(data[2], false, true))
	var 描述:String = data[1]
	if 最小数量 == -1:
		最小数量 = 最大数量
	assert(最大数量 > -1, "卡牌data数据错误")
	
	if len(data0) < 最小数量:
		return false
	
	var ret:Array = await 单位控制系统.请求选择多格(targets[1], 描述, data0, 最大数量, 最小数量)
	
	if ret == []:
		return false
	targets[_get_sub_index(data[0])] = ret
	
	return true



func _加入(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	var pos:战斗_单位管理系统.Card_pos_sys = _gett(data[1], false, false, 战斗_单位管理系统.Card_pos_sys)
	if !pos:
		return false
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		if !await 二级行动系统.加入(i.get_所属life(), i, pos):
			ret = false
	
	await 最终行动系统.等待动画完成()
	return ret

func _破坏(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	var ret:bool = true
	for card:战斗_单位管理系统.Card_sys in data0:
		if card.get_value("特征").has("永恒"):
			continue
		
		var pos:战斗_单位管理系统.Card_pos_sys = card.get_parent()
		var life:战斗_单位管理系统.Life_sys = pos.get_parent()
		if !await 二级行动系统.破坏(card.get_所属life(), card):
			ret = false
		
		
		if pos.nam == "场上":
			var cards1:Array = []
			for i in pos.cards:
					cards1.append(i)
			
			for i:战斗_单位管理系统.Card_sys in cards1:
				if i.get_value("特征").has("永恒"):
					continue
				
				var life1:战斗_单位管理系统.Life_sys = i.get_所属life()
				await 二级行动系统.加入(life1, i, life1.cards_pos["绿区"])
	
	
	
	await 最终行动系统.等待动画完成()
	return ret

func _反转(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		if !await 最终行动系统.反转(i.get_所属life(), i):
			ret = false
	
	await 最终行动系统.等待动画完成()
	return ret

func _改变方向(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		if !await 最终行动系统.改变方向(i.get_所属life(), i):
			ret = false
	
	await 最终行动系统.等待动画完成()
	return ret

func _盖放(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	var data1 = _gett(data[0], true, false, 战斗_单位管理系统.Card_pos_sys)
	if !data0:
		return false
	
	if !data1:
		return false
	var pos:战斗_单位管理系统.Card_pos_sys = data1[0]
	
	var ret:bool = true
	
	for card:战斗_单位管理系统.Card_sys in data0:
		if card.appear:
			if !await 最终行动系统.反转(card.get_所属life(), card):
				ret = false
				continue
		
		if !await 二级行动系统.加入(card.get_所属life(), card, pos):
			ret = false
			continue
		
		if card.direction:
			if !await 最终行动系统.改变方向(card.get_所属life(), card):
				ret = false
				continue
	
	await 最终行动系统.等待动画完成()
	return ret

func _释放(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	var ret:bool = true
	for i:int in len(data0):
		if !await 二级行动系统.释放(data0[i].get_所属life(), data0[i]):
			ret = false
	
	
	await 最终行动系统.等待动画完成()
	return ret

func _创造(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], false, true, TYPE_STRING)
	if !data0:
		return false
	var data1 = _gett(data[1], false, true, 战斗_单位管理系统.Life_sys)
	
	var ret = await 最终行动系统.创造(data1, data0)
	
	if !ret:
		return false
	
	targets[_get_sub_index(data[2])] = [ret]
	
	await 最终行动系统.等待动画完成()
	return true

func _填入(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	var data1 = _gett(data[1], false, false, 战斗_单位管理系统.Card_sys)
	if !data1:
		return false
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		if !await 二级行动系统.填入(i.get_所属life(), data1, i):
			ret = false
	
	await 最终行动系统.等待动画完成()
	return ret

func _去除(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	var data1 = data[1]
	var is_活性:bool = false
	if data1 == "活性":
		is_活性 = true
	var data2 = _gett(data[2], false, true)
	if !data2:
		return false
	data2 = int(data2)
	var data3 = _gett(data[3], false, true, TYPE_STRING)
	if !data3:
		data3 = "蓝区"
	
	var cards1:Dictionary
	for card:战斗_单位管理系统.Card_sys in data0:
		for i in card.get_源(is_活性):
			cards1[i] = card
	
	if len(cards1) < int(data[2]):
		if is_活性:
			return false
		else :
			for card:战斗_单位管理系统.Card_sys in data0:
				for i in card.get_源(true):
					cards1[i] = card
			if len(cards1) < int(data[2]):
				return false
	
	var cards2:Dictionary
	for i in int(data[2]):
		var key = cards1.keys()[i]
		cards2[key] = cards1[key]
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in cards2:
		if !await 二级行动系统.去除(i.get_所属life(), cards2[i], i, data3):
			ret = false
	
	if _get_sub_index(data[4]) != -1:
		targets[_get_sub_index(data[4])] = cards2.keys()
	
	await 最终行动系统.等待动画完成()
	return ret

func _插入(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	var pos:战斗_单位管理系统.Card_pos_sys = _gett(data[1], false, false, 战斗_单位管理系统.Card_pos_sys)
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		if !await 二级行动系统.插入(i.get_所属life(), i, pos):
			ret = false
	
	await 最终行动系统.等待动画完成()
	return ret

func _改变可视数据(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	var data1 = data[1]
	var data2 = data[2]
	var data3 = data[3]
	if _get_sub_index(data[3]) != -1:
		data3 = targets[_get_sub_index(data[3])]
	
	var ind:int = 单位管理系统.get_数据改变唯一标识()
	if data1 in ["sp", "mp"]:
		if data3 is Array:
			data3 = data3[0]
		if !data3.is_valid_float():
			return false
		
		for i in data0:
			i.add_value(data1, [data2, int(data3), ind])
	
	elif data1 in ["特征", "组"]:
		data3 = _get_array(data3)
		for i in len(data3):
			data3[i] = str(data3[i])
		
		for i in data0:
			i.add_value(data1, [data2, data3, ind])
	
	elif data1 in ["卡名"]:
		if data3 is Array:
			data3 = data3[0]
		
		for i in data0:
			i.add_value(data1, [data2, data3.split(), ind])
	
	elif data1 in ["种类"]:
		if data3 is Array:
			data3 = data3[0]
		
		for i in data0:
			i.add_value(data1, [data2, data3, ind])
	
	if _get_sub_index(data[4]) != -1:
		targets[_get_sub_index(data[4])] = str(ind)
	
	for i in data0:
		await 最终行动系统.图形化数据改变(i.get_所属life(), i, data1)
	
	await 最终行动系统.等待动画完成()
	return true

func _改变单位可视数据(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Life_sys)
	if !data0:
		return false
	var data1 = data[1]
	var data2 = data[2]
	var data3 = data[3]
	if _get_sub_index(data[3]) != -1:
		data3 = targets[_get_sub_index(data[3])]
	
	if data1 == "mode":
		data1 = "att_mode"
	
	var ind:int = 单位管理系统.get_数据改变唯一标识()
	if data1 in ["speed"]:
		if data3 is Array:
			data3 = data3[0]
		if !data3.is_valid_float():
			return false
		
		for i in data0:
			i.add_value(data1, [data2, int(data3), ind])
	
	elif data1 in ["att_mode", "state", "组无效"]:
		data3 = _get_array(data3)
		for i in len(data3):
			data3[i] = str(data3[i])
		
		for i in data0:
			i.add_value(data1, [data2, data3, ind])
	
	
	if _get_sub_index(data[2]) != -1:
		targets[_get_sub_index(data[2])] = ind
	
	for i in data0:
		await 最终行动系统.单位图形化数据改变(i, data1)
	
	await 最终行动系统.等待动画完成()
	return true

func _删除可视数据改变(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false)
	var data1 = targets[_get_sub_index(data[1])]
	data1 = int(data1)
	
	var key:String
	for i in data0:
		key = i.remove_value(data1)
	
	if key:
		for i in data0:
			await 最终行动系统.图形化数据改变(i.get_所属life(), i, key)
	
	return true

func _阻止(data:Array) -> bool:
	#提取数据
	var data0:Array = _gett(data[0], true, true)
	if !data0:
		return false
	
	#目标单位
	var lifes:Array = []
	if !data0[0] is String:
		lifes = data0
	else:
		if data0[0] == "攻击目标" and !targets[1].att_life:
			return false
			
		match data0[0] :
			"攻击目标":lifes.append_array([targets[1].att_life])
			"自己":lifes.append_array([targets[1]])
			"敌人":lifes.append_array(all_lifes[int(all_lifes[0].has(targets[1]))])
			"友方":lifes.append_array(all_lifes[int(!all_lifes[0].has(targets[1]))])
			"全部":lifes.append_array(all_lifes[0] + all_lifes[1])
		
	for i:战斗_单位管理系统.Life_sys in lifes:
		i.state.append("阻止")
		await 最终行动系统.单位图形化数据改变(i, "state")
	
	return true

func _合成(data:Array) -> bool:
	#提取
	var life:战斗_单位管理系统.Life_sys = targets[1]
	var 蓝区cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.cards_pos["蓝区"].cards, 3)
	var 场上cards:Array[战斗_单位管理系统.Card_sys]
	for pos in life.cards_pos["场上"]:
		if pos.cards:
			场上cards.append(pos.cards[0])
	场上cards = 单位管理系统.get_给定显示以上的卡牌(场上cards, 2)
	var 手牌cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.cards_pos["手牌"].cards, 3)
	
	var data0:Array
	for i in data[0]:
		if _get_sub_index(i) != -1:
			data0.append_array(_gett(i, true, false, 战斗_单位管理系统.Card_sys).duplicate(true))
		else :
			data0.append_array(蓝区cards)
			data0.append_array(手牌cards)
	var data1:Array
	for i in data[1]:
		if _get_sub_index(i) != -1:
			data1.append_array(_gett(i, true, false, 战斗_单位管理系统.Card_sys).duplicate(true))
		else :
			data1.append_array(蓝区cards)
			data1.append_array(场上cards)
	var data2:Array
	for i in data[2]:
		if _get_sub_index(i) != -1:
			data2.append_array(_gett(i, true, false, 战斗_单位管理系统.Card_sys).duplicate(true))
		else :
			data2.append_array(蓝区cards)
			data2.append_array(场上cards)
	
	var cards:Dictionary = 发动判断系统.合成构造判断(life, data0, data1, data2)
	if !cards:
		await 最终行动系统.确认信息("没有可进行的合成")
		return false
	
	if !await 单位控制系统.请求合成(life, cards):
		return false
	
	
	return true

func _移动(data:Array) -> bool:
	var data0 = _gett(data[0], false, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	if data0.appear < 4:
		return false
	
	var pos:战斗_单位管理系统.Card_pos_sys = _gett(data[1], false, false, 战斗_单位管理系统.Card_pos_sys)
	if !pos:
		return false
	
	if pos.nam != "场上" or pos.appear == 4:
		return false
	
	
	if !await 二级行动系统.加入(data0.get_所属life(), data0, pos):
		return false
	
	return true

func _构造(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	var pos:战斗_单位管理系统.Card_pos_sys = _gett(data[1], false, false, 战斗_单位管理系统.Card_pos_sys)
	if !pos and pos.nam != "场上":
		return false
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		if !await 二级行动系统.构造(i.get_所属life(), i, pos):
			ret = false
	
	await 最终行动系统.等待动画完成()
	return ret

func _行动打出(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	if !data0:
		return false
	
	var ret:bool = true
	for card:战斗_单位管理系统.Card_sys in data0:
		if !card.get_value("种类") in ["攻击", "防御"]:
			continue
		
		if !await 卡牌打出与发动系统.打出(targets[1], card):
			ret = false
		
	
	
	await 最终行动系统.等待动画完成()
	return ret



func _添加buff(data:Array) -> bool:
	#提取数据
	var data1 = _gett(data[1], false, false, 战斗_单位管理系统.Card_sys)
	
	
	var buff:战斗_单位管理系统.Buff_sys = buff系统.create_buff(data[0], data1, data[2], int(data[3]))
	buff.targets = targets
	
	if _get_sub_index(data[4]) != -1:
		targets[_get_sub_index(data[4])] = buff
	
	return true
