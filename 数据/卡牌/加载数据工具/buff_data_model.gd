extends Resource
class_name BuffData

@export var 卡名:String
@export var 优先:int
@export var 影响:Array
@export var 效果:Array



func get_dic_data() -> Dictionary:
	var dic:Dictionary
	dic["卡名"] = 卡名
	dic["优先"] = 优先
	dic["影响"] = 影响
	dic["效果"] = 效果
	
	return dic
