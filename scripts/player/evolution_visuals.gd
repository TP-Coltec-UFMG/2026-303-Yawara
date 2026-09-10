class_name EvolutionVisuals
extends Node2D

const PART_DEFINITIONS := {
    "damage": {"path": "res://assets/sprites/player/parts/garras_tamandua.png", "z": 7},
    "attack_speed": {"path": "res://assets/sprites/player/parts/redemoinho_saci.png", "z": 2},
    "vitality": {"path": "res://assets/sprites/player/parts/vigor_capivara.png", "z": 2},
    "speed": {"path": "res://assets/sprites/player/parts/pes_curupira.png", "z": 7},
    "range": {"path": "res://assets/sprites/player/parts/cauda_sucuri.png", "z": 3},
    "dash": {"path": "res://assets/sprites/player/parts/asas_arara.png", "z": 2},
    "ancestral_shot": {"path": "res://assets/sprites/player/parts/fogo_boitata.png", "z": 8},
    "critical": {"path": "res://assets/sprites/player/parts/orelhas_onca.png", "z": 8},
    "heal_kill": {"path": "res://assets/sprites/player/parts/aura_iara.png", "z": 2},
    "resistance": {"path": "res://assets/sprites/player/parts/carapaca_tatu.png", "z": 3},
    "social_charm": {"path": "res://assets/sprites/player/parts/encanto_boto.png", "z": 8},
    "tiny": {"path": "res://assets/sprites/player/parts/leveza_mico.png", "z": 8},
    "giant": {"path": "res://assets/sprites/player/parts/corpo_queixada.png", "z": 3},
    "forager": {"path": "res://assets/sprites/player/parts/faro_mao_pelada.png", "z": 8},
    "adaptation": {"path": "res://assets/sprites/player/parts/casco_jabuti.png", "z": 3}
}

var active_levels: Dictionary = {}
var loaded_parts: Dictionary = {}

func _ready() -> void:
    z_index = 5

func set_upgrade_level(upgrade_id: String, level: int) -> void:
    active_levels[upgrade_id] = level
    if level > 0:
        _ensure_part(upgrade_id)
    queue_redraw()

func _ensure_part(upgrade_id: String) -> void:
    if loaded_parts.has(upgrade_id) or not PART_DEFINITIONS.has(upgrade_id):
        return
    var definition: Dictionary = PART_DEFINITIONS[upgrade_id]
    var path := String(definition["path"])
    if not ResourceLoader.exists(path):
        return
    var part := Sprite2D.new()
    part.name = "Part_%s" % upgrade_id
    part.texture = load(path) as Texture2D
    part.z_index = int(definition["z"])
    var max_side := float(maxi(part.texture.get_width(), part.texture.get_height()))
    part.scale = Vector2.ONE * (58.0 / maxf(1.0, max_side))
    add_child(part)
    loaded_parts[upgrade_id] = part

func _draw() -> void:
    for id_value in active_levels.keys():
        var upgrade_id := String(id_value)
        if int(active_levels[upgrade_id]) <= 0 or loaded_parts.has(upgrade_id):
            continue
        _draw_placeholder(upgrade_id, int(active_levels[upgrade_id]))

func _draw_placeholder(upgrade_id: String, level: int) -> void:
    var strength := clampf(float(level) / 5.0, 0.2, 1.0)
    match upgrade_id:
        "resistance":
            draw_arc(Vector2(0.0, 2.0), 25.0 + strength * 3.0, -2.75, -0.38, 18, Color("#9e7350"), 7.0)
        "critical":
            draw_colored_polygon(PackedVector2Array([Vector2(-13, -15), Vector2(-8, -34), Vector2(-1, -16)]), Color("#c89b4b"))
            draw_colored_polygon(PackedVector2Array([Vector2(13, -15), Vector2(8, -34), Vector2(1, -16)]), Color("#c89b4b"))
        "dash":
            draw_colored_polygon(PackedVector2Array([Vector2(-12, -7), Vector2(-43, -20), Vector2(-27, 9)]), Color(0.25, 0.68, 0.9, 0.70))
            draw_colored_polygon(PackedVector2Array([Vector2(12, -7), Vector2(43, -20), Vector2(27, 9)]), Color(0.25, 0.68, 0.9, 0.70))
        "damage":
            draw_line(Vector2(-18, 4), Vector2(-35 - level * 2, 13), Color("#d6c08a"), 5.0)
            draw_line(Vector2(18, 4), Vector2(35 + level * 2, 13), Color("#d6c08a"), 5.0)
        "range":
            draw_polyline(PackedVector2Array([Vector2(13, 13), Vector2(30, 22), Vector2(43, 18), Vector2(53 + level * 2, 28)]), Color("#557a48"), 8.0)
        "speed":
            draw_line(Vector2(-9, 18), Vector2(-15, 31), Color("#f07a32"), 5.0)
            draw_line(Vector2(9, 18), Vector2(15, 31), Color("#f07a32"), 5.0)
        "attack_speed":
            draw_arc(Vector2.ZERO, 33.0, -2.4, -0.6, 14, Color(0.75, 0.92, 1.0, 0.55), 3.0)
            draw_arc(Vector2.ZERO, 38.0, 0.7, 2.5, 14, Color(0.75, 0.92, 1.0, 0.42), 3.0)
        "ancestral_shot":
            draw_circle(Vector2(28, -19), 5.0 + strength * 2.0, Color("#ff6a2a"))
            draw_circle(Vector2(-28, -15), 4.0 + strength * 2.0, Color("#ffd052"))
        "heal_kill":
            draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 32, Color(0.25, 0.85, 0.95, 0.28), 4.0)
        "vitality":
            draw_arc(Vector2.ZERO, 28.0, 0.0, TAU, 32, Color(0.45, 0.92, 0.56, 0.23), 5.0)
        "social_charm":
            draw_circle(Vector2(0, -36), 7.0, Color(0.96, 0.45, 0.72, 0.72))
            draw_arc(Vector2.ZERO, 34.0, 3.5, 5.9, 18, Color(0.55, 0.85, 1.0, 0.42), 3.0)
        "tiny":
            draw_circle(Vector2(0, -30), 5.0, Color(0.93, 0.93, 0.72, 0.75))
            draw_line(Vector2(-18, -22), Vector2(-29, -33), Color(0.93, 0.93, 0.72, 0.55), 2.0)
        "giant":
            draw_arc(Vector2.ZERO, 34.0 + level * 2.0, 0.0, TAU, 30, Color(0.58, 0.35, 0.22, 0.52), 7.0)
        "forager":
            draw_circle(Vector2(-15, -27), 5.0, Color(0.56, 0.78, 0.48, 0.72))
            draw_circle(Vector2(15, -27), 5.0, Color(0.56, 0.78, 0.48, 0.72))
        "adaptation":
            draw_arc(Vector2.ZERO, 30.0, -2.8, -0.3, 18, Color(0.38, 0.64, 0.35, 0.65), 5.0)
