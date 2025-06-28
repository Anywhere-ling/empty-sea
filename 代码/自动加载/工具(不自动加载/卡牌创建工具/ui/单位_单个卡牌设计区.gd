extends 卡牌创建工具_单个设计区
class_name 卡牌创建工具_单个单位设计区


@onready var 装备: 卡牌创建工具_不定数量的数据节点容器_h = %装备
@onready var 大小: SpinBox = %大小
@onready var 组: 卡牌创建工具_不定数量的数据节点容器_h = %组











func _ready() -> void:
	#连接信号
	效果设计区.请求检测空效果.connect(_请求检测空效果的信号)
	装备.子数据节点数量改变.connect(_请求检测空效果的信号)
	组.子数据节点数量改变.connect(_请求检测空效果的信号)



func _on_大小_value_changed(value: float) -> void:
	emit_signal("请求储存到历史记录")
