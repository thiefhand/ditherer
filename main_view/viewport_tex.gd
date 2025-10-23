extends TextureRect

@export var viewport: SubViewport

func _process(delta: float) -> void:
    viewport.size = size