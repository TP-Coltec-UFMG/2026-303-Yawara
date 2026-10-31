class_name BuildPlayerPreview
extends Control

var levels: Dictionary = {}
var player_texture: Texture2D
var player_level := 1
var body_size := 1.0

func _ready() -> void:
    _load_default_player_preview()
    queue_redraw()

func _load_default_player_preview() -> void:
    # A tela de build deve mostrar um frame real do personagem, nao a
    # spritesheet/fallback de 16x16 usada apenas por compatibilidade.
    var frames_path := "res://assets/animations/player.tres"
    if ResourceLoader.exists(frames_path):
        var frames := load(frames_path) as SpriteFrames
        if frames != null:
            var animation := "idle_right"
            if not frames.has_animation(animation):
                var names := frames.get_animation_names()
                if not names.is_empty():
                    animation = String(names[0])
            if frames.has_animation(animation) and frames.get_frame_count(animation) > 0:
                player_texture = frames.get_frame_texture(animation, 0)
                if player_texture != null:
                    return

    var paths := [
        "res://assets/sprites/player/player.png",
        "res://assets/sprites/player/base.png"
    ]
    for path in paths:
        if ResourceLoader.exists(path):
            player_texture = load(path) as Texture2D
            break

func set_player_visual(player: Player) -> void:
    # Usa exatamente os SpriteFrames ativos no player. Assim, trocar o sprite
    # do personagem tambem atualiza a foto mostrada em TAB/C.
    if is_instance_valid(player) and is_instance_valid(player.animated_sprite) and player.animated_sprite.sprite_frames != null:
        var frames := player.animated_sprite.sprite_frames
        var animation := "idle_right"
        if not frames.has_animation(animation):
            animation = String(player.animated_sprite.animation)
        if frames.has_animation(animation) and frames.get_frame_count(animation) > 0:
            var texture := frames.get_frame_texture(animation, 0)
            if texture != null:
                player_texture = texture
    queue_redraw()

func set_build(new_levels: Dictionary, new_player_level: int, new_body_size: float = 1.0) -> void:
    levels = new_levels.duplicate()
    player_level = new_player_level
    body_size = clampf(new_body_size, 0.60, 1.80)
    queue_redraw()

func _draw() -> void:
    var area := Rect2(Vector2(8.0, 8.0), size - Vector2(16.0, 16.0))
    draw_rect(area, Color("#17392f"))
    var spotlight := size * Vector2(0.5, 0.56)
    for ring in range(9, 0, -1):
        draw_circle(spotlight, float(ring) * 14.0, Color(0.24, 0.61, 0.43, 0.025))
    draw_arc(spotlight, minf(size.x, size.y) * 0.36, 0.0, TAU, 72, Color(Color("#cbaa67"), 0.55), 2.0, true)

    var center := size * Vector2(0.5, 0.53)
    if player_texture != null:
        # Mantem a proporcao original. Antes a textura era forcada em um
        # quadrado, deixando a foto achatada/esticada.
        var texture_size := player_texture.get_size()
        var max_width := size.x * 0.68 * body_size
        var max_height := size.y * 0.72 * body_size
        var fit := minf(max_width / maxf(1.0, texture_size.x), max_height / maxf(1.0, texture_size.y))
        var draw_size := texture_size * fit
        var draw_rect := Rect2(center - draw_size * 0.5, draw_size)
        draw_texture_rect(player_texture, draw_rect, false)
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
