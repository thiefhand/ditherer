extends Control

@export var image_info_label: Label
@export var image_path_label: Label
@export var zoom_slider: HSlider
@export var show_original_button: BaseButton
@export var dithered_sprite: Sprite2D
@export var save_button: BaseButton
@export var save_scaled_button: BaseButton
@export var scale_input: TextEdit
@export var settings_container: Control
@export var control_types: Dictionary[Variant.Type, PackedScene]
@export var viewport: SubViewport
@export var file_dialog: FileDialog
@export var current_algo: Algo
@export var algos: Array[Algo]
@export var algo_option_button: OptionButton

var _base_image: Image
var _base_image_path: String

func _ready() -> void:
	get_viewport().files_dropped.connect(on_files_dropped)
	save_button.pressed.connect(_on_save_pressed)
	save_scaled_button.pressed.connect(_on_save_scaled_pressed)
	zoom_slider.value_changed.connect(_on_zoom_slider_value_changed)
	zoom_slider.value = dithered_sprite.scale.x
	show_original_button.button_down.connect(_on_show_original_state_changed.bind(true))
	show_original_button.button_up.connect(_on_show_original_state_changed.bind(false))

	load_base_image("sucky.png", load("res://main_view/sucky.png").get_image())
	set_image_to_base()

	for algo in algos:
		algo_option_button.add_item(algo.get_display_name())
	algo_option_button.item_selected.connect(_on_item_selected)
	_on_item_selected(0)

	set_image(_base_image_path, _run_algo())

func load_base_image(image_path: String, image: Image):
	_base_image_path = image_path
	_base_image = image

func set_image_to_base():
	set_image(_base_image_path, _base_image)

func set_image(image_path: String, image: Image):
	image_path_label.text = image_path
	dithered_sprite.texture = ImageTexture.create_from_image(image)
	image_info_label.text = str(int(image.get_size().x)) + "×" + str(int(image.get_size().y)) + " pixels"

func _generate_settings():
	for child in settings_container.get_children():
		child.queue_free()

	for uniform in current_algo.get_property_list():
		if control_types.has(uniform["type"]):
			var control_scene = control_types[uniform["type"]]
			var control: UniformControl = control_scene.instantiate()

			control.set_uniform_name(uniform["name"])
			control.set_uniform_hint(uniform["hint"], uniform["hint_string"])
			control.set_uniform_value(current_algo.get(uniform["name"]))
			control.uniform_value_changed.connect(_on_control_uniform_value_changed.bind(uniform["name"]))

			settings_container.add_child(control)

func _run_algo() -> Image:
	return current_algo.dither(_base_image)

func save_to_png(path: String, scale: float = 1.0):
	var spr_w = dithered_sprite.texture.get_width()
	var spr_h = dithered_sprite.texture.get_height()
	var og_scale = dithered_sprite.scale

	dithered_sprite.scale = Vector2.ONE
	await RenderingServer.frame_post_draw
	var src_img = viewport.get_texture().get_image()
	var src_rect = Rect2i(
		float(src_img.get_width()) / 2.0 - float(spr_w) / 2.0,
		float(src_img.get_height()) / 2.0 - float(spr_h) / 2.0,
		spr_w, spr_h
	)
	var dst_img = Image.create(spr_w, spr_h, false, src_img.get_format())
	dst_img.blit_rect(src_img, src_rect, Vector2i.ZERO)
	dst_img.resize(dst_img.get_width() * scale, dst_img.get_height() * scale, Image.INTERPOLATE_NEAREST)

	dst_img.save_png(path)

	dithered_sprite.scale = og_scale

func _on_save_pressed():
	file_dialog.filters = ["*.png ; PNG Images"]
	file_dialog.title = "Save PNG"
	file_dialog.size = get_viewport_rect().size
	file_dialog.show()	

	var path = await file_dialog.file_selected

	file_dialog.hide()
	save_to_png(path)

func _on_save_scaled_pressed():
	file_dialog.filters = ["*.png ; PNG Images"]
	file_dialog.title = "Save PNG (Scaled)"
	file_dialog.size = get_viewport_rect().size
	file_dialog.show()	

	var path = await file_dialog.file_selected

	file_dialog.hide()
	if scale_input.text.is_empty():
		save_to_png(path, 1.0)
	else:
		save_to_png(path, int(scale_input.text) / 100.0)

func _on_control_uniform_value_changed(value: Variant, name: String):
	# (dithered_sprite.material as ShaderMaterial).set_shader_parameter(name, value)
	current_algo.set(name, value)

	set_image(_base_image_path, _run_algo())

func _on_zoom_slider_value_changed(value: float):
	dithered_sprite.scale = Vector2.ONE * value

func _on_show_original_state_changed(pressed: bool):
	if pressed:
		set_image_to_base()
	else:
		set_image(_base_image_path, _run_algo())

func on_files_dropped(files: PackedStringArray):
	var file = files[0]
	load_base_image(file, Image.load_from_file(file))
	set_image_to_base()

func _on_item_selected(index: int):
	var display_name = algo_option_button.get_item_text(index)

	for algo in algos:
		if algo.get_display_name() == display_name:
			current_algo = algo
			set_image(_base_image_path, _run_algo())
			_generate_settings()
			
			return
