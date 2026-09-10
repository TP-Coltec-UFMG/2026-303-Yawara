extends Node2D

var radius := 70.0
var life := 0.16
var total_life := 0.16
@onready var sprite: Sprite2D = $Sprite2D

func configure(new_radius: float) -> void:
    radius = new_radius
    var path := "res://assets/sprites/effects/slash.png"
    if ResourceLoader.exists(path):
        sprite.texture = load(path)
        var max_side := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
        sprite.scale = Vector2.ONE * ((radius * 2.2) / maxf(1.0, max_side))
    queue_redraw()

func _process(delta: float) -> void:
    life -= delta
    modulate.a = clampf(life / total_life, 0.0, 1.0)
    if life <= 0.0:
        queue_free()

func _draw() -> void:
    if sprite.texture != null:
        return
    draw_arc(Vector2.ZERO, radius, -0.72, 0.72, 24, Color("#fff1a8"), 9.0)
    draw_arc(Vector2.ZERO, radius - 9.0, -0.65, 0.65, 20, Color("#ffca63"), 3.0)
