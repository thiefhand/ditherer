extends Algo
class_name GoofyGreenAlgo

@export_range(0, 2, 0.1) var greenness: float = 0

func get_display_name() -> String:
    return "Goofy Green"

func dither(image: Image) -> Image:
    var working_image = image.duplicate()
    for x in range(image.get_width()):
        for y in range(image.get_height()):
            var src_color: Color = image.get_pixel(x, y)

            src_color.g += greenness

            working_image.set_pixel(x, y, src_color)

    return working_image