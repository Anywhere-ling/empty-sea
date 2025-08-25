extends Control




@onready var 选项集: Container = %选项集
@onready var sop: Control = %sop
@onready var pos: Control = %pos
@onready var 选项集节点: Control = %选项集节点
@onready var 手牌: 战斗_行动与手牌 = %手牌

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var lifes:Array[战斗_life]
var efils:Array[战斗_life]
var lifes_ind:float = 0:
	set(value):
		life显示改变(lifes, value)
		lifes_ind = value
var efils_ind:float = 0:
	set(value):
		life显示改变(efils, value)
		efils_ind = value


#func _ready() -> void:
	#event_bus.call_deferred("push_event", "战斗_右边显示改变", 选项集节点)


func set_c0ntrol(life:战斗_life) -> void:
	life.手牌 = 手牌
	life.卡牌五区.光圈手牌.visible = false


func add_life(life:战斗_life, index:int, all_index:int, is_positive:bool) -> void:
	life.get_parent().remove_child(life)
	if is_positive:
		lifes.insert(index, life)
		_ind改变(index, true)
		add_btn(life, all_index, true)
		pos.add_child(life)
	else :
		efils.insert(index, life)
		_ind改变(index, false)
		add_btn(life, all_index, false)
		sop.add_child(life)
	life.set_all()
	
	_按钮被按下(life)


var tween_ind改变:Tween
func _ind改变(ind:int, is_positive:bool) -> void:
	if tween_ind改变:
		tween_ind改变.kill()
	tween_ind改变 = create_tween()
	tween_ind改变.set_ease(Tween.EASE_OUT)
	tween_ind改变.set_trans(Tween.TRANS_QUAD)
	if is_positive:
		tween_ind改变.tween_property(self, "lifes_ind", ind, 0.3)
	else :
		tween_ind改变.tween_property(self, "efils_ind", ind, 0.3)


func life显示改变(lifes:Array[战斗_life], ind:float) -> void:
	var up_life:战斗_life = lifes[int(ind)]
	if ind + 1 == len(lifes):
		for i in lifes:
			i.visible = false
		up_life.visible = true
		return
	var up_length:float = ind - int(ind)
	var down_life:战斗_life = lifes[int(ind) + 1]
	var down_length:float = int(ind) + 1 - ind
	
	#up
	up_life.scale = Vector2(1,1) * (1 + (up_length/2))
	up_life.modulate.a = 1 - up_length
	#down
	down_life.scale = Vector2(1,1) * (1 - (down_length/2))
	down_life.modulate.a = 1 - down_length
	
	#visible
	for i in lifes:
		i.visible = false
	if up_length != 0:
		down_life.visible = true
	up_life.visible = true


func add_btn(p_life:战斗_life, all_index:int, is_positive:bool) -> void:
	var button:战斗_gui单位管理_选项 = preload(文件路径.tscn_gui单位管理_选项).instantiate()
	选项集.add_child(button)
	选项集.move_child(button, all_index)
	button.set_icon(p_life, is_positive)
	button.按钮按下.connect(_按钮被按下)


func _按钮被按下(life:战斗_life) -> void:
	if lifes.has(life):
		_ind改变(lifes.find(life), true)
		event_bus.push_event("战斗_显示单位切换", [life, true])
	else :
		_ind改变(efils.find(life), false)
		event_bus.push_event("战斗_显示单位切换", [life, false])


func _on_点击旁边_button_up() -> void:
	#event_bus.push_event("战斗_右边显示改变", 选项集节点)
	event_bus.push_event("战斗_左键点击旁边")
