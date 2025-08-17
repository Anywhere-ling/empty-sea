extends Node2D
class_name Card

@onready var 种类: TextureRect = %种类
@onready var 卡名: Label = %卡名
@onready var 卡图: TextureRect = %卡图
@onready var 里侧: Panel = %里侧
@onready var 主要区域: PanelContainer = %主要区域
@onready var sp: Label = %sp
@onready var mp: Label = %mp
@onready var 表侧: PanelContainer = %表侧
@onready var 渲染: SubViewport = %渲染
@onready var 图片: TextureRect = %图片
@onready var 第二层: Node2D = %第二层
@onready var 光圈: Panel = %光圈
@onready var 顶部: Control = %顶部

@export var 光圈_arr:Array[StyleBoxFlat]


signal 图片或文字改变

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var nam:String
var card_sys:战斗_单位管理系统.Card_sys

func _ready() -> void:
	event_bus.subscribe("战斗_鼠标进入卡牌", func(a):
		鼠标停留的卡牌 = a)
	图片或文字改变.connect(_图片或文字改变的信号)
	tree_exiting.connect(set_glo)
	tree_entered.connect(reset_glo)
	



func set_card(p_card_sys:战斗_单位管理系统.Card_sys) -> void:
	card_sys = p_card_sys
	nam = card_sys.nam
	display()


func display() -> void:
	if FileAccess.file_exists(文件路径.png卡牌种类(card_sys.nam)):
		卡图.texture = load(文件路径.png卡牌种类(card_sys.nam))
	else :
		卡图.texture = load(文件路径.png_test())
	
	图片.resized.connect(func():渲染.size = 图片.size)
	if !card_sys.direction:
		第二层.rotation_degrees = 90
	
	
	var data = DatatableLoader.get_data_model("card_data", card_sys.nam)
		
	种类.texture = load(文件路径.png卡牌种类(data.种类))
	卡名.text = data.卡名
	sp.text = str(data.sp)
	mp.text = str(data.mp)
	
	if card_sys.appear != 0:
		for i in ["特征", "组", "种类", "卡名", "sp", "mp"]:
			_图片或文字改变的信号(i)


signal 卡牌信息改变
var 组:Array
var 特征:Array
func _图片或文字改变的信号(key:String) -> void:
	var positive:bool = card_sys.appear
	表侧.visible = positive
	里侧.visible = !positive
	
	if card_sys.appear == 0:
		return
		
	if key in ["种类"]:
		种类.texture = load(文件路径.png卡牌种类(card_sys.get_value("种类")))
	elif key in ["卡名"]:
		卡名.text = card_sys.get_value("卡名")
	elif key in ["sp"]:
		sp.text = str(card_sys.get_value("sp"))
	elif key in ["mp"]:
		mp.text = str(card_sys.get_value("mp"))
	elif key in ["组"]:
		组 = card_sys.get_value("组")
		卡牌信息改变
		return
	elif key in ["特征"]:
		特征 = card_sys.get_value("特征")
		卡牌信息改变
		return
	
	
	
	_重新渲染()





func _重新渲染() -> void:
	渲染.render_target_update_mode = 渲染.UPDATE_ONCE


func 光圈改变(index:int) -> void:
	var style:StyleBoxFlat = 光圈_arr[index]
	光圈.add_theme_stylebox_override("panel", style)



func get_pos() -> String:
	return card_sys.pos

func get_his_pos() -> String:
	return card_sys.his_pos[-2]


signal 卡牌被释放
func free_card() -> void:
	emit_signal("卡牌被释放")
	queue_free()




var tweens:Dictionary[String, Tween]
var tween_ease:Tween.EaseType = Tween.EASE_IN_OUT
var tween_trans:Tween.TransitionType = Tween.TRANS_EXPO
func _new_tween(nam) -> Tween:
	if tweens.has(nam) and tweens[nam]:
		tweens[nam].kill()
	var tween: = create_tween()
	tween.set_ease(tween_ease)
	tween.set_trans(tween_trans)
	tweens[nam] = tween
	return tween

func tween_kill(nam) -> void:
	if tweens.has(nam) and tweens[nam]:
		tweens[nam].kill()

func tween动画添加(tween, property:String, final_val, time:float) -> Tween:
	if !tween is Tween:
		tween = _new_tween(tween)
	tween.tween_property(self, property, final_val, time)
	return tween

func tween动画添加_第二层(tween, property:String, final_val, time:float) -> Tween:
	if !tween is Tween:
		tween = _new_tween(tween)
	tween.tween_property(第二层, property, final_val, time)
	return tween





var glo_p:Vector2
var glo_r:float
func set_glo() -> void:
	glo_p = global_position
	glo_r = global_rotation

func reset_glo() -> void:
	if glo_p:
		global_position = glo_p
		global_rotation = glo_r




var 鼠标停留的卡牌:Card
func 检测鼠标() -> bool:
	var rec2: = Rect2(图片.position + 图片.size/2, 图片.size)
	return rec2.has_point(图片.get_local_mouse_position())





func _on_左_button_up() -> void:
	event_bus.push_event("战斗_卡牌被左键点击", self)
