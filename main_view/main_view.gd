extends Control

@export var image_info_label: Label
@export var image_path_label: Label
@export var zoom_slider: HSlider
@export var dithered_sprite: Sprite2D
@export var dither_button: BaseButton
@export var settings_container: Control
@export var control_types: Dictionary[Variant.Type, PackedScene]

func _ready() -> void:
	dither_button.pressed.connect(_on_dither_pressed)
	zoom_slider.value_changed.connect(_on_zoom_slider_value_changed)
	zoom_slider.value = dithered_sprite.scale.x

	load_image("sucky.png", load("res://main_view/sucky.png"))

	_generate_settings()

func load_image(image_path: String, image: Texture2D):
	image_path_label.text = image_path
	dithered_sprite.texture = image
	image_info_label.text = str(int(image.get_size().x)) + "×" + str(int(image.get_size().y)) + " pixels"

func _generate_settings():
	var shad_mat: ShaderMaterial = dithered_sprite.material as ShaderMaterial
	for uniform in shad_mat.shader.get_shader_uniform_list():
		print(uniform)

		if control_types.has(uniform["type"]):
			var control_scene = control_types[uniform["type"]]
			var control: UniformControl = control_scene.instantiate()

			control.set_uniform_name(uniform["name"])
			control.set_uniform_hint(uniform["hint"], uniform["hint_string"])
			control.set_uniform_value(shad_mat.get_shader_parameter(uniform["name"]))
			control.uniform_value_changed.connect(_on_control_uniform_value_changed.bind(uniform["name"]))

			settings_container.add_child(control)

func do_dither():
	pass

func _on_dither_pressed():
	do_dither()

func _on_control_uniform_value_changed(value: Variant, name: String):
	(dithered_sprite.material as ShaderMaterial).set_shader_parameter(name, value)

func _on_zoom_slider_value_changed(value: float):
	dithered_sprite.scale = Vector2.ONE * value
