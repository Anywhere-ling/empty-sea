extends Node



@export var _model_types : Array[ModelType] = [
	preload("res://数据/卡牌/加载数据工具/card_data_model_type.tres"),
	preload("res://数据/卡牌/加载数据工具/buff_data_model_type.tres"),
	preload("res://数据/卡牌/加载数据工具/equip_data_model_type.tres"),
	preload("res://数据/卡牌/加载数据工具/life_data_model_type.tres"),
]

signal 加载完成

var _data_manager : Node


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var other_data:Dictionary#辅助数据



func _ready() -> void:
	#data_manager的设置
	if has_node(^"/root/DataManager"):
		_data_manager = get_node(^"/root/DataManager")
	_data_manager.register_data_loader("txt", load(文件路径.gdcard_data_loader()).new())
	
	
	#信号
	event_bus.debug_mode = true
	event_bus.enable_history = true
	_data_manager.load_completed.connect(_on_load_completed)
	
	
	
	#开始读取
	_data_manager.load_models(_model_types)



##读取模型
func get_data_model(model_name: String, item_id: String) -> Resource:
	return _data_manager.get_data_model(model_name, item_id)



func 储存辅助数据(data_name, data) -> void:
	other_data[data_name] = data

func get_dic_data(model_name: String, item_id: String) -> Dictionary:
	var model:= get_data_model(model_name, item_id)
	if model.has_method("get_dic_data"):
		return model.call("get_dic_data")
	return {}

## 加载完成回调
func _on_load_completed(table_name: String) -> void:
	other_data["卡名总表"] = _data_manager.get_table_data("card_data").keys()
	other_data["buff名总表"] = _data_manager.get_table_data("buff_data").keys()
	other_data["装备名总表"] = _data_manager.get_table_data("equip_data").keys()
	other_data["单位名总表"] = _data_manager.get_table_data("life_data").keys()
	
	emit_signal("加载完成")
