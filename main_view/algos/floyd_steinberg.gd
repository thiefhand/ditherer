extends Algo
class_name FloydSteinberg

@export_range(1, 10, 1) var steps: int = 1

func get_display_name() -> String:
	return "Floyd-Steinberg"

func dither(image: Image) -> Image:
	var working_image = image.duplicate()
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var src_color = working_image.get_pixel(x, y)
			var quant_color = quantize_color(src_color, steps)
			var error = src_color - quant_color

			working_image.set_pixel(x, y, quant_color)
			adjust_pixel(working_image, x - 1, y + 1, error * (3.0 / 16.0))
			adjust_pixel(working_image, x - 0, y + 1, error * (5.0 / 16.0))
			adjust_pixel(working_image, x + 1, y + 1, error * (1.0 / 16.0))
			adjust_pixel(working_image, x + 1, y + 0, error * (7.0 / 16.0))
	
	return working_image