extends Node2D


@onready var line_2d: Line2D = %Line2D
var posi:Node2D


func _physics_process(delta: float) -> void:
	global_position = posi.global_position
	
	line_2d.add_point(global_position)
	if line_2d.points.size() > 20:
		line_2d.remove_point(0)
