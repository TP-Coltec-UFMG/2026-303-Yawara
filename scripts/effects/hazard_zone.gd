class_name HazardZone
extends Node2D

var radius := 64.0
var windup := 0.8
var damage := 16.0
var effect_id := "meteor"
var active_duration := 0.18
var tick_timer := 0.0
var has_hit := false
var color := Color("#d9a161")

func configure(new_radius: float, new_windup: float, new_damage: float, new_effect: String = "meteor", duration: float = 0.18) -> void:
    radius = new_radius
    windup = new_windup
    damage = new_damage
    effect_id = new_effect
    active_duration = duration
    if effect_id == "poison":
        color = Color("#9d80ba")
    elif effect_id == "root":
        color = Color("#a58c65")
    queue_redraw()

func _process(delta: float) -> void:
    if windup > 0.0:
        windup = maxf(0.0, windup - delta)
        queue_redraw()
        return
    active_duration -= delta
    tick_timer -= delta
    if tick_timer <= 0.0:
        tick_timer = 0.65
        _damage_player()
    queue_redraw()
    if active_duration <= 0.0: queue_free()

func _damage_player() -> void:
    var player := get_tree().get_first_node_in_group("player") as Player
    if not is_instance_valid(player) or global_position.distance_to(player.global_position) > radius: return
    if has_hit and effect_id != "poison":
        return
    if effect_id == "poison":
        player.take_poison_damage(damage)
    else:
        player.take_damage(damage)
    has_hit = true

func _draw() -> void:
    # Avisos de perigo em pixel art, pequenos e suaves, sem retículas vermelhas.
    var alpha := 0.34 if windup > 0.0 else 0.50
    var tile := 6.0
    var r := radius - 3.0
    var corners := [
        Vector2(-r, -r), Vector2(r, -r),
        Vector2(r, r), Vector2(-r, r)
    ]
    if windup > 0.0:
        # Contorno segmentado nas quatro esquinas; o interior fica livre.
        var tint := Color(color, alpha)
        for i in range(4):
            var corner: Vector2 = corners[i]
            var inward_x := 1.0 if corner.x < 0.0 else -1.0
            var inward_y := 1.0 if corner.y < 0.0 else -1.0
            draw_line(corner, corner + Vector2(inward_x * tile * 2.0, 0.0), tint, 2.0)
            draw_line(corner, corner + Vector2(0.0, inward_y * tile * 2.0), tint, 2.0)
        # Marcador discreto de tempo; não é um grande alvo preenchido.
        var progress := clampf(windup / 1.5, 0.0, 1.0)
        draw_rect(Rect2(Vector2(-13.0, r + 7.0), Vector2(26.0, 3.0)), Color(color, 0.13))
        draw_rect(Rect2(Vector2(-13.0, r + 7.0), Vector2(26.0 * (1.0 - progress), 3.0)), Color(color, 0.56))
    else:
        draw_circle(Vector2.ZERO, radius * 0.82, Color(color, 0.18))
        draw_arc(Vector2.ZERO, radius * 0.82, 0.0, TAU, 16, Color(color, 0.53), 2.0)
