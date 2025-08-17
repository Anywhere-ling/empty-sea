extends Node2D
class_name 战斗_动画

signal 可以继续
var 可以继续ed:bool = false
signal 动画完成
var 动画完成ed:bool = false


var 二级动画:战斗_动画
var data:Dictionary
var card:Card
var speed:float = Config.动画速度

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus


func _init(p_data:Dictionary) -> void:
	data = p_data


func start() -> void:
	_start()

func _start() -> void:
	pass


func _add_card(p_card:Card) -> void:
	assert(!p_card.get_parent(), "有父节点")
	get_parent().add_child(p_card)

func _add_效果(nam:String) -> Node:
	return load(文件路径.folder动画效果() + nam + ".tscn").instantiate()

func _add_shader(nam:String) -> Shader:
	return load(文件路径.folder动画效果_shader() + nam + ".gdshader")


func emit_可以继续() -> void:
	可以继续ed = true
	emit_signal("可以继续")

func emit_动画完成() -> void:
	动画完成ed = true
	emit_signal("动画完成")

func _free() -> void:
	get_parent().remove_child(self)
	queue_free()
