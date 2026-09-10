class_name ProceduralWorld
extends Node2D

const CHUNK_SCENE := preload("res://scenes/world/procedural_chunk.tscn")
const CHUNK_SIZE := ProceduralChunk.CHUNK_SIZE
const LOAD_RADIUS := 2
const BIOME_SITE_SPACING := 3.0

var world_seed := 0
var loaded_chunks: Dictionary = {}
var player: Node2D
var refresh_timer := 0.0

func _ready() -> void:
    world_seed = int(Time.get_unix_time_from_system()) ^ int(Time.get_ticks_usec())
    _ensure_chunks_around(Vector2(480.0, 480.0))

func set_player(new_player: Node2D) -> void:
    player = new_player
    _ensure_chunks_around(player.global_position)

func _process(delta: float) -> void:
    if not is_instance_valid(player):
        return
    refresh_timer -= delta
    if refresh_timer <= 0.0:
        refresh_timer = 0.45
        _ensure_chunks_around(player.global_position)

func world_to_chunk(world_position: Vector2) -> Vector2i:
    return Vector2i(floori(world_position.x / CHUNK_SIZE), floori(world_position.y / CHUNK_SIZE))

func biome_for_chunk(coord: Vector2i) -> int:
    # Biomas são definidos por células de Voronoi procedurais. Isso gera manchas
    # irregulares e contínuas, evitando um mapa com cinco quadrados fixos.
    var site_cell := Vector2i(
        floori(float(coord.x) / BIOME_SITE_SPACING),
        floori(float(coord.y) / BIOME_SITE_SPACING)
    )
    var best_distance := 1.0e20
    var selected_biome := 0
    var chunk_center := Vector2(float(coord.x) + 0.5, float(coord.y) + 0.5)
    for sy in range(site_cell.y - 1, site_cell.y + 2):
        for sx in range(site_cell.x - 1, site_cell.x + 2):
            var cell := Vector2i(sx, sy)
            var rng := RandomNumberGenerator.new()
            rng.seed = _site_seed(cell)
            var site_position := Vector2(
                (float(sx) + rng.randf_range(0.12, 0.88)) * BIOME_SITE_SPACING,
                (float(sy) + rng.randf_range(0.12, 0.88)) * BIOME_SITE_SPACING
            )
            var site_biome := rng.randi_range(0, BiomeDB.BIOMES.size() - 1)
            var distance := chunk_center.distance_squared_to(site_position)
            if distance < best_distance:
                best_distance = distance
                selected_biome = site_biome
    return selected_biome

func _site_seed(cell: Vector2i) -> int:
    var mixed := world_seed
    mixed ^= cell.x * 73856093
    mixed ^= cell.y * 19349663
    mixed ^= (cell.x - cell.y) * 83492791
    return abs(mixed)

func get_biome_at(world_position: Vector2) -> int:
    var coord := world_to_chunk(world_position)
    if loaded_chunks.has(coord):
        var chunk: ProceduralChunk = loaded_chunks[coord]
        return chunk.biome_index
    return biome_for_chunk(coord)

func is_water_at(world_position: Vector2) -> bool:
    var coord := world_to_chunk(world_position)
    if loaded_chunks.has(coord):
        var chunk: ProceduralChunk = loaded_chunks[coord]
        return chunk.is_world_point_in_water(world_position)
    return false

func get_environment_at(world_position: Vector2) -> Dictionary:
    var biome := get_biome_at(world_position)
    return {
        "biome": biome,
        "water": is_water_at(world_position),
        "base_terrain": float(BiomeDB.get_biome(biome)["base_terrain"])
    }

func random_land_position_near(origin: Vector2, min_distance: float, max_distance: float) -> Vector2:
    for _attempt in range(24):
        var p := origin + Vector2.from_angle(randf_range(0.0, TAU)) * randf_range(min_distance, max_distance)
        _ensure_chunks_around(p)
        if not is_water_at(p):
            return p
    return origin + Vector2.RIGHT * min_distance

func random_water_position_near(origin: Vector2, min_distance: float, max_distance: float, required_biome: int = -1) -> Vector2:
    for _attempt in range(48):
        var point := origin + Vector2.from_angle(randf_range(0.0, TAU)) * randf_range(min_distance, max_distance)
        _ensure_chunks_around(point)
        if is_water_at(point) and (required_biome < 0 or get_biome_at(point) == required_biome):
            return point
    return random_land_position_near(origin, min_distance, max_distance)

func _ensure_chunks_around(world_position: Vector2) -> void:
    var center := world_to_chunk(world_position)
    var needed: Dictionary = {}
    for y in range(center.y - LOAD_RADIUS, center.y + LOAD_RADIUS + 1):
        for x in range(center.x - LOAD_RADIUS, center.x + LOAD_RADIUS + 1):
            var coord := Vector2i(x, y)
            needed[coord] = true
            if not loaded_chunks.has(coord):
                _load_chunk(coord)

    var to_remove: Array[Vector2i] = []
    for key in loaded_chunks.keys():
        var coord: Vector2i = key
        if not needed.has(coord):
            to_remove.append(coord)
    for coord in to_remove:
        var chunk: ProceduralChunk = loaded_chunks[coord]
        loaded_chunks.erase(coord)
        if is_instance_valid(chunk):
            chunk.queue_free()

func _load_chunk(coord: Vector2i) -> void:
    var chunk := CHUNK_SCENE.instantiate() as ProceduralChunk
    add_child(chunk)
    chunk.setup(coord, biome_for_chunk(coord), world_seed)
    loaded_chunks[coord] = chunk
