class_name WorldProp
extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var prop_kind := "tree"
var biome_index := 0
var fruit_timer := 18.0
var local_seed := 0

func _ready() -> void:
    add_to_group("world_props")
    # Arvores e pedras sao elementos permanentes do mapa, nao alvos de ataque.
    collision_layer = 4
    collision_mask = 0
    queue_redraw()

func configure(kind: String, biome: int, seed_value: int) -> void:
    prop_kind = kind
    biome_index = clampi(biome, 0, BiomeDB.BIOMES.size() - 1)
    local_seed = seed_value
    var shape := collision_shape.shape.duplicate() as CircleShape2D
    if prop_kind == "rock":
        shape.radius = 22.0
    else:
        shape.radius = 18.0
        fruit_timer = 10.0 + float(abs(seed_value) % 180) / 10.0
    collision_shape.shape = shape
    _try_load_sprite()
    queue_redraw()

func _try_load_sprite() -> void:
    # Remove completamente os antigos sprites de arvores e rochas.
    # Props funcionais agora usam EXCLUSIVAMENTE os recursos novos do bioma.
    const DECOR_VARIANTS = [
        ["forest_bush_01.png", "forest_moss_rock_01.png"],
        ["sertao_bush_01.png", "sertao_pebble_01.png"],
        ["pantanal_reed_01.png", "pantanal_mud_01.png"],
        ["geada_bush_01.png", "geada_rock_01.png"]
    ]
    var folder: String = ["forest", "sertao", "pantanal", "geada"][biome_index]
    var file_name: String = DECOR_VARIANTS[biome_index][0 if prop_kind == "tree" else 1]
    var path := "res://assets/sprites/ground_details/%s/%s" % [folder, file_name]
    if ResourceLoader.exists(path):
        sprite.texture = load(path) as Texture2D
    else:
        sprite.texture = null
    if sprite.texture != null:
        var target := 57.0 if prop_kind == "tree" else 32.0
        var max_side := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
        sprite.scale = Vector2.ONE * (target / maxf(max_side, 1.0))


func _physics_process(delta: float) -> void:
    if prop_kind != "tree":
        return
    fruit_timer -= delta
    if fruit_timer <= 0.0:
        fruit_timer = 20.0 + float(abs(local_seed + Time.get_ticks_msec()) % 140) / 10.0
        var player := get_tree().get_first_node_in_group("player")
        if is_instance_valid(player) and global_position.distance_to(player.global_position) < 950.0:
            _drop_fruit(1)

func take_damage(_amount: float) -> void:
    # Mantido apenas por compatibilidade com chamadas antigas. Props nao quebram.
    return

func _drop_fruit(count: int) -> void:
    var data: Dictionary = BiomeDB.get_biome(biome_index)
    for i in range(count):
        var offset := Vector2.from_angle(randf_range(0.0, TAU)) * randf_range(24.0, 58.0)
        var value := 1
        if randf() < 0.02:
            value = 4
        elif randf() < 0.10:
            value = 3
        elif randf() < 0.24:
            value = 2
        get_tree().call_group("game_world", "spawn_fruit", global_position + offset, String(data["fruit"]), biome_index, value)

func _draw() -> void:
    # Sombra suave embaixo de cada sprite: dá profundidade sem mudar colisões.
    draw_set_transform(Vector2(0.0, 16.0), 0.0, Vector2(1.0, 0.28))
    draw_circle(Vector2.ZERO, 29.0 if prop_kind == "tree" else 22.0, Color(0.015, 0.035, 0.026, 0.29))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    # Sem formas antigas desenhadas se um PNG estiver ausente.
    return
