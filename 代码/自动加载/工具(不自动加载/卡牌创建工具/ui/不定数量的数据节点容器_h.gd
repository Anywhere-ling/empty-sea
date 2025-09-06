extends HBoxContainer
class_name 卡牌创建工具_不定数量的数据节点容器_h

@onready var 加: Button = %加
@onready var 选项卡: OptionButton = %选项卡
@onready var 提供焦点: Button = %提供焦点




signal 子数据节点数量改变


##添加数据节点
func add_child_node(node:Control) -> void:
	add_child(node)
	#如果有，移动到焦点节点前
	var arr:Array = get_children()
	var focus:Control = get_viewport().gui_get_focus_owner()
	if focus:
		if arr.has(focus):
			move_child(node , arr.find(focus))
			emit_signal("子数据节点数量改变", self)
			return
		elif arr.has(focus.get_parent()):
			move_child(node , arr.find(focus.get_parent()))
			emit_signal("子数据节点数量改变", self)
			return
	move_child(node , -3)
	
	
	emit_signal("子数据节点数量改变", self)
	
	
	
##移除数据节点
func remove_child_node(node:Control) -> void:
	remove_child(node)
	node.queue_free()
	
	emit_signal("子数据节点数量改变", self)

##判断是否有数据节点
func has_child_node() -> bool:
	return len(get_children()) > 2



func 按钮添加() -> void:
	var node1:= Label.new()
	node1.text = 选项卡.get_item_text(选项卡.selected)
	add_child_node(node1)
	var btn:= 提供焦点.duplicate(15)
	btn.visible = true
	node1.add_child(btn)
	#var btn:= Button.new()
	#node1.add_child(btn)
	#for i:String in ["disabled", "hover_pressed", "hover", "pressed", "normal"]:
		#btn.add_theme_stylebox_override(i, StyleBoxEmpty.new())
	#btn.anchor_bottom = 1
	#btn.anchor_right = 1

func _on_加_button_up() -> void:
	if 选项卡.visible == true and 选项卡.selected != -1:
		按钮添加()
	
	
