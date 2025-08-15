extends Control
class_name 卡牌创建工具_单个设计区

@onready var 卡名: LineEdit = %卡名
@onready var 效果设计区: 卡牌创建工具_效果设计区 = $PanelContainer/主要区域/VBoxContainer/效果/效果设计区
@onready var 效果: VBoxContainer = $PanelContainer/主要区域/VBoxContainer/效果
@onready var 前进: Button = %前进
@onready var 后退: Button = %后退

var 需要一起删除:Array[Array]


signal 请求关闭该卡牌
signal 请求储存到历史记录
signal 请求读取历史记录

var history_index:int = -1:
	set(value):
		history_index = value
		if value > 0 :
			后退.disabled = false
		else :
			后退.disabled = true
		if value < len(history) - 1 :
			前进.disabled = false
		else :
			前进.disabled = true
var history:Array = []











##一起删除的数组
func get_需要一起删除_array(node:Control) -> Array:
	var ret:Array = []
	for arr:Array in 需要一起删除:
		if arr.has(node):
			ret.append_array(arr)
	return ret


##添加下一条空效果
func _add_new_effect() -> void:
	var new_effect:卡牌创建工具_效果设计区 = load(文件路径.tscn卡牌创建工具_效果设计区()).instantiate()
	效果.add_child(new_effect)
	_reset_effect_index()
	#绑定信号
	new_effect.请求检测空效果.connect(_请求检测空效果的信号)

##清除空效果
func _remove_empty_effects() -> void:
	var arr:Array = 效果.get_children()
	for effect:Control in arr:
		if effect is 卡牌创建工具_效果设计区:
			if effect.is_empty_effect():
				effect.get_parent().remove_child(effect)
				effect.queue_free()
		else:
			效果.remove_child(effect)
			effect.queue_free()
				
	_add_new_effect()



#重置效果的序号
func _reset_effect_index() -> void:
	var arr:Array = 效果.get_children()
	for effect:卡牌创建工具_效果设计区 in arr:
		var index:int = arr.find(effect)
		effect.名字.text = "效果/" + str(index + 1)
		var hse:= HSeparator.new()
		效果.add_child(hse)
		效果.move_child(hse, (index * 2) + 1)



func _请求检测空效果的信号(node:HBoxContainer) -> void:
	_remove_empty_effects()
	emit_signal("请求储存到历史记录")
	




func _on_关闭_button_up() -> void:
	emit_signal("请求关闭该卡牌", self)


func _on_前进_button_up() -> void:
	history_index += 1
	emit_signal("请求读取历史记录", history[history_index])



func _on_后退_button_up() -> void:
	history_index -= 1
	emit_signal("请求读取历史记录", history[history_index])



func _on_卡名_text_changed(new_text: String) -> void:
	name = new_text
	emit_signal("请求储存到历史记录")


func _on_卡名_editing_toggled(toggled_on: bool) -> void:
	if !toggled_on:
		emit_signal("请求储存到历史记录")

func _on_种类_item_selected(index: int) -> void:
	emit_signal("请求储存到历史记录")
