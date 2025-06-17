extends ScrollContainer
class_name 卡牌创建工具_带搜索的选择器

@onready var 选项容器: VBoxContainer = %选项容器
@onready var 搜索框: LineEdit = %搜索框

signal 确认按钮被按下
signal 请求显示简介

var choose_data:Array = []#总的选项
var choose_index:int = -1#选择的序号
var btns_group:= ButtonGroup.new()#按钮组


func _ready() -> void:
	btns_group.pressed.connect(_选项被选择的信号)




##开始生成选项
func start_build() -> bool:
	if choose_data == []:
		return false
	
	for i in choose_data:
		var choose:Node
		#判断类型
		if i is int:
			i = str(i)
		
		if i is String :
			choose = Label.new()
			choose.text = i
			
		#添加选择按钮
		var btn1:= Button.new()
		btn1.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		btn1.set_anchors_preset(PRESET_FULL_RECT)
		choose.add_child(btn1)
		btn1.toggle_mode = true
		btn1.button_group = btns_group
		btn1.focus_mode = Control.FOCUS_NONE
		
		
		#添加确认按钮
		var btn2:= Button.new()
		btn2.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		btn2.set_anchors_preset(PRESET_FULL_RECT)
		btn1.add_child(btn2)
		btn2.mouse_filter = Control.MOUSE_FILTER_PASS
		btn2.visible = false
		btn1.toggled.connect(func(b): btn2.visible = b)
		btn2.button_down.connect(_确认按钮被按下的信号.bind(btn2))
		btn2.focus_mode = Control.FOCUS_NONE
		
		#添加到容器
		选项容器.add_child(choose)
			
	return true

##返回当前选项
func _get_choose():
	if choose_index == -1:
		return null
	return choose_data[choose_index]

##搜索功能
func _search(text:String) -> void:
	var arr:Array[Node] = 选项容器.get_children()
	#取消所有按钮的隐藏
	for i:Node in arr:
		i.visible = true
	
	if text != "":
		#隐藏不符合的按钮
		for i:Node in arr:
			if !_has_string(i.text , text.split("", true)):
				i.visible = false


##判断是否有这些字
func _has_string(text:String , arr:Array) -> bool:
	var new_text:Array = text.split("", true)
	var o_length:int = len(new_text)#原长度
	#过滤" "
	arr = arr.filter(func(a):return a != " ")
	
	#删除对应字符
	for i:String in arr:
		new_text.erase(i)
	
	#检测删除的数量
	return len(new_text) + len(arr) == o_length
	
	


func _选项被选择的信号(button:Button) -> void:
	choose_index = 选项容器.get_children().find(button.get_parent())
	emit_signal("请求显示简介", _get_choose())

func _确认按钮被按下的信号(button:Button) -> void:
	if button.get_parent() == btns_group.get_pressed_button():
		emit_signal("确认按钮被按下", _get_choose())
	


func _on_搜索框_text_changed(new_text: String) -> void:
	_search(new_text)
