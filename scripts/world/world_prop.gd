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
    var biome_data: Dictionary = BiomeDB.get_biome(biome_index)
    var file_name := prop_kind
    if prop_kind == "tree":
        file_name = String(biome_data["tree_kind"])
    var path := "res://assets/sprites/world/%s.png" % file_name
    if ResourceLoader.exists(path):
        sprite.texture = load(path) as Texture2D
        var target := 76.0 if prop_kind == "tree" else 48.0
        var max_side := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
        sprite.scale = Vector2.ONE * target / maxf(max_side, 1.0)

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
    if sprite.texture != null:
        return
    var alpha := 1.0
    if prop_kind == "rock":
        var c := Color("#77746d")
        c.a = alpha
        draw_colored_polygon(PackedVector2Array([Vector2(-25, 15), Vector2(-19, -12), Vector2(-3, -25), Vector2(22, -15), Vector2(27, 13), Vector2(7, 24)]), c)
        draw_line(Vector2(-13, -8), Vector2(10, 12), Color(0.22, 0.22, 0.21, alpha), 3.0)
        return

    var biome_data: Dictionary = BiomeDB.get_biome(biome_index)
    var trunk := Color("#60432d")
    trunk.a = alpha
    var crown: Color = biome_data["accent"]
    crown.a = alpha
    if biome_index == 1:
        # Forma seca/cacto para Caatinga.
        draw_line(Vector2(0, 25), Vector2(0, -34), crown, 9.0)
        draw_line(Vector2(0, -12), Vector2(-18, -23), crown, 7.0)
        draw_line(Vector2(0, 0), Vector2(18, -12), crown, 7.0)
    elif biome_index == 3:
        draw_line(Vector2(0, 26), Vector2(0, -42), trunk, 8.0)
        draw_colored_polygon(PackedVector2Array([Vector2(0, -51), Vector2(-32, -10), Vector2(32, -10)]), crown)
        draw_colored_polygon(PackedVector2Array([Vector2(0, -34), Vector2(-26, 3), Vector2(26, 3)]), crown.darkened(0.08))
    else:
        draw_line(Vector2(0, 27), Vector2(0, -22), trunk, 9.0)
        draw_circle(Vector2(-14, -28), 23.0, crown)
        draw_circle(Vector2(14, -29), 24.0, crown.lightened(0.05))
        draw_circle(Vector2(0, -44), 24.0, crown.darkened(0.05))
