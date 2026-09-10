class_name EncounterPoint
extends Node2D

var biome_index := 0
var encounter_type := "community"
var encounter_name := "Ponto de Encontro"
var used := false
var player: Node2D
var pulse := 0.0

func _ready() -> void:
    add_to_group("encounter_points")
    z_index = 2
    queue_redraw()

func configure(biome: int, type_value: String, seed_value: int) -> void:
    biome_index = clampi(biome, 0, BiomeDB.BIOMES.size() - 1)
    encounter_type = type_value
    if BiomeDB.POIS.has(encounter_type):
        encounter_name = String(BiomeDB.POIS[encounter_type]["name"])
    else:
        var names: Array = BiomeDB.ENCOUNTER_NAMES.get(encounter_type, ["Ponto de Encontro"])
        encounter_name = String(names[abs(seed_value) % names.size()])
    queue_redraw()

func _process(delta: float) -> void:
    pulse += delta
    if used:
        return
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node2D
        return
    var distance := global_position.distance_to(player.global_position)
    if distance < 92.0 and Input.is_action_just_pressed("interact"):
        get_tree().call_group("game_world", "open_encounter", self)
    if distance < 180.0:
        queue_redraw()

func mark_used() -> void:
    used = true
    queue_redraw()

func _draw() -> void:
    var data: Dictionary = BiomeDB.get_biome(biome_index)
    var c: Color = data["detail"]
    if used:
        c = c.darkened(0.55)
    var r := 31.0 + sin(pulse * 2.0) * 2.0
    draw_circle(Vector2.ZERO, r, Color(c, 0.15))
    draw_arc(Vector2.ZERO, r, 0.0, TAU, 28, c, 3.0)
    match encounter_type:
        "community":
            draw_rect(Rect2(-20, -8, 40, 28), Color("#8f5b32"))
            draw_colored_polygon(PackedVector2Array([Vector2(-27,-8), Vector2(0,-32), Vector2(27,-8)]), Color("#b88945"))
            draw_circle(Vector2(0, 26), 7.0, Color("#ee8e37"))
        "shrine":
            draw_rect(Rect2(-11, -28, 22, 53), Color("#85816f"))
            draw_circle(Vector2(0, -29), 13.0, Color("#b0a875"))
            draw_circle(Vector2(0, -29), 5.0, c)
        _:
            draw_circle(Vector2(-14, 2), 15.0, Color("#4d7c49"))
            draw_circle(Vector2(11, -8), 18.0, Color("#5f934f"))
            draw_circle(Vector2(2, 14), 13.0, Color("#78a65f"))

    if not used and is_instance_valid(player) and global_position.distance_to(player.global_position) < 92.0:
        draw_string(ThemeDB.fallback_font, Vector2(-42, -48), "E  INTERAGIR", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#fff0b0"))
