extends Node
class_name 战斗_日志系统

var datasyss:Array[战斗_单位管理系统.Data_sys]
var 信息:Array[Array]


func 记录(func_to_wrap: Callable) -> Callable:
	var wrapped = func(args):
		var result = func_to_wrap.call(args)
		录入信息(func_to_wrap.get_object(), func_to_wrap, args, result)
		return result
	return wrapped


func 录入信息(obj:Object, fun:Callable, args:Array, ret) -> void:
	var arr:Array
	arr.append(obj.name)
	arr.append(str(fun))
	
	args = args.duplicate(true)
	转化成编号(args)
	arr.append(args)
	
	var retarr:Array = [ret].duplicate(true)
	转化成编号(retarr)
	arr.append(retarr[0])
	
	信息.append(arr)

func 转化成编号(arr:Array) -> void:
	for i:int in len(arr):
		if arr[i] is 战斗_单位管理系统.Data_sys:
			arr[i] = Data_sys_index.new(arr[i].index)
		elif arr[i] is Array:
			转化成编号(arr[i])
			

class Data_sys_index extends Object:
	var index:int
	
	func _init(ind:int) -> void:
		index = ind
