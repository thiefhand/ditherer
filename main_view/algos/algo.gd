extends Resource
class_name Algo

func quantize(value: float, steps: float) -> float:
	return floor(value * steps) / steps

func quantize_color(color: Color, steps: float) -> Color:
	return Color(
		quantize(color.r, steps),
		quantize(color.g, steps),
		quantize(color.b, steps),
		color.a
	)

func quantize_bw_color(color: Color) -> Color:
	if color.r + color.g + color.b > 1.5:
		return Color.WHITE
	else:
		return Color.BLACK

func bw_color(color: Color) -> Color:
	return Color(
		(color.r + color.g + color.b) / 3.0,
		(color.r + color.g + color.b) / 3.0,
		(color.r + color.g + color.b) / 3.0,
		color.a
	)

func adjust_pixel(image: Image, x: int, y: int, amount: Color):
	if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
		image.set_pixel(x, y, image.get_pixel(x, y) + amount)

func get_display_name() -> String:
	return "Algo"

func dither(image: Image) -> Image:
	return image