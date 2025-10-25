extends Algo
class_name Bayer16

const MATRIX = [
	0, 128, 32, 160, 8, 136, 40, 168, 2, 130, 34, 162, 10, 138, 42, 170,
	192, 64, 224, 96, 200, 72, 232, 104, 194, 66, 226, 98, 202, 74, 234, 106,
	48, 176, 16, 144, 56, 184, 24, 152, 50, 178, 18, 146, 58, 186, 26, 154,
	240, 112, 208, 80, 248, 120, 216, 88, 242, 114, 210, 82, 250, 122, 218, 90,
	12, 140, 44, 172, 4, 132, 36, 164, 14, 142, 46, 174, 6, 134, 38, 166,
	204, 76, 236, 108, 196, 68, 228, 100, 206, 78, 238, 110, 198, 70, 230, 102,
	60, 188, 28, 156, 52, 180, 20, 148, 62, 190, 30, 158, 54, 182, 22, 150,
	252, 124, 220, 92, 244, 116, 212, 84, 254, 126, 222, 94, 246, 118, 214, 86,
	3, 131, 35, 163, 11, 139, 43, 171, 1, 129, 33, 161, 9, 137, 41, 169,
	195, 67, 227, 99, 203, 75, 235, 107, 193, 65, 225, 97, 201, 73, 233, 105,
	51, 179, 19, 147, 59, 187, 27, 155, 49, 177, 17, 145, 57, 185, 25, 153,
	243, 115, 211, 83, 251, 123, 219, 91, 241, 113, 209, 81, 249, 121, 217, 89,
	15, 143, 47, 175, 7, 135, 39, 167, 13, 141, 45, 173, 5, 133, 37, 165,
	207, 79, 239, 111, 199, 71, 231, 103, 205, 77, 237, 109, 197, 69, 229, 101,
	63, 191, 31, 159, 55, 183, 23, 151, 61, 189, 29, 157, 53, 181, 21, 149,
	255, 127, 223, 95, 247, 119, 215, 87, 253, 125, 221, 93, 245, 117, 213, 85
]


@export_range(0, 1, 0.05) var dither_weight: float = 0.2
@export_range(0, 3, 0.05) var exposure: float = 1.0
@export_range(0, 2, 0.05) var contrast: float = 1.0
@export_range(1, 24, 1) var steps: int = 1

func get_display_name() -> String:
	return "Bayer 16x16"

func quantize(value: float, steps: float) -> float:
	return floor(value * steps) / steps

func dither(image: Image) -> Image:
	var working_image = image.duplicate()
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var mat_sample = (MATRIX[(y % 16) * 16 + (x % 16)] / 256.0) * 2.0 - 1.0
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
