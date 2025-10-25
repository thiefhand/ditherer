extends Algo
class_name Bayer4

const MATRIX = [
	0, 12, 3, 15,
	8, 4, 11, 7,
	2, 14, 1, 13,
	10, 6, 9, 5
]

@export_range(0, 1, 0.05) var dither_weight: float = 0.2
@export_range(0, 3, 0.05) var exposure: float = 1.0
@export_range(0, 2, 0.05) var contrast: float = 1.0
@export_range(1, 24, 1) var steps: int = 1

func get_display_name() -> String:
	return "Bayer 4x4"

func dither(image: Image) -> Image:
	var working_image = image.duplicate()
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var mat_sample = (MATRIX[(y % 4) * 4 + (x % 4)] / 16.0) * 2.0 - 1.0
			var src_color: Color = image.get_pixel(x, y)
			src_color = src_color * exposure
			src_color = Color(
				pow(src_color.r, contrast),
				pow(src_color.g, contrast),
				pow(src_color.b, contrast),
				src_color.a
			)

			var dst_color = Color(
				quantize(src_color.r + mat_sample * dither_weight, steps),
				quantize(src_color.g + mat_sample * dither_weight, steps),
				quantize(src_color.b + mat_sample * dither_weight, steps),
				src_color.a
			)
			working_image.set_pixel(x, y, dst_color)

	return working_image
