extends Node2D
class_name 战斗_动画

signal 可以继续
var 可以继续ed:bool = false
signal 动画完成
var 动画完成ed:bool = false


var 二级动画:战斗_动画
var data:Dictionary
var card:Card
var speed:float = C0nfig.动画速度

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus


func _init(p_data:Dictionary) -> void:
	data = p_data


func start() -> void:
	_start()

func _start() -> void:
	pass


func is_方块区(life:战斗_life, pos:String) -> bool:
	if pos in ["白区", "绿区", "蓝区" ,"红区"]:
		return true
	elif pos == "手牌":
		return !life.is_c0ntrol
	return false

func get_场上(x:int, y:int) -> 战斗_场上_单格:
	return get_parent().gui_场上.get_ind(x,y)

func get_posi(pos:String, life:战斗_life = null) -> Vector2:
	if pos.begins_with("场上"):
		var x:int = int(pos.erase(2))
		var y:int = int(pos.erase(2))
		return get_场上(x,y).get_posi()
	else:
		return life.get_posi(pos)


func _add_card(p_card:Card) -> void:
	get_parent().add_card(p_card)

func _add_效果(nam:String) -> Node:
	return load(文件路径.folder动画效果 + nam + ".tscn").instantiate()

func _add_shader(nam:String) -> Shader:
	return load(文件路径.folder动画效果_shader + nam + ".gdshader")


func emit_可以继续(动画index:int) -> void:
	可以继续ed = true
	emit_signal("可以继续", 动画index)

func emit_动画完成() -> void:
	动画完成ed = true
	emit_signal("动画完成")

func _free() -> void:
	get_parent().remove_child(self)
	queue_free()
