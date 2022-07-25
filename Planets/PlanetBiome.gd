@tool
extends Resource
class_name PlanetBiome

@export var gradient : GradientTexture: set = set_gradient
@export var start_height : float: set = set_start_height

func set_gradient(val):
	gradient = val
	changed.emit()
	if not gradient.is_connected("changed", self, "bubble_signal_changed"):
		gradient.changed.connect(bubble_signal_changed)

func set_start_height(val):
	start_height = val
	changed.emit()

func bubble_signal_changed():
	changed.emit()
