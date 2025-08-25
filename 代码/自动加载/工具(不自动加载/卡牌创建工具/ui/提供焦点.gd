extends Button

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func _on_button_up() -> void:
	event_bus.push_event("提供焦点的按钮被按下", self)
