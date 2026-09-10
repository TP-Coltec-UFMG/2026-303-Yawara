class_name ProceduralChunk
extends Node2D

const CHUNK_SIZE := 960.0
const PROP_SCENE := preload("res://scenes/world/world_prop.tscn")
const ENCOUNTER_SCENE := preload("res://scenes/world/encounter_point.tscn")
const FRUIT_SCENE := preload("res://scenes/world/fruit_pickup.tscn")

var chunk_coord := Vector2i.ZERO
var biome_index := 0
var world_seed := 0
var lakes: Array[Dictionary] = []
var decoration_points: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var ground_texture: Texture2D

func setup(coord: Vector2i, biome: int, seed_value: int) -> void:
    texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
    chunk_coord = coord
    biome_index = clampi(biome, 0, BiomeDB.BIOMES.size() - 1)
    world_seed = seed_value
    position = Vector2(float(coord.x) * CHUNK_SIZE, float(coord.y) * CHUNK_SIZE)
    rng.seed = _mix_seed(coord, seed_value)
    _try_load_ground_texture()
    _generate_layout()
    queue_redraw()

func _try_load_ground_texture() -> void:
    var ground_files: Array[String] = [
        "grande_floresta_ground.png",
        "sertao_ground.png",
        "pantanal_ground.png",
        "campos_geada_ground.png"
    ]
    var path := "res://assets/sprites/regions/%s" % ground_files[biome_index]
    if ResourceLoader.exists(path):
        ground_texture = load(path) as Texture2D

func _mix_seed(coord: Vector2i, seed_value: int) -> int:
    var mixed := seed_value
    mixed ^= coord.x * 73856093
    mixed ^= coord.y * 19349663
    mixed ^= biome_index * 83492791
    return abs(mixed)

func _generate_layout() -> void:
    var data: Dictionary = BiomeDB.get_biome(biome_index)

    # Lagos / brejos. O jogador pode atravessar, mas sofre penalidade de terreno.
    if rng.randf() < float(data["lake_chance"]):
        var lake_count := 1 if rng.randf() < 0.82 else 2
        for _i in range(lake_count):
            lakes.append({
                "center": Vector2(rng.randf_range(180.0, CHUNK_SIZE - 180.0), rng.randf_range(160.0, CHUNK_SIZE - 160.0)),
                "radius": rng.randf_range(85.0, 175.0)
            })

    # Decoração puramente visual: grama, folhas, pedras pequenas etc.
    for _i in range(rng.randi_range(24, 38)):
        decoration_points.append({
            "pos": Vector2(rng.randf_range(22.0, CHUNK_SIZE - 22.0), rng.randf_range(22.0, CHUNK_SIZE - 22.0)),
            "size": rng.randf_range(2.0, 7.0),
            "variant": rng.randi_range(0, 3)
        })

    # Árvores e rochas com colisão. Evitamos o interior dos lagos.
    var tree_count := rng.randi_range(7, 13)
    var rock_count := rng.randi_range(3, 7)
    if biome_index == 1:
        tree_count = rng.randi_range(5, 9)
    elif biome_index == 0 or biome_index == 3:
        tree_count += 3

    for i in range(tree_count):
        var p := _random_land_point(20)
        if p.x < 0.0:
            continue
        var prop := PROP_SCENE.instantiate() as WorldProp
        prop.position = p
        add_child(prop)
        prop.configure("tree", biome_index, int(rng.randi()) + i)

    for i in range(rock_count):
        var p := _random_land_point(20)
        if p.x < 0.0:
            continue
        var rock := PROP_SCENE.instantiate() as WorldProp
        rock.position = p
        add_child(rock)
        rock.configure("rock", biome_index, int(rng.randi()) + i)

    # Frutas também existem naturalmente no chão: build vegana não precisa bater em árvore.
    var ground_fruit := rng.randi_range(3, 6)
    for _i in range(ground_fruit):
        var p := _random_land_point(12)
        if p.x < 0.0:
            continue
        var fruit := FRUIT_SCENE.instantiate() as FruitPickup
        fruit.position = p
        add_child(fruit)
        var fruit_value := 1
        if rng.randf() < 0.025:
            fruit_value = 4
        elif rng.randf() < 0.12:
            fruit_value = 3
        elif rng.randf() < 0.28:
            fruit_value = 2
        fruit.configure(String(data["fruit"]), biome_index, fruit_value)

    # Pontos de encontro são raros o suficiente para incentivar exploração.
    var poi_chance := 0.33 if GameSession.selected_genetic == "pioneer" else 0.22
    if rng.randf() < poi_chance:
        var types := BiomeDB.POIS.keys()
        var encounter := ENCOUNTER_SCENE.instantiate() as EncounterPoint
        encounter.position = _random_land_point(30)
        add_child(encounter)
        encounter.configure(biome_index, String(types[rng.randi_range(0, types.size() - 1)]), int(rng.randi()))

func _random_land_point(attempts: int) -> Vector2:
    for _i in range(attempts):
        var p := Vector2(rng.randf_range(70.0, CHUNK_SIZE - 70.0), rng.randf_range(70.0, CHUNK_SIZE - 70.0))
        if not is_local_point_in_water(p):
            return p
    return Vector2(-1.0, -1.0)

func is_world_point_in_water(world_point: Vector2) -> bool:
    return is_local_point_in_water(to_local(world_point))

func is_local_point_in_water(local_point: Vector2) -> bool:
    for lake in lakes:
        if local_point.distance_to(lake["center"]) <= float(lake["radius"]):
            return true
    return false

func _draw() -> void:
    var data: Dictionary = BiomeDB.get_biome(biome_index)
    var ground: Color = data["ground"]
    var accent: Color = data["accent"]
    var detail: Color = data["detail"]
    if ground_texture != null:
        draw_texture_rect(ground_texture, Rect2(0.0, 0.0, CHUNK_SIZE + 2.0, CHUNK_SIZE + 2.0), true)
    else:
        draw_rect(Rect2(0.0, 0.0, CHUNK_SIZE + 2.0, CHUNK_SIZE + 2.0), ground)

    for decoration in decoration_points:
        var p: Vector2 = decoration["pos"]
        var s := float(decoration["size"])
        var variant := int(decoration["variant"])
        if variant == 0:
            draw_line(p - Vector2(0, s), p + Vector2(s * 0.45, s), Color(accent, 0.6), 2.0)
        elif variant == 1:
            draw_circle(p, s, Color(detail, 0.18))
        elif variant == 2:
            draw_line(p - Vector2(s, 0), p + Vector2(s, 0), Color(detail, 0.28), 2.0)
        else:
            draw_circle(p, maxf(1.0, s * 0.45), Color(accent.lightened(0.15), 0.40))

    # Camadas extras para cada bioma, inspiradas nos packs e na folha de bases.
    if biome_index == 0:
        for i in range(10):
            var leaf := Vector2(70.0 + float(i) * 82.0 + sin(float(i) + float(chunk_coord.y)) * 18.0, 80.0 + fmod(float(i * 67), CHUNK_SIZE - 120.0))
            draw_circle(leaf, 20.0, Color(accent.lightened(0.12), 0.10))
            draw_line(leaf + Vector2(-18, 0), leaf + Vector2(18, 6), Color(detail, 0.16), 2.0)
    elif biome_index == 1:
        for i in range(9):
            var y := 70.0 + float(i) * 95.0
            draw_polyline(PackedVector2Array([Vector2(48, y), Vector2(240, y + 18), Vector2(420, y - 12), Vector2(620, y + 10), Vector2(840, y - 16)]), Color(detail, 0.11), 2.0)
        for i in range(6):
            var stone := Vector2(110.0 + float(i) * 145.0 + float((chunk_coord.x + chunk_coord.y) % 9) * 4.0, 120.0 + fmod(float(i * 143), CHUNK_SIZE - 180.0))
            draw_circle(stone, 12.0, Color(ground.darkened(0.14), 0.18))
    elif biome_index == 2:
        for i in range(14):
            var reed := Vector2(60.0 + float(i) * 60.0, 75.0 + fmod(float(i * 47), CHUNK_SIZE - 100.0))
            draw_line(reed, reed + Vector2(0, 10 + (i % 3) * 8), Color(accent.lightened(0.15), 0.30), 2.0)
            draw_line(reed + Vector2(0, 2), reed + Vector2(-5, 9), Color(detail, 0.20), 1.0)
            draw_line(reed + Vector2(0, 4), reed + Vector2(5, 12), Color(detail, 0.20), 1.0)
        for i in range(5):
            var mud := Vector2(130.0 + float(i) * 170.0, 140.0 + fmod(float(i * 131), CHUNK_SIZE - 220.0))
            draw_circle(mud, 28.0, Color(ground.darkened(0.10), 0.18))
    elif biome_index == 3:
        for i in range(26):
            var spark := Vector2(40.0 + fmod(float(i * 73), CHUNK_SIZE - 80.0), 38.0 + fmod(float(i * 101), CHUNK_SIZE - 76.0))
            draw_circle(spark, 2.0 + float(i % 2), Color(detail.lightened(0.12), 0.45))
        for i in range(8):
            var grass := Vector2(88.0 + float(i) * 102.0, 120.0 + fmod(float(i * 117), CHUNK_SIZE - 180.0))
            draw_line(grass, grass + Vector2(-6, 12), Color(accent, 0.18), 2.0)
            draw_line(grass, grass + Vector2(0, 16), Color(detail, 0.15), 2.0)
            draw_line(grass, grass + Vector2(6, 11), Color(accent.lightened(0.05), 0.18), 2.0)

    for lake in lakes:
        var center: Vector2 = lake["center"]
        var radius := float(lake["radius"])
        draw_circle(center, radius, Color("#245c70"))
        draw_circle(center + Vector2(-radius * 0.18, -radius * 0.15), radius * 0.72, Color("#2f7184"))
        draw_arc(center, radius, 0.0, TAU, 48, Color("#78a9a5"), 4.0)
        for i in range(5):
            var a := TAU * float(i) / 5.0 + float(chunk_coord.x + chunk_coord.y)
            var lilypad := center + Vector2.from_angle(a) * radius * 0.55
            draw_circle(lilypad, 7.0, Color("#4f8a55"))

    # Grade de chunk quase invisível, útil para perceber que o mapa continua sem fim.
    draw_rect(Rect2(1, 1, CHUNK_SIZE - 2, CHUNK_SIZE - 2), Color(detail, 0.055), false, 2.0)
