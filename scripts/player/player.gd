class_name Player
extends CharacterBody2D

const SpriteAnimUtils := preload("res://scripts/core/sprite_anim_utils.gd")

signal health_changed(current: float, maximum: float)
signal xp_changed(current: int, needed: int, level: int)
signal level_up_requested
signal player_died
signal weapon_changed(weapon_name: String)
signal food_changed(current: float, maximum: float)
signal mutagen_changed(current: int)

const BASE_MOVE_SPEED := 280.0
const BASE_ATTACK_DAMAGE := 24.0
const BASE_ATTACK_RADIUS := 72.0
const BASE_ATTACK_COOLDOWN := 0.48
const BASE_DASH_COOLDOWN := 1.15
const BASE_MAX_HEALTH := 140.0

@onready var health: HealthComponent = $HealthComponent
@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D
@onready var evolution_visuals: EvolutionVisuals = $EvolutionVisuals
@onready var weapon_sprite: Sprite2D = $WeaponSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

var move_speed := BASE_MOVE_SPEED
var attack_damage := BASE_ATTACK_DAMAGE
var attack_radius := BASE_ATTACK_RADIUS
var attack_cooldown := BASE_ATTACK_COOLDOWN
var dash_cooldown := BASE_DASH_COOLDOWN
var dash_speed := 760.0
var dash_duration := 0.16
var damage_reduction := 0.0
var critical_chance := 0.05
var critical_multiplier := 1.8
var ancestral_shot_ratio := 0.0
var heal_on_kill := 0.0
var ability_power := 10.0
var plating := 0.0
var max_plating := 0.0

# Atributos do painel de build.
var passive_regeneration := 0.0
var madness := 0.0
var poison_resistance := 0.0
var dodge_chance := 0.0
var heat_adaptation := 1.0
var cold_adaptation := 1.0
var attack_penalty := 1.0
var body_size := 0.82
var food_progress := 1.0
var consumption_speed := 1.0
var consumption_distance := 1.0
var terrain_adaptation := 1.0
var senses := 1.0
var social := 10.0
var region_affinities: Array[int] = [0, 0, 0, 0]
var spirit_affinities: Array[int] = [0, 0, 0, 0, 0, 0]

# Estatísticas de run / estilo de vida.
var food_meter := 0.0
var fruit_count := 0
var animals_killed := 0
var peaceful_encounters := 0
var companion_names: Array[String] = []

# Armas e poderes de mini-chefes.
var unlocked_weapons: Dictionary = {"claws": true, "spear": true}
var current_weapon := "claws"
var miniboss_powers: Dictionary = {}
var attack_counter := 0

# Estado de combate e progressão.
var attack_timer := 0.0
var dash_timer := 0.0
var dash_time_left := 0.0
var dash_direction := Vector2.ZERO
var invulnerable := false
var hurt_invulnerability := 0.0
var level := 1
var xp := 0
var xp_needed := 40
var pending_level_up := false
var upgrade_levels: Dictionary = {}
var upgrade_rarities: Dictionary = {}
var specialisations: Dictionary = {}
var internal_stats: Dictionary = {}
var mutagen := 0
var rarity_luck := 0.0
var progress_requirement_multiplier := 1.0
var alpha_damage_multiplier := 1.0
var poi_multiplier := 1.0
var poi_reward_multiplier := 1.0
var ally_reward_multiplier := 1.0
var reroll_discount := 0
var specialisation_level_offset := 0
var size_rarity_bonus := 0.0
var use_highest_attack_stat := false
var empty_slot_bonus := 0.0
var diet_style := "omnivore"
var evolution_choice_count := 3
var highborn_rule := false
var underdog_rule := false
var independent_rule := false
var underdog_awakened := false

# Slots ativos. O catalogo completo fica em CombatDB; a run comeca simples.
var equipped_attacks: Array[String] = []
var unlocked_attacks: Dictionary = {}
var unlocked_ultimates: Dictionary = {"lick_wounds":true}
var unlocked_movements: Dictionary = {"basic_dash":true}
var equipped_ultimate := "lick_wounds"
var equipped_movement := "basic_dash"
var ultimate_timer := 0.0
var ultimate_buff_timer := 0.0
var ultimate_base_damage_multiplier := 1.0

# Ambiente procedural.
var environment_speed_multiplier := 1.0
var heat_damage_per_second := 0.0
var cold_damage_per_second := 0.0
var environment_tick := 0.5
var current_biome := 0
var currently_in_water := false
var currently_day := true
var climate_active := false
var soak_level := 0.0

var base_sprite_scale := Vector2.ONE
var feeding_banner_cooldown := 0.0
var camera_shake_time := 0.0
var camera_shake_strength := 0.0
var use_animated_sprite := false
var facing_direction := "right"
var attack_animation_time := 0.0

func _ready() -> void:
    motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
    up_direction = Vector2.ZERO
    add_to_group("player")
    health.health_changed.connect(_on_health_changed)
    health.died.connect(_on_died)
    _ensure_animated_sprite()
    _try_load_sprite()
    camera.limit_left = -100000000
    camera.limit_top = -100000000
    camera.limit_right = 100000000
    camera.limit_bottom = 100000000
    var shape := collision_shape.shape.duplicate() as CircleShape2D
    collision_shape.shape = shape
    _refresh_body_visual()
    xp_changed.emit(xp, xp_needed, level)
    _refresh_weapon_visual()
    GeneticsDB.apply_to_player(self, GameSession.selected_genetic)
    if not GameSession.selected_secondary_genetic.is_empty():
        GeneticsDB.apply_to_player(self, GameSession.selected_secondary_genetic)
    _refresh_internal_stats()
    if not SettingsManager.settings_changed.is_connected(_apply_accessibility_settings):
        SettingsManager.settings_changed.connect(_apply_accessibility_settings)
    _apply_accessibility_settings()
    weapon_changed.emit(WeaponDB.get_weapon_name(current_weapon))
    food_changed.emit(food_meter, 100.0)
    mutagen_changed.emit(mutagen)
    queue_redraw()

# Mantido por compatibilidade com a versão de mapa finito.
func set_world_bounds(_bounds: Rect2) -> void:
    pass

func _ensure_animated_sprite() -> void:
    if animated_sprite != null:
        return
    animated_sprite = AnimatedSprite2D.new()
    animated_sprite.name = "AnimatedSprite2D"
    animated_sprite.z_index = 4
    add_child(animated_sprite)

func _try_load_sprite() -> void:
    var idle_path := "res://assets/sprites/player/ninja_green/idle.png"
    var walk_path := "res://assets/sprites/player/ninja_green/walk.png"
    var attack_path := "res://assets/sprites/player/ninja_green/attack.png"
    var dead_path := "res://assets/sprites/player/ninja_green/dead.png"
    if ResourceLoader.exists(walk_path):
        var walk_tex := load(walk_path) as Texture2D
        var idle_tex: Texture2D = walk_tex
        if ResourceLoader.exists(idle_path):
            var candidate_idle := load(idle_path) as Texture2D
            if candidate_idle.get_height() >= 64:
                idle_tex = candidate_idle
        var attack_tex: Texture2D = walk_tex
        if ResourceLoader.exists(attack_path):
            var candidate_attack := load(attack_path) as Texture2D
            if candidate_attack.get_height() >= 64:
                attack_tex = candidate_attack
        var dead_tex: Texture2D = null
        if ResourceLoader.exists(dead_path):
            dead_tex = load(dead_path) as Texture2D
        animated_sprite.sprite_frames = SpriteAnimUtils.create_directional_frames_from_separate_sheets(idle_tex, walk_tex, attack_tex, dead_tex)
        animated_sprite.visible = true
        animated_sprite.centered = true
        animated_sprite.scale = Vector2.ONE * 2.3
        animated_sprite.play("idle_right")
        use_animated_sprite = true
        sprite.visible = false
        base_sprite_scale = Vector2.ONE * 2.3
        return

    var paths := [
        "res://assets/sprites/player/player.png",
        "res://assets/sprites/player/base.png"
    ]
    for path in paths:
        if ResourceLoader.exists(path):
            sprite.texture = load(path) as Texture2D
            var max_side := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
            base_sprite_scale = Vector2.ONE * (48.0 / maxf(1.0, max_side))
            sprite.scale = base_sprite_scale
            return

func _physics_process(delta: float) -> void:
    attack_timer = maxf(0.0, attack_timer - delta)
    attack_animation_time = maxf(0.0, attack_animation_time - delta)
    dash_timer = maxf(0.0, dash_timer - delta)
    hurt_invulnerability = maxf(0.0, hurt_invulnerability - delta)
    feeding_banner_cooldown = maxf(0.0, feeding_banner_cooldown - delta)
    ultimate_timer = maxf(0.0, ultimate_timer - delta)
    ultimate_buff_timer = maxf(0.0, ultimate_buff_timer - delta)
    if ultimate_buff_timer <= 0.0:
        ultimate_base_damage_multiplier = 1.0

    if passive_regeneration > 0.0 and health.current_health < health.max_health:
        health.heal(passive_regeneration * delta)

    _update_environment_damage(delta)
    _update_weapon_input()
    _update_combat_loadout_input()
    if InputMap.has_action("ultimate") and Input.is_action_just_pressed("ultimate") and ultimate_timer <= 0.0 and not pending_level_up:
        _activate_ultimate()

    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if Input.is_action_just_pressed("dash") and dash_timer <= 0.0 and input_vector.length() > 0.1:
        _start_dash(input_vector.normalized())

    if dash_time_left > 0.0:
        dash_time_left -= delta
        velocity = dash_direction * dash_speed * _size_speed_multiplier()
    else:
        velocity = input_vector * move_speed * _size_speed_multiplier() * environment_speed_multiplier
    invulnerable = dash_time_left > 0.0 or hurt_invulnerability > 0.0

    move_and_slide()

    if Input.is_action_pressed("attack") and attack_timer <= 0.0 and not pending_level_up:
        _attack()

    if is_instance_valid(weapon_sprite) and weapon_sprite.texture != null:
        var weapon_aim := _get_aim_direction()
        if weapon_aim.length() < 0.1:
            weapon_aim = Vector2.RIGHT
        weapon_sprite.rotation = weapon_aim.angle()
        weapon_sprite.position = weapon_aim * 20.0 * body_size

    _update_player_animation(input_vector)
    _update_camera_accessibility(delta)
    queue_redraw()

func _update_player_animation(input_vector: Vector2) -> void:
    if not use_animated_sprite or animated_sprite == null or animated_sprite.sprite_frames == null:
        return

    if input_vector.x > 0.12:
        facing_direction = "right"
    elif input_vector.x < -0.12:
        facing_direction = "left"

    var prefix := "idle"
    if health.current_health <= 0.0 and animated_sprite.sprite_frames.has_animation("dead"):
        prefix = "dead"
    elif attack_animation_time > 0.0:
        prefix = "attack"
    elif input_vector.length() > 0.05 or velocity.length() > 10.0 or dash_time_left > 0.0:
        prefix = "walk"

    var anim := prefix
    if prefix != "dead":
        anim = "%s_%s" % [prefix, facing_direction]
        if not animated_sprite.sprite_frames.has_animation(anim):
            anim = "%s_right" % prefix
    if animated_sprite.animation != anim and animated_sprite.sprite_frames.has_animation(anim):
        animated_sprite.play(anim)

func _update_environment_damage(delta: float) -> void:
    environment_tick -= delta
    if environment_tick > 0.0:
        return
    environment_tick = 0.5
    var amount := (heat_damage_per_second + cold_damage_per_second) * 0.5
    if amount > 0.0:
        health.damage(amount)

func set_environment_state(biome_index: int, in_water: bool, is_day: bool, event_active: bool = false) -> void:
    current_biome = clampi(biome_index, 0, BiomeDB.BIOMES.size() - 1)
    currently_in_water = in_water
    currently_day = is_day
    climate_active = event_active

    var biome_data: Dictionary = BiomeDB.get_biome(current_biome)
    var base_terrain := float(biome_data["base_terrain"])
    environment_speed_multiplier = base_terrain

    if in_water:
        soak_level = minf(1.0, soak_level + 0.035)
    else:
        soak_level = maxf(0.0, soak_level - 0.025)

    if in_water and not miniboss_powers.has("minhocao"):
        var relief := clampf((terrain_adaptation - 0.85) / 0.75, 0.0, 1.0)
        environment_speed_multiplier *= lerpf(0.60, 1.0, relief)
    elif current_biome == 2 and not miniboss_powers.has("minhocao"):
        var dry_relief := clampf((terrain_adaptation - 0.90) / 0.60, 0.0, 1.0)
        environment_speed_multiplier *= lerpf(0.88, 1.0, dry_relief)

    heat_damage_per_second = 0.0
    cold_damage_per_second = 0.0
    if current_biome == 1 and is_day and event_active:
        var heat_factor := clampf((1.35 - heat_adaptation) / 0.35, 0.0, 1.0)
        heat_damage_per_second = 5.5 * heat_factor
    if current_biome == 3 and not is_day and event_active:
        var cold_factor := clampf((1.35 - cold_adaptation) / 0.35, 0.0, 1.0)
        cold_damage_per_second = 5.5 * cold_factor
    if soak_level > 0.65 and terrain_adaptation < 1.20:
        environment_speed_multiplier *= lerpf(1.0, 0.82, soak_level)

func _start_dash(direction: Vector2) -> void:
    var movement: Dictionary = CombatDB.MOVEMENTS.get(equipped_movement, CombatDB.MOVEMENTS["basic_dash"])
    var movement_distance := float(movement["distance"])
    if movement_distance > 0.0:
        dash_duration = clampf(movement_distance * 27.0 / maxf(1.0, dash_speed), 0.10, 0.34)
    dash_direction = direction
    dash_time_left = dash_duration
    dash_timer = dash_cooldown
    AudioManager.play_sfx("dash.wav")
    if miniboss_powers.has("minhocao"):
        get_tree().call_group("game_world", "spawn_melee_effect", global_position, direction, 120.0 * _size_area_multiplier())
        _deal_area_damage(global_position, 115.0 * _size_area_multiplier(), get_effective_attack_damage() * 0.60, false)

func _update_weapon_input() -> void:
    if Input.is_action_just_pressed("weapon_next"):
        _cycle_weapon(1)
    elif Input.is_action_just_pressed("weapon_prev"):
        _cycle_weapon(-1)
    for i in range(WeaponDB.ORDER.size()):
        var action := "weapon_%d" % (i + 1)
        if InputMap.has_action(action) and Input.is_action_just_pressed(action):
            var id := String(WeaponDB.ORDER[i])
            if unlocked_weapons.has(id):
                set_weapon(id)

func _update_combat_loadout_input() -> void:
    if InputMap.has_action("ultimate_next") and Input.is_action_just_pressed("ultimate_next"):
        equipped_ultimate = _cycle_dictionary_key(unlocked_ultimates, equipped_ultimate)
        get_tree().call_group("game_world", "show_banner", "Ultimate: %s" % String(CombatDB.ULTIMATES[equipped_ultimate]["name"]), 1.2)
    if InputMap.has_action("movement_next") and Input.is_action_just_pressed("movement_next"):
        equipped_movement = _cycle_dictionary_key(unlocked_movements, equipped_movement)
        get_tree().call_group("game_world", "show_banner", "Dash: %s" % String(CombatDB.MOVEMENTS[equipped_movement]["name"]), 1.2)

func _cycle_dictionary_key(values: Dictionary, current: String) -> String:
    var keys: Array = values.keys()
    keys.sort()
    if keys.is_empty(): return current
    var index := keys.find(current)
    return String(keys[posmod(index + 1, keys.size())])

func _refresh_weapon_visual() -> void:
    if not is_instance_valid(weapon_sprite):
        return
    weapon_sprite.texture = null
    var path := "res://assets/sprites/weapons/%s.png" % current_weapon
    if ResourceLoader.exists(path):
        weapon_sprite.texture = load(path) as Texture2D
        var max_side := float(maxi(weapon_sprite.texture.get_width(), weapon_sprite.texture.get_height()))
        weapon_sprite.scale = Vector2.ONE * (34.0 * body_size / maxf(1.0, max_side))

func _cycle_weapon(direction: int) -> void:
    var available: Array[String] = []
    for id_value in WeaponDB.ORDER:
        var id := String(id_value)
        if unlocked_weapons.has(id):
            available.append(id)
    if available.is_empty():
        return
    var index := available.find(current_weapon)
    if index < 0:
        index = 0
    index = posmod(index + direction, available.size())
    set_weapon(available[index])

func set_weapon(id: String) -> void:
    if not unlocked_weapons.has(id):
        return
    current_weapon = id
    _refresh_weapon_visual()
    weapon_changed.emit(WeaponDB.get_weapon_name(current_weapon))
    get_tree().call_group("game_world", "show_banner", "Arma: %s" % WeaponDB.get_weapon_name(current_weapon), 1.0)

func unlock_weapon(id: String) -> bool:
    if not WeaponDB.WEAPONS.has(id) or unlocked_weapons.has(id):
        return false
    unlocked_weapons[id] = true
    set_weapon(id)
    return true

func unlock_random_weapon() -> String:
    var locked: Array[String] = []
    for id_value in WeaponDB.ORDER:
        var id := String(id_value)
        if not unlocked_weapons.has(id):
            locked.append(id)
    if locked.is_empty():
        return ""
    locked.shuffle()
    var chosen := locked[0]
    unlock_weapon(chosen)
    return chosen

func _attack() -> void:
    attack_animation_time = 0.22
    var weapon: Dictionary = WeaponDB.get_weapon(current_weapon)
    attack_timer = attack_cooldown * float(weapon["cooldown"]) * attack_penalty * _size_attack_penalty()
    attack_counter += 1

    var aim := _get_aim_direction()

    var effective_damage := get_effective_attack_damage() * float(weapon["damage"])
    var effective_radius := get_effective_attack_radius() * float(weapon["area"])
    var weapon_type := String(weapon["type"])

    match weapon_type:
        "melee":
            var melee_center := global_position + aim * effective_radius * 0.52
            _deal_area_damage(melee_center, effective_radius, effective_damage, true)
            get_tree().call_group("game_world", "spawn_melee_effect", global_position, aim, effective_radius)
        "thrust":
            var thrust_radius := maxf(30.0, effective_radius * 0.58)
            var thrust_center := global_position + aim * maxf(80.0, get_effective_attack_radius() * 1.12)
            _deal_area_damage(thrust_center, thrust_radius, effective_damage, true)
            get_tree().call_group("game_world", "spawn_melee_effect", thrust_center, aim, thrust_radius)
        "projectile":
            var projectile_damage := attack_damage * float(weapon["damage"]) * (0.82 + 0.18 * _size_damage_multiplier())
            get_tree().call_group("game_world", "spawn_player_projectile", global_position + aim * 30.0, aim, projectile_damage, "", 1)
        "slow_projectile":
            var slow_damage := attack_damage * float(weapon["damage"]) * (0.88 + 0.12 * _size_damage_multiplier())
            get_tree().call_group("game_world", "spawn_player_projectile", global_position + aim * 30.0, aim, slow_damage, "slow", 1)
        "social_pulse":
            var affinity_total := 0
            for affinity in region_affinities:
                affinity_total += affinity
            var social_multiplier := 0.58 + social * 0.045 + float(affinity_total) * 0.006
            var pulse_radius := maxf(88.0, effective_radius * 1.48)
            _deal_area_damage(global_position, pulse_radius, attack_damage * social_multiplier, false, true)
            get_tree().call_group("game_world", "spawn_melee_effect", global_position, Vector2.RIGHT, pulse_radius)

    if ancestral_shot_ratio > 0.0 and weapon_type in ["melee", "thrust"]:
        get_tree().call_group("game_world", "spawn_player_projectile", global_position + aim * 32.0, aim, get_effective_attack_damage() * ancestral_shot_ratio, "", 1)

    # Sol do Sertão: leque de fogo em todo ataque.
    if miniboss_powers.has("cabra_cabriola"):
        var base_angle := aim.angle()
        for offset in [-0.22, 0.0, 0.22]:
            var dir := Vector2.from_angle(base_angle + float(offset))
            get_tree().call_group("game_world", "spawn_player_projectile", global_position + dir * 28.0, dir, get_effective_attack_damage() * 0.42, "burn", 1)

    # Brasa da Teiniaguá: todo terceiro ataque cria uma coroa de projéteis.
    if miniboss_powers.has("teiniagua") and attack_counter % 3 == 0:
        for i in range(8):
            var dir := Vector2.from_angle(TAU * float(i) / 8.0)
            get_tree().call_group("game_world", "spawn_player_projectile", global_position + dir * 24.0, dir, get_effective_attack_damage() * 0.36, "", 1)

    if not equipped_attacks.is_empty():
        _perform_evolution_attack(equipped_attacks[attack_counter % equipped_attacks.size()], aim)

    AudioManager.play_sfx("attack.wav")

func _perform_evolution_attack(attack_id: String, aim: Vector2) -> void:
    if not CombatDB.ATTACKS.has(attack_id): return
    var data: Dictionary = CombatDB.ATTACKS[attack_id]
    var level_value := clampi(int(upgrade_levels.get("attack_%s" % attack_id, 1)), 1, 5)
    var scales: Array = data["scale"]
    var scale_value := float(scales[level_value - 1])
    var base := attack_damage
    match String(data["stat"]):
        "ability": base = ability_power
        "hybrid": base = (attack_damage + ability_power) * 0.5
        "lowest": base = minf(attack_damage, ability_power)
        "physical_hp": base = attack_damage + health.max_health * float(data["hp_scale"][level_value - 1])
    var final_damage := base * scale_value
    var kind := String(data["kind"])
    if kind in ["projectile", "stone", "tongue", "poison"]:
        var effect := "poison" if kind == "poison" else ("slow" if kind == "tongue" else "")
        get_tree().call_group("game_world", "spawn_player_projectile", global_position + aim * 30.0, aim, final_damage, effect, 1)
    else:
        var radius := get_effective_attack_radius() * (1.25 if kind in ["wide", "slam"] else 0.72)
        var center := global_position + aim * radius * 0.55
        _deal_area_damage(center, radius, final_damage, true)
        if kind == "leech": health.heal(final_damage * float(data.get("heal", 0.10)))

func _deal_area_damage(center: Vector2, radius: float, damage: float, hit_harvestables: bool, hostiles_only: bool = false) -> void:
    var circle := CircleShape2D.new()
    circle.radius = radius
    var query := PhysicsShapeQueryParameters2D.new()
    query.shape = circle
    query.transform = Transform2D(0.0, center)
    query.collision_mask = 6 if hit_harvestables else 2
    query.collide_with_bodies = true
    var hits := get_world_2d().direct_space_state.intersect_shape(query, 48)
    var damaged: Dictionary = {}
    for hit in hits:
        var body = hit["collider"]
        if body == null or damaged.has(body):
            continue
        damaged[body] = true
        if body.is_in_group("enemies") and body.has_method("take_damage"):
            if hostiles_only and body is Enemy:
                var creature := body as Enemy
                if creature.temperament != "predator" and creature.hostile_to_player <= 0.0:
                    continue
            var dealt := damage
            if randf() < critical_chance:
                dealt *= critical_multiplier
            body.take_damage(dealt)
        elif hit_harvestables and body.is_in_group("harvestable") and body.has_method("take_damage"):
            body.take_damage(damage)

func get_effective_attack_damage() -> float:
    var base := maxf(attack_damage, ability_power) if use_highest_attack_stat else attack_damage
    var time_multiplier := day_damage_multiplier() if currently_day else night_damage_multiplier()
    var affinity_multiplier := 1.0 + float(spirit_affinities[0]) * 0.012 + float(spirit_affinities[2]) * 0.008
    var minimalist_damage := 1.0 + empty_slot_bonus * float(maxi(0, 2 - equipped_attacks.size()))
    return base * _size_damage_multiplier() * ultimate_base_damage_multiplier * time_multiplier * affinity_multiplier * minimalist_damage

func day_damage_multiplier() -> float:
    return 1.0 + float(spirit_affinities[4]) * 0.01

func night_damage_multiplier() -> float:
    return 1.0 + float(spirit_affinities[5]) * 0.01

func get_effective_attack_radius() -> float:
    return attack_radius * _size_area_multiplier()

func get_effective_dodge() -> float:
    var size_bonus := 0.0
    if body_size < 1.0:
        size_bonus = (1.0 - body_size) * 0.65
    elif body_size > 1.0:
        size_bonus = -(body_size - 1.0) * 0.18
    return clampf(dodge_chance + size_bonus + float(spirit_affinities[1]) * 0.004, 0.0, 0.70)

func _size_damage_multiplier() -> float:
    # Tamanho é uma escolha central: gigantes batem muito mais forte; pequenos
    # sacrificam dano bruto para ganhar mobilidade, recarga e esquiva.
    if body_size >= 1.0:
        return 1.0 + (body_size - 1.0) * 0.95
    return maxf(0.72, 1.0 - (1.0 - body_size) * 0.45)

func _size_area_multiplier() -> float:
    if body_size >= 1.0:
        return minf(1.78, 1.0 + (body_size - 1.0) * 0.85)
    return maxf(0.78, 1.0 - (1.0 - body_size) * 0.35)

func _size_speed_multiplier() -> float:
    if body_size < 1.0:
        return 1.0 + (1.0 - body_size) * 0.70
    return maxf(0.68, 1.0 - (body_size - 1.0) * 0.35)

func _size_attack_penalty() -> float:
    if body_size < 1.0:
        return maxf(0.76, 1.0 - (1.0 - body_size) * 0.42)
    return minf(1.28, 1.0 + (body_size - 1.0) * 0.24)

func take_poison_damage(amount: float) -> void:
    var resisted := clampf(poison_resistance, 0.0, 1.0)
    var final_amount := amount * (1.0 - resisted)
    if final_amount <= 0.01:
        return
    take_damage(final_amount)

func take_damage(amount: float) -> void:
    if invulnerable:
        return
    if randf() < get_effective_dodge():
        hurt_invulnerability = 0.16
        invulnerable = true
        return
    var final_amount := amount * (1.0 - clampf(damage_reduction, 0.0, 0.72))
    if highborn_rule:
        for node in get_tree().get_nodes_in_group("enemies"):
            if is_instance_valid(node) and node is Node2D and global_position.distance_to(node.global_position) < 150.0:
                final_amount *= 1.50
                break
    if plating > 0.0:
        var absorbed := minf(plating, final_amount)
        plating -= absorbed
        final_amount -= absorbed
    if final_amount <= 0.0:
        return
    health.damage(final_amount)
    hurt_invulnerability = 0.28
    invulnerable = true
    AudioManager.play_sfx("hurt.wav")
    request_camera_shake(5.0, 0.16)

func add_xp(amount: int) -> void:
    var sense_multiplier := clampf(senses, 0.75, 2.25)
    var pressure_cost := GameSession.pressure_multiplier("progress")
    var minimalist_progress := 1.0 + empty_slot_bonus * float(maxi(0, 2 - equipped_attacks.size()))
    xp += maxi(1, int(round(float(amount) * sense_multiplier * minimalist_progress / pressure_cost)))
    xp_changed.emit(xp, xp_needed, level)
    _try_level_up()

func add_nature_xp(amount: int) -> void:
    var forager_level := int(upgrade_levels.get("forager", 0))
    var multiplier := 1.0 + float(forager_level) * 0.22 + maxf(0.0, social - 10.0) * 0.012
    add_xp(maxi(1, int(round(float(amount) * multiplier))))

func _try_level_up() -> void:
    if pending_level_up or xp < xp_needed:
        return
    xp -= xp_needed
    level += 1
    xp_needed = int(round(40.0 * pow(1.26, level - 1) * progress_requirement_multiplier))
    pending_level_up = true
    xp_changed.emit(xp, xp_needed, level)
    AudioManager.play_sfx("levelup.wav")
    level_up_requested.emit()

func apply_upgrade(upgrade_id: String, rarity: String = "rare") -> void:
    var current := int(upgrade_levels.get(upgrade_id, 0)) + 1
    upgrade_levels[upgrade_id] = current
    upgrade_rarities[upgrade_id] = rarity
    var rarity_power := float(CombatDB.RARITIES.get(rarity, CombatDB.RARITIES["rare"])["power"])
    match upgrade_id:
        "damage":
            attack_damage *= 1.0 + 0.20 * rarity_power
        "attack_speed":
            attack_cooldown = maxf(0.15, attack_cooldown * (1.0 - 0.12 * rarity_power))
        "vitality":
            health.increase_max(30.0 * rarity_power, 30.0 * rarity_power)
            passive_regeneration += 0.35 * rarity_power
            food_progress += 0.04 * rarity_power
            change_size(0.04 * rarity_power)
        "speed":
            move_speed *= 1.0 + 0.10 * rarity_power
            terrain_adaptation += 0.05 * rarity_power
            change_size(-0.025 * rarity_power)
        "range":
            attack_radius *= 1.0 + 0.18 * rarity_power
            consumption_distance += 0.08 * rarity_power
            change_size(0.025 * rarity_power)
        "dash":
            dash_cooldown = maxf(0.36, dash_cooldown * (1.0 - 0.15 * rarity_power))
            dodge_chance = minf(0.34, dodge_chance + 0.025 * rarity_power)
            change_size(-0.045 * rarity_power)
        "ancestral_shot":
            ancestral_shot_ratio = 0.38 + 0.16 * float(current - 1)
            heat_adaptation += 0.08
        "critical":
            critical_chance = minf(0.48, critical_chance + 0.08)
            senses += 0.05
            attack_damage *= 1.03
        "heal_kill":
            heal_on_kill = float(current)
            social += 1.0
            consumption_speed += 0.05
        "resistance":
            damage_reduction = minf(0.58, damage_reduction + 0.08)
            poison_resistance = minf(1.0, poison_resistance + 0.06)
            change_size(0.075)
        "social_charm":
            social += 4.0
            senses += 0.03
        "tiny":
            change_size(-0.10)
            dodge_chance = minf(0.42, dodge_chance + 0.04)
            move_speed *= 1.06
            attack_cooldown = maxf(0.15, attack_cooldown * 0.95)
        "giant":
            change_size(0.12)
            attack_damage *= 1.12
            health.increase_max(16.0, 16.0)
            attack_radius *= 1.05
        "forager":
            senses += 0.12
            consumption_distance += 0.22
            food_progress += 0.12
        "adaptation":
            terrain_adaptation += 0.14 * rarity_power
            heat_adaptation += 0.10 * rarity_power
            cold_adaptation += 0.10 * rarity_power
            poison_resistance = minf(1.0, poison_resistance + 0.04 * rarity_power)
        _:
            _apply_catalog_upgrade(upgrade_id, rarity_power)
    if CombatDB.SPECIALISATIONS.has(upgrade_id) and current + specialisation_level_offset >= 3 and not specialisations.has(upgrade_id):
        var choices: Array = CombatDB.SPECIALISATIONS[upgrade_id]
        specialisations[upgrade_id] = String(choices[randi() % choices.size()])
    social = clampf(social, 0.0, 50.0)
    evolution_visuals.set_upgrade_level(upgrade_id, current)
    pending_level_up = false
    _refresh_body_visual()
    _refresh_internal_stats()
    if GameSession.selected_genetic == "elitist" and current == 1:
        if rarity == "legendary": add_xp(xp_needed)
        elif rarity == "common": health.increase_max(-health.max_health * 0.10, 0.0)
    _try_level_up()

func get_evolution_choice_count() -> int:
    return clampi(evolution_choice_count, 1, 3)

func forced_minimum_rarity() -> String:
    if GameSession.selected_genetic == "chosen" and level == 3: return "legendary"
    return ""

func _apply_catalog_upgrade(upgrade_id: String, power: float) -> void:
    var definition := UpgradeDB.find_upgrade(upgrade_id)
    var effect := String(definition.get("effect", "balanced"))
    if upgrade_id in ["herbivore", "carnivore", "piscivore", "omnivore", "vegan"]:
        diet_style = upgrade_id
    match effect:
        "physical": attack_damage *= 1.0 + 0.07 * power; spirit_affinities[0] += 1
        "ability": ability_power *= 1.0 + 0.09 * power; spirit_affinities[2] += 1
        "speed": move_speed *= 1.0 + 0.06 * power; dash_cooldown *= maxf(0.65, 1.0 - 0.03 * power)
        "terrain": terrain_adaptation += 0.10 * power; heat_adaptation += 0.04 * power; cold_adaptation += 0.04 * power
        "social": social += 2.0 * power; spirit_affinities[3] += 1
        "size": change_size(0.07 * power); attack_damage *= 1.0 + 0.035 * power
        "small": change_size(-0.07 * power); attack_cooldown *= maxf(0.65, 1.0 - 0.04 * power)
        "hp": health.increase_max(13.0 * power, 13.0 * power); change_size(0.018 * power)
        "plating": max_plating += 12.0 * power; plating = max_plating
        "plating_attack": max_plating += 7.0 * power; plating = max_plating; attack_damage += max_plating * 0.025
        "regen": passive_regeneration += 0.28 * power
        "senses": senses += 0.10 * power; critical_chance = minf(0.55, critical_chance + 0.015 * power)
        "feeding": consumption_speed += 0.08 * power; consumption_distance += 0.12 * power
        "food": food_progress += 0.11 * power; consumption_speed += 0.03 * power; spirit_affinities[1] += 1
        "poison": poison_resistance = minf(1.0, poison_resistance + 0.035 * power); ability_power *= 1.0 + 0.04 * power
        "dodge": dodge_chance = minf(0.62, dodge_chance + 0.035 * power); move_speed *= 1.0 + 0.025 * power
        "cooldown": attack_cooldown *= maxf(0.60, 1.0 - 0.055 * power); dash_cooldown *= maxf(0.60, 1.0 - 0.04 * power)
        "critical": critical_chance = minf(0.60, critical_chance + 0.045 * power)
        "resist": damage_reduction = minf(0.72, damage_reduction + 0.035 * power); poison_resistance = minf(1.0, poison_resistance + 0.025 * power)
        "cold": cold_adaptation += 0.16 * power
        "area": attack_radius *= 1.0 + 0.09 * power; consumption_distance += 0.04 * power
        "poi": poi_multiplier += 0.12 * power; rarity_luck += 0.04 * power
        "mutagen": rarity_luck += 0.08 * power; add_mutagen(int(2.0 * power))
        "vegan": diet_style = "vegan"; food_progress += 0.20 * power; social += 1.0 * power
        "day": spirit_affinities[4] += int(3.0 * power)
        "night": spirit_affinities[5] += int(3.0 * power); senses += 0.08 * power
        "unlock_attack":
            var attack_id := upgrade_id.trim_prefix("attack_")
            unlocked_attacks[attack_id] = true
            if not equipped_attacks.has(attack_id):
                if equipped_attacks.size() < 2: equipped_attacks.append(attack_id)
                else: equipped_attacks[1] = attack_id
            if CombatDB.SPECIALISATIONS.has(attack_id) and int(upgrade_levels.get(upgrade_id, 0)) + specialisation_level_offset >= 3 and not specialisations.has(attack_id):
                var choices: Array = CombatDB.SPECIALISATIONS[attack_id]
                specialisations[attack_id] = String(choices[randi() % choices.size()])
        "unlock_ultimate":
            var ultimate_id := upgrade_id.trim_prefix("ultimate_")
            unlocked_ultimates[ultimate_id] = true
            equipped_ultimate = ultimate_id
        "unlock_movement":
            var movement_id := upgrade_id.trim_prefix("movement_")
            unlocked_movements[movement_id] = true
            equipped_movement = movement_id
        _:
            attack_damage *= 1.0 + 0.025 * power
            ability_power *= 1.0 + 0.025 * power
            social += 0.35 * power

func add_mutagen(amount: int) -> void:
    mutagen += maxi(0, int(round(float(amount) * (1.0 + rarity_luck * 0.1))))
    mutagen_changed.emit(mutagen)

func spend_mutagen(amount: int) -> bool:
    var cost := maxi(0, amount - reroll_discount)
    if mutagen < cost: return false
    mutagen -= cost
    mutagen_changed.emit(mutagen)
    return true

func get_rarity_luck() -> float:
    return rarity_luck + maxf(0.0, body_size - 1.0) * size_rarity_bonus

func _activate_ultimate() -> void:
    var data: Dictionary = CombatDB.ULTIMATES.get(equipped_ultimate, CombatDB.ULTIMATES["lick_wounds"])
    var cooldowns: Array = data["cooldown"]
    ultimate_timer = float(cooldowns[0])
    match String(data["kind"]):
        "heal": health.heal(health.max_health * 0.32 + consumption_speed * 4.0)
        "burst": _deal_area_damage(global_position, 170.0 * _size_area_multiplier(), get_effective_attack_damage() * 2.4, false)
        "stun_dot":
            _deal_area_damage(global_position, 150.0, get_effective_attack_damage() * 1.2, false)
            _slow_nearby(160.0, 0.18, 5.0)
        "web": _slow_nearby(220.0, 0.34, 7.0)
        "burrow": hurt_invulnerability = 3.0
        "buff", "evolution_buff":
            ultimate_base_damage_multiplier = 1.45 + float(upgrade_levels.size()) * 0.01
            ultimate_buff_timer = 10.0
        "charm":
            var target := _nearest_social_target(280.0)
            if is_instance_valid(target): target.force_befriend()
    get_tree().call_group("game_world", "show_banner", "%s ativado" % String(data["name"]), 1.4)

func _slow_nearby(radius: float, factor: float, duration: float) -> void:
    for node in get_tree().get_nodes_in_group("enemies"):
        if is_instance_valid(node) and node is Node2D and global_position.distance_to(node.global_position) <= radius and node.has_method("apply_slow"):
            node.call("apply_slow", factor, duration)

func _nearest_social_target(radius: float) -> Enemy:
    var best: Enemy
    var best_distance := radius
    for node in get_tree().get_nodes_in_group("creatures"):
        if not is_instance_valid(node) or not (node is Enemy): continue
        var creature := node as Enemy
        if creature.temperament == "predator" or creature.befriended: continue
        var distance := global_position.distance_to(creature.global_position)
        if distance < best_distance: best_distance = distance; best = creature
    return best

func _refresh_internal_stats() -> void:
    internal_stats = StatDB.make_defaults()
    internal_stats["max_health"] = health.max_health
    internal_stats["health_regeneration"] = passive_regeneration
    internal_stats["plating"] = plating
    internal_stats["max_plating"] = max_plating
    internal_stats["physical"] = attack_damage
    internal_stats["ability"] = ability_power
    internal_stats["social"] = social
    internal_stats["speed"] = move_speed
    internal_stats["size"] = body_size
    internal_stats["attack_area"] = attack_radius
    internal_stats["attack_cooldown"] = attack_cooldown
    internal_stats["dash_cooldown"] = dash_cooldown
    internal_stats["dodge_chance"] = get_effective_dodge()
    internal_stats["damage_reduction"] = damage_reduction
    internal_stats["poison_reduction"] = poison_resistance
    internal_stats["heat_reduction"] = clampf(heat_adaptation - 1.0, 0.0, 1.0)
    internal_stats["cold_reduction"] = clampf(cold_adaptation - 1.0, 0.0, 1.0)
    internal_stats["terrain_adaptation"] = terrain_adaptation
    internal_stats["soak_reduction"] = clampf(terrain_adaptation - 1.0, 0.0, 1.0)
    internal_stats["feeding_speed"] = consumption_speed
    internal_stats["feeding_distance"] = consumption_distance
    internal_stats["food_progress"] = food_progress
    internal_stats["rarity_luck"] = get_rarity_luck()
    internal_stats["critical_chance"] = critical_chance
    internal_stats["critical_multiplier"] = critical_multiplier
    internal_stats["senses"] = senses
    internal_stats["ally_limit"] = 4.0
    internal_stats["alpha_damage"] = alpha_damage_multiplier

func change_size(amount: float) -> void:
    body_size = clampf(body_size + amount, 0.60, 1.80)
    _refresh_body_visual()

func _refresh_body_visual() -> void:
    if use_animated_sprite and is_instance_valid(animated_sprite):
        animated_sprite.scale = base_sprite_scale * body_size
    elif is_instance_valid(sprite) and sprite.texture != null:
        sprite.scale = base_sprite_scale * body_size
    if is_instance_valid(evolution_visuals):
        evolution_visuals.scale = Vector2.ONE * body_size
    _refresh_weapon_visual()
    if is_instance_valid(collision_shape) and collision_shape.shape is CircleShape2D:
        var shape := collision_shape.shape as CircleShape2D
        shape.radius = 16.0 * body_size
    queue_redraw()

func apply_regional_blessing(region_index: int) -> void:
    match region_index:
        0:
            health.increase_max(15.0, 15.0)
            poison_resistance += 0.05
            heat_adaptation += 0.05
        1:
            dash_cooldown *= 0.94
            heat_adaptation += 0.14
        2:
            terrain_adaptation += 0.10
            move_speed *= 1.03
        3:
            attack_cooldown *= 0.97
            cold_adaptation += 0.14
            attack_damage *= 1.03
    increase_affinity(region_index, 4)

func apply_miniboss_power(boss_id: String) -> void:
    if miniboss_powers.has(boss_id):
        return
    miniboss_powers[boss_id] = true
    var region_index := int(BiomeDB.get_miniboss(boss_id)["biome"])
    match boss_id:
        "mapinguari":
            passive_regeneration += 1.4
            poison_resistance = 1.0
            consumption_distance += 0.65
        "cabra_cabriola":
            heat_adaptation = maxf(heat_adaptation, 1.60)
            ancestral_shot_ratio = maxf(ancestral_shot_ratio, 0.55)
        "minhocao":
            terrain_adaptation = maxf(terrain_adaptation, 1.65)
        "corpo_seco":
            damage_reduction = minf(0.68, damage_reduction + 0.18)
            attack_damage *= 1.15
            change_size(0.18)
        "teiniagua":
            cold_adaptation = maxf(cold_adaptation, 1.60)
            attack_cooldown *= 0.92
    increase_affinity(region_index, 8)

func activate_underdog() -> void:
    if not underdog_rule or underdog_awakened: return
    underdog_awakened = true
    attack_damage *= 1.80
    ability_power *= 1.35
    move_speed *= 1.12
    health.increase_max(35.0, 35.0)
    get_tree().call_group("game_world", "show_banner", "UNDERDOG DESPERTOU\nA fraqueza inicial virou forca ancestral.", 3.0)

func on_enemy_killed(region_index: int = -1, temperament: String = "") -> void:
    if heal_on_kill > 0.0:
        health.heal(heal_on_kill)
    animals_killed += 1
    if temperament in ["prey", "passive"]:
        modify_social(-0.25)
    if region_index >= 0 and region_index < region_affinities.size():
        increase_affinity(region_index, 1)

func can_eat_food(food_name: String) -> bool:
    return not (diet_style == "vegan" and food_name in ["carne", "peixe", "carne seca"])

func get_feeding_interval() -> float:
    return clampf(0.50 / maxf(0.25, consumption_speed), 0.10, 0.80)

func consume_food_bite(food_name: String, region_index: int, rarity_level: int, _bite_index: int, is_final: bool) -> bool:
    if not can_eat_food(food_name):
        if feeding_banner_cooldown <= 0.0:
            get_tree().call_group("game_world", "show_banner", "Sua Genetic vegana recusou alimento animal.", 1.2)
            feeding_banner_cooldown = 1.2
        return false

    if food_name == "fruto ancestral":
        fruit_count += 1
        get_tree().call_group("game_world", "request_branching_evolution")
        return true

    var clamped_rarity := clampi(rarity_level, 1, 4)
    var progress_per_bite: Array[float] = [0.0, 2.0, 6.0, 18.0, 60.0]
    var bite_progress: float = progress_per_bite[clamped_rarity]
    if is_final:
        bite_progress *= 2.0
    var diet_multiplier := 1.0
    if diet_style == "carnivore" and food_name in ["carne", "peixe", "carne seca"]:
        diet_multiplier = 1.25
    elif diet_style == "herbivore" and food_name not in ["carne", "peixe", "carne seca"]:
        diet_multiplier = 1.25
    bite_progress *= food_progress * diet_multiplier

    add_nature_xp(maxi(1, int(round(bite_progress))))
    health.heal((1.0 + float(clamped_rarity) * 0.55) * (0.85 + consumption_speed * 0.15))
    food_meter += bite_progress
    while food_meter >= 100.0:
        food_meter -= 100.0
        passive_regeneration += 0.02
    food_changed.emit(food_meter, 100.0)

    if is_final:
        fruit_count += 1
        modify_social(0.03 * float(clamped_rarity))
        increase_affinity(region_index, 1)
        if clamped_rarity >= 2 and feeding_banner_cooldown <= 0.0:
            get_tree().call_group("game_world", "show_banner", "%s consumida: +%d Progress" % [food_name.capitalize(), int(round(bite_progress))], 1.0)
            feeding_banner_cooldown = 0.8
    return true

func get_consumption_radius() -> float:
    var bonus := 1.0
    if miniboss_powers.has("mapinguari"):
        bonus = 1.35
    var size_reach := pow(maxf(0.60, body_size), 0.55)
    # Area curta: o personagem precisa realmente passar sobre o alimento.
    return 28.0 * consumption_distance * bonus * size_reach

func modify_social(amount: float) -> void:
    var affinity_bonus := 1.0 + float(spirit_affinities[3]) * 0.01 if amount > 0.0 else 1.0
    social = clampf(social + amount * affinity_bonus, 0.0, 50.0)

func can_add_companion() -> bool:
    return get_tree().get_nodes_in_group("companions").size() < 4

func register_companion(name_value: String) -> void:
    if companion_names.size() >= 4:
        return
    if not companion_names.has(name_value):
        companion_names.append(name_value)
        modify_social(0.4)

func register_peaceful_encounter(region_index: int, xp_amount: int = 12) -> void:
    peaceful_encounters += 1
    modify_social(0.6)
    add_nature_xp(xp_amount)
    increase_affinity(region_index, 2)

func apply_poi(poi_id: String, biome_index: int, preserve: bool) -> void:
    var reward := poi_reward_multiplier
    if preserve:
        modify_social(0.8 * reward)
        add_nature_xp(int(12.0 * reward))
        increase_affinity(biome_index, int(3.0 * reward))
        get_tree().call_group("game_world", "show_banner", "O lugar foi preservado: Social, Progress e afinidade aumentaram.", 2.0)
        return
    match poi_id:
        "algae_reef": health.increase_max(7.0 * reward, 7.0 * reward); ability_power += 1.0 * reward
        "carved_tree": add_nature_xp(int(float(xp_needed) * reward)); attack_damage += 1.0 * reward
        "chaos_tree": add_mutagen(int(5.0 * reward)); attack_damage *= 1.0 + 0.08 * reward
        "frozen_specimen": add_mutagen(int(10.0 * reward)); modify_social(1.0 * reward)
        "giant_mushroom": food_progress += 0.18 * reward; rarity_luck += 0.10 * reward
        "growing_tree": attack_damage *= 1.0 + 0.10 * reward
        "healing_pond": health.heal(health.max_health * 0.50); passive_regeneration += 0.35 * reward
        "lotus_plant": add_nature_xp(int(20.0 * reward)); attack_cooldown *= maxf(0.72, 1.0 - 0.06 * reward)
        "mud_pond": terrain_adaptation += 0.18 * reward; modify_social(0.5 * reward)
        "oasis": health.heal(health.max_health); passive_regeneration += 0.6 * reward
        "sun_dial": spirit_affinities[4 if currently_day else 5] += int(4.0 * reward)
        "unattended_nest": modify_social(1.5 * reward); add_mutagen(int(3.0 * reward))
        "bramble": take_damage(8.0); attack_damage *= 1.0 + 0.07 * reward
        "boss_area": add_mutagen(int(4.0 * reward)); rarity_luck += 0.05 * reward
    increase_affinity(biome_index, 2)
    _refresh_internal_stats()
    get_tree().call_group("game_world", "show_banner", "Forca de %s absorvida." % String(BiomeDB.POIS[poi_id]["name"]), 1.8)

func increase_affinity(region_index: int, amount: int) -> void:
    if region_index < 0 or region_index >= region_affinities.size():
        return
    region_affinities[region_index] = mini(25, region_affinities[region_index] + amount)

func heal_amount(amount: float) -> void:
    health.heal(amount)

func grant_adaptation(terrain: float, heat: float, cold: float) -> void:
    terrain_adaptation += terrain
    heat_adaptation += heat
    cold_adaptation += cold

func grant_senses(amount: float) -> void:
    senses += amount

func _apply_accessibility_settings() -> void:
    if is_instance_valid(camera):
        camera.position_smoothing_enabled = not SettingsManager.reduce_motion
        if SettingsManager.reduce_motion or not SettingsManager.screen_shake:
            camera.offset = Vector2.ZERO
            camera_shake_time = 0.0

func request_camera_shake(strength: float, duration: float) -> void:
    if not SettingsManager.screen_shake or SettingsManager.reduce_motion:
        return
    camera_shake_strength = maxf(camera_shake_strength, strength)
    camera_shake_time = maxf(camera_shake_time, duration)

func _update_camera_accessibility(delta: float) -> void:
    if not is_instance_valid(camera):
        return
    if camera_shake_time > 0.0 and SettingsManager.screen_shake and not SettingsManager.reduce_motion:
        camera_shake_time = maxf(0.0, camera_shake_time - delta)
        var strength := camera_shake_strength * SettingsManager.shake_intensity
        camera.offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
        if camera_shake_time <= 0.0:
            camera.offset = Vector2.ZERO
            camera_shake_strength = 0.0
    else:
        camera.offset = Vector2.ZERO
        camera_shake_time = 0.0
        camera_shake_strength = 0.0

func _get_aim_direction() -> Vector2:
    var base_direction := (get_global_mouse_position() - global_position).normalized()
    if base_direction.length() < 0.1:
        base_direction = Vector2.RIGHT
    var assist_level := SettingsManager.aim_assist
    if assist_level <= 0:
        return base_direction
    var max_distance := 230.0 if assist_level == 1 else 360.0
    var max_angle := deg_to_rad(18.0 if assist_level == 1 else 34.0)
    var best_direction := base_direction
    var best_score := 1.0e20
    for node in get_tree().get_nodes_in_group("enemies"):
        if not is_instance_valid(node) or not (node is Node2D):
            continue
        if node is Enemy and (node as Enemy).befriended:
            continue
        var target := node as Node2D
        var to_target := target.global_position - global_position
        var distance := to_target.length()
        if distance <= 0.1 or distance > max_distance:
            continue
        var candidate_direction := to_target / distance
        var angle := absf(base_direction.angle_to(candidate_direction))
        if angle > max_angle:
            continue
        var score := distance + angle * 180.0
        if score < best_score:
            best_score = score
            best_direction = candidate_direction
    return best_direction

func get_build_stats() -> Dictionary:
    var physical := get_effective_attack_damage() * 0.70 + health.max_health * 0.085
    var skill := ability_power
    var predator_affinity := clampi(spirit_affinities[0] + int(float(animals_killed) / 5.0), 0, 25)
    var prey_affinity := clampi(spirit_affinities[1] + int(float(fruit_count) / 5.0) + peaceful_encounters, 0, 25)
    var trickster_affinity := clampi(spirit_affinities[2] + int(round(dodge_chance * 20.0)), 0, 25)
    var imposing_affinity := clampi(int(round((body_size - 0.60) * 12.0 + max_plating / 20.0 + health.max_health / 90.0)), 0, 25)
    var gregarious_affinity := clampi(spirit_affinities[3] + int(round(social / 4.0)) + companion_names.size() * 2, 0, 25)
    var build_affinities: Array[int] = [predator_affinity, prey_affinity, trickster_affinity, imposing_affinity, gregarious_affinity]
    return {
        "level": level,
        "xp": xp,
        "xp_needed": xp_needed,
        "physical": physical,
        "skill": skill,
        "max_hp": health.max_health,
        "social": social,
        "speed": (move_speed * _size_speed_multiplier()) / 45.0,
        "damage": get_effective_attack_damage() / BASE_ATTACK_DAMAGE,
        "reloads": BASE_ATTACK_COOLDOWN / (attack_cooldown * _size_attack_penalty()),
        "attack_area": get_effective_attack_radius() / BASE_ATTACK_RADIUS,
        "attack_penalty": attack_penalty * _size_attack_penalty(),
        "size": body_size,
        "regeneration": passive_regeneration,
        "madness": madness,
        "damage_resistance": damage_reduction,
        "poison_resistance": poison_resistance,
        "dodge": get_effective_dodge(),
        "heat_adaptation": heat_adaptation,
        "cold_adaptation": cold_adaptation,
        "food_progress": food_progress,
        "consumption_speed": consumption_speed,
        "consumption_distance": consumption_distance,
        "terrain_adaptation": terrain_adaptation,
        "senses": senses,
        "affinities": region_affinities.duplicate(),
        "build_affinities": build_affinities,
        "plating": plating,
        "max_plating": max_plating,
        "current_weapon": WeaponDB.get_weapon_name(current_weapon),
        "unlocked_weapons": unlocked_weapons.keys(),
        "miniboss_powers": miniboss_powers.keys(),
        "fruit_count": fruit_count,
        "animals_killed": animals_killed,
        "peaceful_encounters": peaceful_encounters,
        "companions": companion_names.duplicate(),
        "food_meter": food_meter,
        "mutagen": mutagen,
        "genetic": GeneticsDB.GENETICS.get(GameSession.selected_genetic, GeneticsDB.GENETICS["standard"])["name"],
        "specialisations": specialisations.duplicate(true),
        "internal_stats": internal_stats.duplicate(true),
        "spirit_affinities": spirit_affinities.duplicate(),
        "equipped_attacks": equipped_attacks.duplicate(),
        "equipped_ultimate": equipped_ultimate,
        "equipped_movement": equipped_movement,
    }

func _on_health_changed(current: float, maximum: float) -> void:
    health_changed.emit(current, maximum)

func _on_died() -> void:
    if use_animated_sprite and animated_sprite != null and animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation("dead"):
        animated_sprite.play("dead")
    player_died.emit()

func _draw() -> void:
    if use_animated_sprite or sprite.texture != null:
        return
    var body_color := Color("#e7d7a8")
    if invulnerable:
        body_color.a = 0.45
    draw_circle(Vector2.ZERO, 19.0 * body_size, body_color)
    if SettingsManager.high_contrast:
        draw_arc(Vector2.ZERO, 21.0 * body_size, 0.0, TAU, 32, Color.BLACK, maxf(2.0, 3.0 * body_size))
    draw_circle(Vector2(0, -4.0 * body_size), 10.0 * body_size, Color("#3b2d24"))
    var aim := (get_global_mouse_position() - global_position).normalized()
    if aim.length() < 0.1:
        aim = Vector2.RIGHT
    draw_line(Vector2.ZERO, aim * 30.0 * body_size, Color("#fff4cc"), maxf(3.0, 5.0 * body_size))
