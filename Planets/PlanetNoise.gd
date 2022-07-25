@tool
extends Resource

class_name PlanetNoise

@export var noise_map : OpenSimplexNoise: set = set_noise_map
@export var amplitude : float = 1.0: set = set_amplitude
@export var min_height : float = 0.0: set = set_min_height
@export var use_first_layer_as_mask : bool = false: set = set_first_layer_as_mask

func set_first_layer_as_mask(val):
	use_first_layer_as_mask = val
	changed.emit()
	
func set_min_height(val):
	min_height = val
	changed.emit()
	
func set_amplitude(val):
	amplitude = val
	changed.emit()

func set_noise_map(val):
	noise_map = val
	changed.emit()
	if noise_map != null and not noise_map.is_connected("changed", self, "on_data_changed"):
		noise_map.changed.connect(on_data_changed)
		
func on_data_changed():
	changed.emit()
