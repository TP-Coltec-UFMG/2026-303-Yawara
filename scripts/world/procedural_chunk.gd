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
# Details enviados pelo usuario; arquivos otimizados para desempenho e bioma.
const DETAIL_FOLDERS := ["forest", "sertao", "pantanal", "geada"]
const DETAIL_FILES := [
    ["forest_leaf_01.png", "forest_leaf_02.png", "forest_fern_01.png", "forest_branch_01.png", "forest_bush_01.png", "forest_moss_rock_01.png"],
    ["sertao_dry_grass_01.png", "sertao_crack_01.png", "sertao_branch_01.png", "sertao_pebble_01.png", "sertao_bush_01.png", "sertao_cactus_01.png"],
    ["pantanal_wet_grass_01.png", "pantanal_mud_01.png", "pantanal_reed_01.png", "pantanal_puddle_01.png", "pantanal_flower_01.png"],
    ["geada_frost_01.png", "geada_grass_01.png", "geada_flower_01.png", "geada_twig_01.png", "geada_rock_01.png", "geada_bush_01.png"]
]
var ground_texture: Texture2D
var ground_grain_texture: Texture2D
var detail_textures: Array[Texture2D] = []
var ground_details: Array[Dictionary] = []

func setup(coord: Vector2i, biome: int, seed_value: int) -> void:
    texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
    chunk_coord = coord
    biome_index = clampi(biome, 0, BiomeDB.BIOMES.size() - 1)
    world_seed = seed_value
    position = Vector2(float(coord.x) * CHUNK_SIZE, float(coord.y) * CHUNK_SIZE)
    rng.seed = _mix_seed(coord, seed_value)
    _try_load_ground_texture()
    _try_load_ground_grain()
    _load_detail_textures()
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

# Camada de microtextura pixel art quase transparente, por bioma.
# Acrescenta riqueza ao solo sem criar objetos nem afetar colisao.
func _try_load_ground_grain() -> void:
    var grain_files := ["forest_grain.png", "sertao_grain.png", "pantanal_grain.png", "geada_grain.png"]
    var grain_path: String = "res://assets/sprites/regions/soil_details/%s" % grain_files[biome_index]
    ground_grain_texture = null
    if ResourceLoader.exists(grain_path):
        ground_grain_texture = load(grain_path) as Texture2D

func _load_detail_textures() -> void:
    detail_textures.clear()
    for file_name in DETAIL_FILES[biome_index]:
        var texture_path: String = "res://assets/sprites/ground_details/%s/%s" % [DETAIL_FOLDERS[biome_index], file_name]
        if ResourceLoader.exists(texture_path):
            var tex := load(texture_path) as Texture2D
            if tex != null:
                detail_textures.append(tex)

func _mix_seed(coord: Vector2i, seed_value: int) -> int:
    var mixed := seed_value
    mixed ^= coord.x * 73856093
    mixed ^= coord.y * 19349663
    mixed ^= biome_index * 83492791
    return abs(mixed)

func _generate_layout() -> void:
    lakes.clear()
    decoration_points.clear()
    ground_details.clear()
    var data: Dictionary = BiomeDB.get_biome(biome_index)

    # Lagos / brejos. O jogador pode atravessar, mas sofre penalidade de terreno.
    if rng.randf() < float(data["lake_chance"]):
        var lake_count := 1 if rng.randf() < 0.82 else 2
        for _i in range(lake_count):
            lakes.append({
                "center": Vector2(rng.randf_range(215.0, CHUNK_SIZE - 215.0), rng.randf_range(215.0, CHUNK_SIZE - 215.0)),
                "radius": rng.randf_range(85.0, 162.0)
            })

    # Decoração puramente visual: grama, folhas, pedras pequenas etc.
    for _i in range(0):
        decoration_points.append({
            "pos": Vector2(rng.randf_range(22.0, CHUNK_SIZE - 22.0), rng.randf_range(22.0, CHUNK_SIZE - 22.0)),
            "size": rng.randf_range(2.0, 7.0),
            "variant": rng.randi_range(0, 3)
        })

    # Decoração do terreno, sem colisão nem nós extras: leves, determinísticas
    # por semente e desenhadas abaixo dos objetos/animais.
    if not detail_textures.is_empty():
        for _detail_index in range(rng.randi_range(3, 5)):
            var p := Vector2(rng.randf_range(24.0, CHUNK_SIZE - 24.0), rng.randf_range(24.0, CHUNK_SIZE - 24.0))
            if is_local_point_in_water(p) or (position + p).distance_to(Vector2(480, 480)) < 135.0:
                continue
            var too_close := false
            for existing in ground_details:
                if p.distance_to(existing["position"]) < 180.0:
                    too_close = true
                    break
            if too_close:
                continue
            var variant := rng.randi_range(0, detail_textures.size() - 1)
            # Grama/folhas/decalques mais comuns, props maiores mais raros.
            if rng.randf() < 0.70:
                variant = rng.randi_range(0, mini(2, detail_textures.size() - 1))
            ground_details.append({
                "position": p,
                "variant": variant,
                "scale": rng.randf_range(0.48, 0.66),
                "opacity": rng.randf_range(0.74, 0.87)
            })

    # Árvores e rochas com colisão. Evitamos o interior dos lagos.
    var tree_count := rng.randi_range(0, 1)
    var rock_count := rng.randi_range(0, 1)
    # Variacao natural sem lotar a camera aproximada.

    for i in range(tree_count):
        var p := _random_land_point(20)
        if p.x < 0.0 or (position + p).distance_to(Vector2(480, 480)) < 110.0:
            continue
        var prop := PROP_SCENE.instantiate() as WorldProp
        prop.position = p
        add_child(prop)
        prop.configure("tree", biome_index, int(rng.randi()) + i)

    for i in range(rock_count):
        var p := _random_land_point(20)
        if p.x < 0.0 or (position + p).distance_to(Vector2(480, 480)) < 110.0:
            continue
        var rock := PROP_SCENE.instantiate() as WorldProp
        rock.position = p
        add_child(rock)
        rock.configure("rock", biome_index, int(rng.randi()) + i)

    # Frutas também existem naturalmente no chão: build vegana não precisa bater em árvore.
    var ground_fruit := rng.randi_range(1, 3)
    for _i in range(ground_fruit):
        var p := _random_land_point(12)
        if p.x < 0.0 or (position + p).distance_to(Vector2(480, 480)) < 110.0:
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
        var encounter_pos := _random_land_point(30)
        if encounter_pos.x < 0.0:
            encounter.queue_free()
            return
        encounter.position = encounter_pos
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

# Os tons do terreno e as margens usam formas orgânicas, nunca um grid visível.
func _draw() -> void:
    var data: Dictionary = BiomeDB.get_biome(biome_index)
    var ground: Color = data["ground"]
    if ground_texture != null:
        draw_texture_rect(ground_texture, Rect2(0.0, 0.0, CHUNK_SIZE + 2.0, CHUNK_SIZE + 2.0), true)
    else:
        draw_rect(Rect2(0.0, 0.0, CHUNK_SIZE + 2.0, CHUNK_SIZE + 2.0), ground)

    # A textura base já incorpora folhas, veios e variações tonais.
    # A antiga sobreposição de ruído foi removida para não poluir o piso.
    _draw_biome_transitions(ground)

    for placed in ground_details:
        var tex: Texture2D = detail_textures[int(placed["variant"])]
        var draw_size: Vector2 = tex.get_size() * float(placed["scale"])
        var center: Vector2 = placed["position"]
        draw_texture_rect(tex, Rect2(center - draw_size * 0.5, draw_size), false, Color(1.0, 1.0, 1.0, float(placed["opacity"])))

    for lake in lakes:
        _draw_lake(lake)


func _lake_polygon(center: Vector2, radius: float, factor: float) -> PackedVector2Array:
    var vertices := PackedVector2Array()
    var phase := float(chunk_coord.x * 17 + chunk_coord.y * 31) * 0.31 + center.x * 0.017
    for i in range(40):
        var angle := TAU * float(i) / 40.0
        var variation := 0.94 + sin(angle * 3.0 + phase) * 0.065 + sin(angle * 7.0 - phase * 1.5) * 0.034
        var stretch := Vector2(1.14, 0.85)
        vertices.append(center + Vector2.from_angle(angle) * radius * variation * factor * stretch)
    return vertices


func _draw_lake(lake: Dictionary) -> void:
    var center: Vector2 = lake["center"]
    var radius: float = float(lake["radius"])
    # Em vez de três círculos concêntricos, desenhamos água irregular
    # com margem úmida, profundidade e reflexos de céu.
    var bank_palette := [Color("#6e915f"), Color("#a98d5e"), Color("#6b9a73"), Color("#9eb7b6")]
    var mid_palette := [Color("#66b7a1"), Color("#6eb1a0"), Color("#62b4a9"), Color("#86b9c1")]
    var deep_palette := [Color("#4b8f8a"), Color("#5a9690"), Color("#4e958f"), Color("#71a5ad")]
    var bank: Color = bank_palette[biome_index]
    var mid: Color = mid_palette[biome_index]
    var deep: Color = deep_palette[biome_index]
    draw_colored_polygon(_lake_polygon(center, radius, 1.10), Color(bank, 0.82))
    draw_colored_polygon(_lake_polygon(center, radius, 1.035), mid)
    draw_colored_polygon(_lake_polygon(center, radius, 0.97), deep)
    draw_colored_polygon(_lake_polygon(center + Vector2(-5.0, 6.0), radius, 0.73), Color(mid, 0.42))
    draw_colored_polygon(_lake_polygon(center + Vector2(-radius * 0.13, -radius * 0.14), radius, 0.43), Color("#d7f1e4", 0.17))

    # Reflexos discretos e vegetação aquática, em estilo aconchegante e limpo.
    for i in range(2):
        var offset := Vector2(-radius * 0.24 + float(i) * radius * 0.28, -radius * 0.16 + float(i % 2) * 17.0)
        var a := center + offset
        draw_line(a, a + Vector2(radius * 0.17, -1.0), Color("#d8f2e8", 0.22), 2.0)
        draw_line(a + Vector2(8.0, 5.0), a + Vector2(radius * 0.09, 5.0), Color("#e5f7ef", 0.15), 2.0)
    if biome_index == 2 or biome_index == 0:
        for i in range(2):
            var angle := float(i) * 2.65 + center.x * 0.035
            var p := center + Vector2(cos(angle) * radius * 0.62, sin(angle) * radius * 0.48)
            draw_circle(p, 5.0, Color("#3d6f4f"))
            draw_circle(p + Vector2(-1.0, -1.0), 3.0, Color("#8cc27b"))
            draw_line(p, p + Vector2(5.0, -2.0), Color("#4d9e94"), 2.0)


# Bordas com curvas suaves; cada chunk chega à mesma cor no encontro de biomas.
func _draw_biome_transitions(ground_color: Color) -> void:
    var world := get_parent() as ProceduralWorld
    if world == null:
        return
    var fade_width := 150.0
    var steps := 12
    var directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
    for side in range(4):
        var other_index := world.biome_for_chunk(chunk_coord + directions[side])
        if other_index == biome_index:
            continue
        var other_color: Color = BiomeDB.get_biome(other_index)["ground"]
        var meeting_color := ground_color.lerp(other_color, 0.5)
        for step in range(steps):
            var t := float(step) / float(steps)
            var strength := 0.60 * pow(1.0 - t, 1.5)
            var inner := fade_width * float(step + 1) / float(steps)
            var outer := fade_width * float(step) / float(steps)
            var polygon := PackedVector2Array()
            for j in range(25):
                polygon.append(_edge_point(side, outer, float(j) / 24.0))
            for j in range(24, -1, -1):
                polygon.append(_edge_point(side, inner, float(j) / 24.0))
            draw_colored_polygon(polygon, Color(meeting_color, strength))


func _edge_point(side: int, distance: float, t: float) -> Vector2:
    var along := t * CHUNK_SIZE
    var wobble := sin(along * 0.013 + float(chunk_coord.x + chunk_coord.y)) * 13.0
    wobble += sin(along * 0.041 + float(chunk_coord.x * 5 - chunk_coord.y * 3)) * 3.5
    # A borda de fora é reta; a irregularidade aumenta para dentro do bioma.
    var depth := maxf(0.0, distance + wobble * minf(distance / 48.0, 1.0))
    match side:
        0: return Vector2(depth, along)
        1: return Vector2(CHUNK_SIZE - depth, along)
        2: return Vector2(along, depth)
        _: return Vector2(along, CHUNK_SIZE - depth)
