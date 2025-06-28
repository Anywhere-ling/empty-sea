extends 战斗_效果处理系统
class_name 战斗_发动判断系统


var effect可判断:Array = [
	
]


func _effect_process() -> bool:
	for i:int in len(effect):
		var arr:Array = effect[i]
		#发动判断
		if !arr[0] in effect可判断:
			break
		
		if arr[0] in effect标点:
			if effect标点[arr[0]].call(arr):
				
				event_bus.push_event("战斗_日志记录", [name, arr[0], [arr], true])
			else :
				
				event_bus.push_event("战斗_日志记录", [name, arr[0], [arr], false])
				return false
		
		if arr[0] in effect组件:
			if effect组件[arr[0]].call(arr):
				
				event_bus.push_event("战斗_日志记录", [name, arr[0], [arr], true])
			else :
				
				event_bus.push_event("战斗_日志记录", [name, arr[0], [arr], false])
				return false

	
	return true
