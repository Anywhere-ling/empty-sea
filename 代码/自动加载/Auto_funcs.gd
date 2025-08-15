extends Node

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

signal 数据返回

func event_bus_push_back(sign:String, data:Array) -> Array:
	var 返回:Array = [false]
	event_bus.subscribe(sign + "返回", func(a = null):
		返回[0] = true
		返回.append(a)
		emit_signal("数据返回")
		, 1, true)
	event_bus.push_event(sign, data)
	if !返回[0]:
		await 数据返回
	
	var ret = 返回[1]
	ret = [ret]
	return ret


var same_array:Array
func set_same_array(a:Array) -> void:
	same_array = a


func is_same_array(a:Array) -> bool:
	same_array.append("is_same_array")
	var ret = a.has("is_same_array")
	same_array.erase("is_same_array")
	return ret
