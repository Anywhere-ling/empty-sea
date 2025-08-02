extends PanelContainer
class_name 战斗_gui单位管理_选项

@onready var 正: Button = %正
@onready var 反: Button = %反


var life:战斗_life

signal 按钮按下


func set_icon(p_life:战斗_life, is_positive:bool) -> void:
	life = p_life
	
	if is_positive:
		反.disabled = true
		反.get_parent().modulate.a = 0
	else :
		正.disabled = true
		正.get_parent().modulate.a = 0
	
	反.get_parent().texture = life.life图.texture
	正.get_parent().texture = life.life图.texture
	


func _on_正_button_down() -> void:
	emit_signal("按钮按下", life)


func _on_反_button_down() -> void:
	emit_signal("按钮按下", life)
