extends VBoxContainer
class_name 卡牌创建工具_不定数量的数据节点容器

@onready var 加: Button = %加
@onready var 选项卡: OptionButton = %选项卡




signal 子数据节点数量改变


##添加数据节点
func add_child_node(node:Control) -> void:
	add_child(node)
	#连接信号
	if node is HBoxContainer:
		for i:Control in node.get_children():
			if i is Label:
				pass
			if i is LineEdit:
				i.editing_toggled.connect(func(a): if !a:
					_子数据节点数量改变的信号(i))
			if i is SpinBox:
				i.value_changed.connect(func(a):
					_子数据节点数量改变的信号(i))
			if i is OptionButton:
				i.item_selected.connect(func(a):
					_子数据节点数量改变的信号(i))
			if i is 卡牌创建工具_不定数量的数据节点容器_h:
				i.子数据节点数量改变.connect(_子数据节点数量改变的信号)
	
	
	node.owner = self
	#如果有，移动到焦点节点前
	var arr:Array = get_children()
	var focus:Control = get_viewport().gui_get_focus_owner()
	if focus:
		while !arr.has(focus):
			if !focus or !focus.get_parent() is Control:
				break
			focus = focus.get_parent()
		if focus and arr.find(focus) != -1:
			move_child(node , arr.find(focus))
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
	move_child(node1 , -3)
	var btn:= Button.new()
	node1.add_child(btn)
	for i:String in ["disabled", "hover_pressed", "hover", "pressed", "normal"]:
		btn.add_theme_stylebox_override(i, StyleBoxEmpty.new())
	btn.anchor_bottom = 1
	btn.anchor_right = 1
	

func _子数据节点数量改变的信号(node) -> void:
	emit_signal("子数据节点数量改变", self)


func _on_加_button_up() -> void:
	if 选项卡.visible == true and 选项卡.selected != -1:
		按钮添加()
	
