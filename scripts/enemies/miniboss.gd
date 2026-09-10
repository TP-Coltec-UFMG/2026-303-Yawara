class_name BiomeMiniboss
extends CharacterBody2D

signal defeated(biome_index: int)

# Recortes provisórios das artes enviadas. Um PNG transparente com o nome
# normal do Guardiao sempre tem prioridade sobre estas folhas-fonte.
const GUARDIAN_SHEETS := {
    "mapinguari": {
        "path":"res://assets/sprites/miniboss/source_guardians/mapinguari_sheet.jpeg",
        "region":Rect2(24, 30, 210, 205), "frames":4, "step_x":256.0, "fps":7.0,
        "key":Color("#41444b"), "tolerance":0.11, "checker":false
    },
    "minhocao": {
        "path":"res://assets/sprites/miniboss/source_guardians/minhocao_sheet.jpeg",
        "region":Rect2(0, 45, 170, 250), "frames":6, "step_x":170.0, "fps":6.0,
        "key":Color("#f6f6f6"), "tolerance":0.10, "checker":false
    },
    "teiniagua": {
        "path":"res://assets/sprites/miniboss/source_guardians/teiniagua_sheet.jpeg",
        "region":Rect2(0, 40, 120, 235), "frames":6, "step_x":120.0, "fps":7.0,
        "key":Color.WHITE, "tolerance":0.10, "checker":true
    },
    "cabra_cabriola": {
        "path":"res://assets/sprites/miniboss/source_guardians/cabra_cabriola_sheet.jpeg",
        "region":Rect2(0, 35, 120, 225), "frames":6, "step_x":119.5, "fps":7.0,
        "key":Color("#a0a2ae"), "tolerance":0.14, "checker":false
    },
    "corpo_seco": {
        "path":"res://assets/sprites/miniboss/source_guardians/corpo_seco_sheet.jpeg",
        "region":Rect2(0, 0, 120, 245), "frames":6, "step_x":119.5, "fps":7.0,
        "key":Color("#a1a8b2"), "tolerance":0.14, "checker":false
    }
}

@onready var health: HealthComponent = $HealthComponent
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var player: Player
var biome_index := 0
var boss_id := "mapinguari"
var boss_name := "Guardião Ancestral"
var power_name := "Poder Ancestral"
var attack_pattern := "poison"
var move_speed := 105.0
var contact_damage := 18.0
var attack_timer := 0.0
var special_timer := 2.4
var flash_time := 0.0
var difficulty := 1.0
var guardian_atlas: AtlasTexture
var guardian_walk_frames: Array[Rect2] = []
var guardian_frame_index := 0
var guardian_frame_timer := 0.0
var guardian_frame_duration := 0.14

func _ready() -> void:
    add_to_group("enemies")
    add_to_group("minibosses")
    health.died.connect(_on_died)
    player = get_tree().get_first_node_in_group("player") as Player

func configure(biome: int, difficulty_value: float, new_boss_id: String = "") -> void:
    biome_index = clampi(biome, 0, BiomeDB.BIOMES.size() - 1)
    difficulty = maxf(1.0, difficulty_value)
    boss_id = new_boss_id if BiomeDB.MINIBOSSES.has(new_boss_id) else BiomeDB.choose_miniboss_for_biome(biome_index)
    var data: Dictionary = BiomeDB.get_miniboss(boss_id)
    boss_name = String(data["name"])
    power_name = String(data["power"])
    attack_pattern = String(data["pattern"])
    health.setup(460.0 + 120.0 * difficulty)
    move_speed = 96.0 + 9.0 * difficulty
    contact_damage = (15.0 + 2.6 * difficulty) * GameSession.pressure_multiplier("enemy_damage")
    var shape := collision_shape.shape.duplicate() as CircleShape2D
    shape.radius = 31.0
    collision_shape.shape = shape
    _try_load_sprite()
    queue_redraw()

func _try_load_sprite() -> void:
    var path := "res://assets/sprites/miniboss/%s.png" % boss_id
    if ResourceLoader.exists(path):
        guardian_atlas = null
        guardian_walk_frames.clear()
        sprite.material = null
        sprite.texture = load(path) as Texture2D
        var max_side := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
        sprite.scale = Vector2.ONE * (82.0 / maxf(1.0, max_side))
        return
    _load_source_guardian()

func _load_source_guardian() -> void:
    if not GUARDIAN_SHEETS.has(boss_id):
        return
    var definition: Dictionary = GUARDIAN_SHEETS[boss_id]
    var path := String(definition["path"])
    if not ResourceLoader.exists(path):
        return

    guardian_atlas = AtlasTexture.new()
    guardian_atlas.atlas = load(path) as Texture2D
    var region: Rect2 = definition["region"]
    guardian_walk_frames.clear()
    var frame_count := int(definition.get("frames", 1))
    var step_x := float(definition.get("step_x", region.size.x))
    for frame_index in range(frame_count):
        var frame_region := region
        frame_region.position.x += step_x * float(frame_index)
        guardian_walk_frames.append(frame_region)
    guardian_frame_index = 0
    guardian_frame_duration = 1.0 / maxf(1.0, float(definition.get("fps", 7.0)))
    guardian_frame_timer = guardian_frame_duration
    guardian_atlas.region = guardian_walk_frames[0]
    sprite.texture = guardian_atlas
    var max_side := maxf(region.size.x, region.size.y)
    sprite.scale = Vector2.ONE * (105.0 / maxf(1.0, max_side))
    sprite.position.y = -9.0

    var shader_path := "res://assets/shaders/guardian_chroma_key.gdshader"
    if ResourceLoader.exists(shader_path):
        var shader_material := ShaderMaterial.new()
        shader_material.shader = load(shader_path) as Shader
        shader_material.set_shader_parameter("key_color", definition["key"])
        shader_material.set_shader_parameter("tolerance", float(definition["tolerance"]))
        shader_material.set_shader_parameter("remove_checkerboard", bool(definition["checker"]))
        sprite.material = shader_material

func _physics_process(delta: float) -> void:
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Player
        return
    attack_timer = maxf(0.0, attack_timer - delta)
    special_timer -= delta
    flash_time = maxf(0.0, flash_time - delta)

    var distance := global_position.distance_to(player.global_position)
    velocity = global_position.direction_to(player.global_position) * move_speed
    _update_guardian_animation(delta)
    move_and_slide()
    if distance < 54.0 and attack_timer <= 0.0:
        attack_timer = 0.72
        player.take_damage(contact_damage)
    if special_timer <= 0.0:
        special_timer = randf_range(2.4, 3.4)
        _special_attack()
    queue_redraw()

func _update_guardian_animation(delta: float) -> void:
    if guardian_atlas == null or guardian_walk_frames.size() <= 1:
        return
    guardian_frame_timer -= delta
    if guardian_frame_timer <= 0.0:
        guardian_frame_timer += guardian_frame_duration
        guardian_frame_index = (guardian_frame_index + 1) % guardian_walk_frames.size()
        guardian_atlas.region = guardian_walk_frames[guardian_frame_index]
    if absf(velocity.x) > 1.0:
        sprite.flip_h = velocity.x < 0.0

func _special_attack() -> void:
    match attack_pattern:
        "poison":
            _radial(8, 270.0, 9.0, "poison")
        "fire":
            _radial(6, 360.0, 11.0)
        "wave":
            # Impacto físico perto do mini-chefe.
            if global_position.distance_to(player.global_position) < 150.0:
                player.take_damage(13.0)
            get_tree().call_group("game_world", "spawn_melee_effect", global_position, Vector2.RIGHT, 135.0)
        "roots":
            _aimed(3, 420.0, 12.0)
        "spirits":
            _radial(10, 325.0, 10.0)

func _radial(count: int, speed: float, damage: float, effect_id: String = "") -> void:
    for i in range(count):
        var dir := Vector2.from_angle(TAU * float(i) / float(count) + randf_range(-0.08, 0.08))
        get_tree().call_group("game_world", "spawn_boss_projectile", global_position + dir * 28.0, dir, speed, damage, 6.0, effect_id)

func _aimed(count: int, speed: float, damage: float) -> void:
    var base := global_position.direction_to(player.global_position).angle()
    for i in range(count):
        var offset := (float(i) - float(count - 1) * 0.5) * 0.20
        var dir := Vector2.from_angle(base + offset)
        get_tree().call_group("game_world", "spawn_boss_projectile", global_position + dir * 28.0, dir, speed, damage, 6.0)

func take_damage(amount: float) -> void:
    health.damage(amount)
    flash_time = 0.0 if SettingsManager.reduce_flashes else 0.08

func apply_slow(_factor: float, _duration: float) -> void:
    pass # mini-chefes não sofrem slow da boleadeira

func _on_died() -> void:
    for index in range(4):
        var angle := TAU * float(index) / 4.0
        var rarity := 3 if index == 0 else 2
        get_tree().call_group("game_world", "spawn_fruit", global_position + Vector2.from_angle(angle) * 34.0, "carne", biome_index, rarity)
    get_tree().call_group("game_world", "on_miniboss_defeated", biome_index, boss_id, boss_name, power_name, global_position)
    defeated.emit(biome_index)
    queue_free()

func _draw() -> void:
    if sprite.texture != null:
        return
    var data: Dictionary = BiomeDB.get_biome(biome_index)
    var c: Color = data["detail"]
    if flash_time > 0.0 and not SettingsManager.reduce_flashes:
        c = Color.WHITE
    draw_circle(Vector2.ZERO, 34.0, c)
    draw_arc(Vector2.ZERO, 40.0, 0.0, TAU, 32, Color("#3a1715"), 5.0)
    draw_circle(Vector2(-12,-7), 4.0, Color("#f6d251"))
    draw_circle(Vector2(12,-7), 4.0, Color("#f6d251"))
    draw_string(ThemeDB.fallback_font, Vector2(-68, -52), boss_name, HORIZONTAL_ALIGNMENT_CENTER, 136.0, 13, Color("#fff0b0"))
