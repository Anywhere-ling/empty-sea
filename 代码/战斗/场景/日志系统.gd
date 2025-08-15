extends Node
class_name 战斗_日志系统


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var datasyss:Array[战斗_单位管理系统.Data_sys]
var 信息:Array[Array]



func _ready() -> void:
	event_bus.subscribe("战斗_datasys被创造", 创造了datasys)
	event_bus.subscribe("战斗_日志记录", 录入信息)


func 创造了datasys(data:战斗_单位管理系统.Data_sys) -> void:
	data.编号 = len(datasyss)
	datasyss.append(data)


func 录入信息(obj:String, fun:String, args:Array, ret) -> void:
	
	args = args.duplicate(true)
	转化成编号(args)
	
	var retarr:Array = [ret].duplicate(true)
	retarr = 转化成编号(retarr)
	
	信息.append([obj, fun, args, retarr[0]])
	_out_data(obj, fun, args, retarr[0])
	


func 转化成编号(arr:Array) -> Array:
	var arr1:Array
	for i:int in len(arr):
		for i1 in arr:
			arr1.append(i1)
		if arr[i] is 战斗_单位管理系统.Data_sys:
			var data :=Data_sys_index.new(arr[i].编号)
			arr1[i] = data
		elif arr[i] is Array:
			arr[i] = 转化成编号(arr[i])
	return arr1
	get_parent()

class Data_sys_index extends Resource:
	var index:int
	
	func _init(ind:int) -> void:
		index = ind


#class History extends Resource:
	#var obj:String
	#var fun:String
	#var args:Array
	#var ret
	#
	#func _init(p_obj:String, p_fun:String, p_args:Array, p_ret) -> void:
		#obj = p_obj
		#fun = p_fun
		#args = p_args
		#ret = p_ret
		#_out_data(p_obj, p_fun, p_args, p_ret)
	#
	#func search(data, index:int) -> bool:
		#var sub
		#match index:
			#0 : sub = obj
			#1 : sub = fun
			#3 : sub = ret
		#
		#if sub == data:
			#return true
		#
		#if !sub is String:
			#return false
		#
		#data = data.split()
		#for i:String in sub:
			#data.erase(i)
		#
		#if data == []:
			#return true
		#else :
			#return false
	#
func _out_data(p_obj:String, p_fun:String, p_args:Array, p_ret) -> void:
	var data:String
	if p_obj == "回合系统":
		if p_fun == "_回合结束":
			data = "进入回合 " + str(p_ret[0]) + "." + str(p_ret[1])
		elif p_fun == "_阶段改变的信号":
			data = "进入 " + str(p_ret) + " 阶段"
	
	elif p_obj == "最终行动系统":
		if !p_ret:
			return
		if p_fun == "加入":
			data = p_args[1].nam + " 加入了 " + p_args[2].get_parent().nam + " 的 " + p_args[2].nam
		elif p_fun == "加入连锁的动画":
			data = p_args[0].nam + " 发动了 " + p_args[1].nam + " 的 "  + str(p_args[2] + 1) + " 效果"
		elif p_fun == "抽牌":
			data = p_args[0].nam + " 抽牌了"
		elif p_fun == "反转":
			data = p_args[1].nam + " 反转了"
		elif p_fun == "无效":
			data = p_args[1].nam + " 被无效了"
		elif p_fun == "方向改变":
			data = p_args[1].nam + " 方向改变了"
		elif p_fun == "破坏":
			data = p_args[1].nam + " 破坏了"
		
		
	elif p_obj == "卡牌打出与发动系统":
		if p_fun == "打出":
			if p_ret:
				data = p_args[0].nam + " 打出了 " + p_args[1].nam
	
	elif p_obj == "战斗系统":
		if p_fun == "_处理卡牌消耗":
			data = p_args[0].get_parent().get_parent().nam + " 支付了 " + p_args[0].nam + " 的消耗"
		elif p_fun == "攻击":
			data = p_args[0].nam + " 对 " + p_args[0].att_life.nam + p_args[2]
		
	elif p_obj == "连锁系统":
		if p_fun == "start":
			data = "连锁开始处理"
	
	elif p_obj == "战斗_发动判断系统":
		data = p_fun + "失败"
	
	elif p_obj == "战斗_效果处理系统":
		data = p_fun + "失败"
	
	elif p_obj == "buff系统":
		if p_fun == "_buff判断":
			if p_ret == 0:
				data = "因 " + p_args[1] + " 生效的 " + p_args[0].nam + " 未通过"
			elif p_ret == 1:
				data = "因 " + p_args[1] + " 生效的 " + p_args[0].nam + " 通过"
			
			
	
	if data:
		print(data)
