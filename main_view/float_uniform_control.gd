extends UniformControl

@export var name_label: Label
@export var value_label: Label
@export var slider: HSlider

func _ready() -> void:
	slider.value_changed.connect(_on_value_changed)

func set_uniform_name(_name: String):
	name_label.text = _name

func set_uniform_value(value: Variant):
	if value:
		slider.value = value
		value_label.text = str(value)

func set_uniform_hint(hint: int, hint_string: String):
	match hint:
		PROPERTY_HINT_RANGE:
			var bounds = hint_string.split_floats(",", false)
			slider.min_value = bounds[0]
			slider.max_value = bounds[1]
			if bounds.size() > 2:
				slider.step = bounds[2]

func _on_value_changed(value: float):
	uniform_value_changed.emit(value)
	value_label.text = str(value)
