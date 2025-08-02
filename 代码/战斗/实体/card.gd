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




signal 图片或文字改变

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var nam:String
var card_sys:战斗_单位管理系统.Card_sys

func _ready() -> void:
	event_bus.subscribe("战斗_鼠标进入卡牌", func(a):
		鼠标停留的卡牌 = a)
	图片或文字改变.connect(_图片或文字改变的信号)



func _physics_process(delta: float) -> void:
	_检测鼠标()




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
	_图片或文字改变的信号()



func _图片或文字改变的信号() -> void:
	if card_sys.appear != 0:
		种类.texture = load(文件路径.png卡牌种类(card_sys.图形化数据["种类"]))
		卡名.text = card_sys.图形化数据["卡名"]
		sp.text = str(card_sys.图形化数据["sp"])
		mp.text = str(card_sys.图形化数据["mp"])
	
	var positive:bool = card_sys.appear
	表侧.visible = positive
	里侧.visible = !positive
	
	重新渲染()


func 重新渲染() -> void:
	渲染.render_target_update_mode = 渲染.UPDATE_ONCE


func 光圈改变(index:int) -> void:
	var color:Color
	match index:
		0:color = Color(0,0,0,0)
		1:color = Color.DODGER_BLUE
		2:color = Color.GOLD
		3:color = Color.DODGER_BLUE.blend(Color.GOLD)
	
	var style:StyleBoxFlat
	style = 光圈.get_theme_stylebox("panel")
	style.bg_color = color
	if index == 0:
		style.border_color = color
	else:
		style.border_color = Color(color, 0.3)



func get_pos() -> String:
	if get_parent():
		return get_parent().tooltip_text
	return "场地"





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





var  glo:Vector2
func set_glo() -> void:
	glo = global_position



var 鼠标停留中:bool = false
var 鼠标停留的卡牌:Card

func _检测鼠标() -> void:
	var rec2: = Rect2(图片.position + 图片.size/2, 图片.size)
	if rec2.has_point(图片.get_local_mouse_position()):
		if !鼠标停留的卡牌:
			鼠标停留中 = true
			event_bus.push_event("战斗_鼠标进入卡牌", self)
	else :
		if 鼠标停留的卡牌 == self:
			鼠标停留中 = false
			event_bus.push_event("战斗_鼠标进入卡牌", null)




func _on_左_button_up() -> void:
	if 鼠标停留的卡牌 == self:
		event_bus.push_event("战斗_卡牌被左键点击", self)
