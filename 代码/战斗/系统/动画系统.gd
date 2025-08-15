extends Control

signal 可以继续
signal 动画完成

@onready var 最终行动系统: Node = %最终行动系统


var 对照表:Dictionary[String, Dictionary] = {
	"card":{},
	"life":{},
}
var dic动画:Dictionary[String, Dictionary] = {
	"加入":{"":{}
		
	}
}

func _ready() -> void:
	var 动画表 = load(文件路径.res_动画表()).new()
	dic动画 = 动画表.dic动画


func create_动画(tapy:String, data:Dictionary) -> 战斗_动画:
	var tapy动画:Dictionary = dic动画[tapy]
	var 符合动画
	for 动画:String in tapy动画:
		if tapy动画[动画].has("card") and tapy动画[动画]["card"] == data["card"].nam:
			var 全部符合:bool = true
			for i:String in tapy动画[动画]:
				if !tapy动画[动画][i] == data[i].nam:
					全部符合 = false
			if 全部符合:
				符合动画 = 动画
	if !符合动画:
		符合动画 = tapy
	
	data = _data转换(data)
	符合动画 = load(文件路径.folder战斗动画() + 符合动画 +".gd").new(data)
	add_child(符合动画)
	return 符合动画

func _data转换(data):
	if data is Dictionary:
		for i:String in data:
			if data[i] is 战斗_单位管理系统.Life_sys:
				data[i] = 对照表["life"][data[i]]
			elif data[i] is 战斗_单位管理系统.Card_sys:
				data[i] = 对照表["card"][data[i]]
			elif data[i] is 战斗_单位管理系统.Card_pos_sys:
				var life_gui:战斗_life = 对照表["life"][data[i].get_parent()]
				var nam:String = data[i].nam
				if nam == "场上":
					nam = nam + str(data[i].场上index)
				data[i] = [life_gui, nam]
		return data
	elif data is 战斗_单位管理系统.Life_sys:
		return 对照表["life"][data]
	elif data is 战斗_单位管理系统.Card_sys:
		return 对照表["card"][data]
	elif data is 战斗_单位管理系统.Card_pos_sys:
		var life_gui:战斗_life = 对照表["life"][data.get_parent()]
		var nam:String = data.nam
		if nam == "场上":
			nam = nam + str(data.场上index)
		return [life_gui, nam]


func start_动画(动画:战斗_动画) -> void:
	动画.可以继续.connect(emit_可以继续, 5)
	动画.动画完成.connect(emit_动画完成, 5)
	动画.start()

func emit_可以继续() -> void:
	最终行动系统.call("emit_signal", "可以继续")

func emit_动画完成() -> void:
	#await get_tree().create_timer(0.2).timeout
	最终行动系统.call("emit_signal", "动画完成")
