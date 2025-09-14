extends PanelContainer


@onready var 容器: VBoxContainer = %容器
@onready var 滚动: ScrollContainer = %滚动

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var cards:Array
var is_reverse:bool = false
var is_动画:bool = false

signal 完成

func _ready() -> void:
	event_bus.subscribe("战斗_gui连锁_add", add_card)
	event_bus.subscribe("战斗_gui连锁_remove", remove_card)


func add_card(card:Card, is_positive:bool, eff_ind:int) -> void:
	visible = true
	
	var 子:战斗_gui连锁_子
	for i in 容器.get_children():
		if !i.visible:
			子 = i
			break
	if !子:
		子 = _get_子()
		容器.add_child(子)
	
	
	子.set_card(card, is_positive, eff_ind)
	
	cards.append(子)
	
	var v_bar: = 滚动.get_v_scroll_bar()
	var l:int = (v_bar.max_value + 4)/(len(cards)-1)
	var time:float = 1.1
	if len(cards) == 2:
		is_动画 = true
	if !is_动画:
		time = 0
	await _tween(v_bar.max_value - v_bar.page + l, time)
	
	call_deferred("emit_signal", "完成")
	visible = false


func _get_子() -> 战斗_gui连锁_子:
	var 子:战斗_gui连锁_子 = preload(文件路径.tscn_战斗_gui连锁_子).instantiate()
	return 子

func free_card() -> void:
	for i:战斗_gui连锁_子 in 容器.get_children():
		if !i.visible:
			break
		i.free_card()
		i.visible = false

var tween:Tween
func _tween(a:int, time:float = 1.1) -> void:
	if time == 0:
		滚动.scroll_vertical = a
		return
	time -= 0.1
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	
	time = time/C0nfig.动画速度
	tween.tween_property(滚动, "scroll_vertical", a, time*0.7)
	await get_tree().create_timer(time).timeout

func remove_card() -> void:
	visible = true
	
	var v_bar: = 滚动.get_v_scroll_bar()
	var l:int = (v_bar.max_value + 4)/(len(cards) - 1)
	var time:float = 1.1
	
	if !is_动画:
		time = 0
	await _tween(v_bar.max_value - v_bar.page, time)
	
	cards[-1].free_card()
	cards.remove_at(cards.size() - 1)
	call_deferred("emit_signal", "完成")
	visible = false
	if len(cards) == 0:
		is_动画 = false
