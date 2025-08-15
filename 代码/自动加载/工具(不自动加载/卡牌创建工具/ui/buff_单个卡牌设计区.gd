extends 卡牌创建工具_单个设计区
class_name 卡牌创建工具_单个buff设计区


@onready var 优先: SpinBox = %优先
@onready var 影响: 卡牌创建工具_不定数量的数据节点容器_h = %影响












func _ready() -> void:
	#连接信号
	效果设计区.请求检测空效果.connect(_请求检测空效果的信号)
	影响.子数据节点数量改变.connect(_请求检测空效果的信号)




func _请求检测空效果的信号(node:HBoxContainer) -> void:
	emit_signal("请求储存到历史记录")
	


func _on_优先_value_changed(value: float) -> void:
	emit_signal("请求储存到历史记录")
