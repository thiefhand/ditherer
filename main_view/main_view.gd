extends Control

@export var image_info_label: Label
@export var image_path_label: Label
@export var zoom_slider: HSlider
@export var show_original_button: BaseButton
@export var dithered_sprite: Sprite2D
@export var save_button: BaseButton
@export var settings_container: Control
@export var control_types: Dictionary[Variant.Type, PackedScene]
@export var viewport: SubViewport
@export var file_dialog: FileDialog

var _dither_material: ShaderMaterial

func _ready() -> void:
	get_viewport().files_dropped.connect(on_files_dropped)
	save_button.pressed.connect(_on_save_pressed)
	zoom_slider.value_changed.connect(_on_zoom_slider_value_changed)
	zoom_slider.value = dithered_sprite.scale.x
	show_original_button.button_down.connect(_on_show_original_state_changed.bind(true))
	show_original_button.button_up.connect(_on_show_original_state_changed.bind(false))

	load_texture("sucky.png", load("res://main_view/sucky.png"))

	_generate_settings()

	file_dialog.connect("file_selected", _on_file_selected)

func load_texture(image_path: String, texture: Texture2D):
	image_path_label.text = image_path
	dithered_sprite.texture = texture
	image_info_label.text = str(int(texture.get_size().x)) + "×" + str(int(texture.get_size().y)) + " pixels"

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

# func do_dither():
# 	var spr_w = dithered_sprite.texture.get_width()
# 	var spr_h = dithered_sprite.texture.get_height()

# 	dithered_sprite.scale = Vector2.ONE
# 	await RenderingServer.frame_post_draw
# 	var src_img = viewport.get_texture().get_image()
# 	src_img.save_png("user://source.png")
# 	var src_rect = Rect2i(
# 		float(src_img.get_width()) / 2.0 - float(spr_w) / 2.0,
# 		float(src_img.get_height()) / 2.0 - float(spr_h) / 2.0,
# 		spr_w, spr_h
# 	)
# 	print(src_rect)
# 	var dst_img = Image.create(spr_w, spr_h, false, src_img.get_format())
# 	dst_img.blit_rect(src_img, src_rect, Vector2i.ZERO)
# 	dst_img.save_png("user://dest.png")
# 	load_texture("the ether", ImageTexture.create_from_image(dst_img))

# func _on_dither_pressed():
# 	do_dither()

func save_to_png(path: String):
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

	dst_img.save_png(path)

	dithered_sprite.scale = og_scale

func _on_save_pressed():
	file_dialog.filters = ["*.png ; PNG Images"]
	file_dialog.title = "Save PNG"
	file_dialog.size = get_viewport_rect().size
	file_dialog.show()	

func _on_file_selected(path: String):
	file_dialog.hide()

	save_to_png(path)

func _on_control_uniform_value_changed(value: Variant, name: String):
	(dithered_sprite.material as ShaderMaterial).set_shader_parameter(name, value)

func _on_zoom_slider_value_changed(value: float):
	dithered_sprite.scale = Vector2.ONE * value

func _on_show_original_state_changed(pressed: bool):
	if pressed:
		_dither_material = dithered_sprite.material.duplicate()
		dithered_sprite.material = null
	else:
		dithered_sprite.material = _dither_material

func on_files_dropped(files: PackedStringArray):
	var file = files[0]
	load_texture(file, ImageTexture.create_from_image(Image.load_from_file(file)))
