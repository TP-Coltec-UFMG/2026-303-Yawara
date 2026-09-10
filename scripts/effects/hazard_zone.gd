class_name HazardZone
extends Node2D

var radius := 64.0
var windup := 0.8
var damage := 16.0
var effect_id := "meteor"
var active_duration := 0.18
var tick_timer := 0.0
var has_hit := false
var color := Color("#ef5d50")

func configure(new_radius: float, new_windup: float, new_damage: float, new_effect: String = "meteor", duration: float = 0.18) -> void:
    radius = new_radius
    windup = new_windup
    damage = new_damage
    effect_id = new_effect
    active_duration = duration
    if effect_id == "poison":
        color = Color("#9a54c7")
    elif effect_id == "root":
        color = Color("#8d693d")
    queue_redraw()

func _process(delta: float) -> void:
    if windup > 0.0:
        windup -= delta
        queue_redraw()
        return
    active_duration -= delta
    tick_timer -= delta
    if tick_timer <= 0.0:
        tick_timer = 0.45
        _damage_player()
    queue_redraw()
    if active_duration <= 0.0: queue_free()

func _damage_player() -> void:
    var player := get_tree().get_first_node_in_group("player") as Player
    if not is_instance_valid(player) or global_position.distance_to(player.global_position) > radius: return
    if effect_id == "poison":
        player.take_poison_damage(damage)
    else:
        player.take_damage(damage)
    has_hit = true

func _draw() -> void:
    if windup > 0.0:
        var pulse := 0.18 + sin(Time.get_ticks_msec() * 0.012) * 0.05
        draw_circle(Vector2.ZERO, radius, Color(color, pulse))
        draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(color, 0.95), 3.0)
        draw_line(Vector2(-radius * 0.6, 0), Vector2(radius * 0.6, 0), Color(color, 0.8), 2.0)
        draw_line(Vector2(0, -radius * 0.6), Vector2(0, radius * 0.6), Color(color, 0.8), 2.0)
    else:
        draw_circle(Vector2.ZERO, radius, Color(color, 0.55))
        draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color.WHITE, 4.0)
