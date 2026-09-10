class_name BuildPlayerPreview
extends Control

var levels: Dictionary = {}
var player_texture: Texture2D
var player_level := 1
var body_size := 1.0

func _ready() -> void:
    var paths := [
        "res://assets/sprites/player/player.png",
        "res://assets/sprites/player/base.png"
    ]
    for path in paths:
        if ResourceLoader.exists(path):
            player_texture = load(path) as Texture2D
            break
    queue_redraw()

func set_build(new_levels: Dictionary, new_player_level: int, new_body_size: float = 1.0) -> void:
    levels = new_levels.duplicate()
    player_level = new_player_level
    body_size = clampf(new_body_size, 0.60, 1.80)
    queue_redraw()

func _draw() -> void:
    var area := Rect2(Vector2(8.0, 8.0), size - Vector2(16.0, 16.0))
    draw_rect(area, Color("#43a549"))
    for y in range(int(area.position.y), int(area.end.y), 24):
        for x in range(int(area.position.x), int(area.end.x), 24):
            if (floori(float(x) / 24.0) + floori(float(y) / 24.0)) % 3 == 0:
                draw_circle(Vector2(x + 8, y + 10), 2.5, Color(0.20, 0.48, 0.22, 0.35))

    var center := size * Vector2(0.5, 0.53)
    if player_texture != null:
        var side := minf(size.x, size.y) * 0.56 * body_size
        draw_texture_rect(player_texture, Rect2(center - Vector2.ONE * side * 0.5, Vector2.ONE * side), false)
    else:
        _draw_placeholder_player(center)

    draw_string(ThemeDB.fallback_font, Vector2(size.x - 82.0, 28.0), "Nv. %d" % player_level, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color.WHITE)

func _draw_placeholder_player(center: Vector2) -> void:
    draw_set_transform(center, 0.0, Vector2.ONE * body_size)
    center = Vector2.ZERO
    if int(levels.get("dash", 0)) > 0:
        draw_colored_polygon(PackedVector2Array([center + Vector2(-12, -4), center + Vector2(-55, -30), center + Vector2(-34, 18)]), Color(0.27, 0.70, 0.94, 0.75))
        draw_colored_polygon(PackedVector2Array([center + Vector2(12, -4), center + Vector2(55, -30), center + Vector2(34, 18)]), Color(0.27, 0.70, 0.94, 0.75))
    if int(levels.get("resistance", 0)) > 0:
        draw_arc(center + Vector2(0, 3), 34.0, -2.7, -0.4, 20, Color("#976b4e"), 10.0)
    draw_circle(center, 28.0, Color("#e7d7a8"))
    draw_circle(center + Vector2(0, -7), 15.0, Color("#3b2d24"))
    if int(levels.get("critical", 0)) > 0:
        draw_colored_polygon(PackedVector2Array([center + Vector2(-15, -16), center + Vector2(-9, -45), center + Vector2(-2, -19)]), Color("#d6a34f"))
        draw_colored_polygon(PackedVector2Array([center + Vector2(15, -16), center + Vector2(9, -45), center + Vector2(2, -19)]), Color("#d6a34f"))
    if int(levels.get("damage", 0)) > 0:
        draw_line(center + Vector2(-21, 4), center + Vector2(-52, 20), Color("#fff0b6"), 7.0)
        draw_line(center + Vector2(21, 4), center + Vector2(52, 20), Color("#fff0b6"), 7.0)
    if int(levels.get("range", 0)) > 0:
        draw_polyline(PackedVector2Array([center + Vector2(17, 18), center + Vector2(39, 31), center + Vector2(57, 24), center + Vector2(72, 39)]), Color("#557a48"), 9.0)
    if int(levels.get("ancestral_shot", 0)) > 0:
        draw_circle(center + Vector2(48, -35), 8.0, Color("#ff6f2f"))
    if int(levels.get("attack_speed", 0)) > 0:
        draw_arc(center, 50.0, -2.4, -0.5, 16, Color(0.8, 0.95, 1.0, 0.65), 4.0)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
