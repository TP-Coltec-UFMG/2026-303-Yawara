class_name Enemy
extends CharacterBody2D

const SpriteAnimUtils := preload("res://scripts/core/sprite_anim_utils.gd")
const ANIMATED_VISUALS := {
    "marimbondo_onca": {"path":"res://assets/sprites/enemies/ninja_pack/yellow_bat.png", "kind":"grid4", "scale":1.0},
    "minhocao_areia": {"path":"res://assets/sprites/enemies/ninja_pack/snake3.png", "kind":"grid4", "scale":1.0},
    "veado_bravo": {"path":"res://assets/sprites/enemies/ninja_pack/wildboar.png", "kind":"side2", "scale":1.1},
    "furao_ladrao": {"path":"res://assets/sprites/enemies/ninja_pack/racoon.png", "kind":"side2", "scale":1.0},
    "sapo_aranha": {"path":"res://assets/sprites/enemies/ninja_pack/spider_yellow.png", "kind":"grid4", "scale":1.0},
    "fruta_espinho": {"path":"res://assets/sprites/enemies/ninja_pack/mushroom2.png", "kind":"grid4", "scale":1.0},
    "peixe_cuspidor": {"path":"res://assets/sprites/enemies/ninja_pack/fish.png", "kind":"grid4", "scale":1.0},
    "jabuti_ancestral": {"path":"res://assets/sprites/enemies/ninja_pack/frog.png", "kind":"side2", "scale":1.05},
    "peixe_boi_jovem": {"path":"res://assets/sprites/enemies/ninja_pack/pig_black.png", "kind":"side2", "scale":1.1},
    "coruja_oco": {"path":"res://assets/sprites/enemies/ninja_pack/owl.png", "kind":"grid4", "scale":1.0},
    "lebre_pampas": {"path":"res://assets/sprites/enemies/ninja_pack/mouse.png", "kind":"grid4", "scale":0.9},
    "onca_corrompida": {"path":"res://assets/sprites/enemies/ninja_pack/beast.png", "kind":"grid4", "scale":1.1},
    "jaguatirica_corrompida": {"path":"res://assets/sprites/enemies/ninja_pack/beast2.png", "kind":"grid4", "scale":1.05},
    "gato_mato": {"path":"res://assets/sprites/enemies/ninja_pack/cat_orange.png", "kind":"side2", "scale":1.0},
    "queixada": {"path":"res://assets/sprites/enemies/ninja_pack/wildboar.png", "kind":"side2", "scale":1.1},
    "quati": {"path":"res://assets/sprites/enemies/ninja_pack/racoon.png", "kind":"side2", "scale":1.0},
    "graxaim": {"path":"res://assets/sprites/enemies/ninja_pack/dog.png", "kind":"side2", "scale":1.05},
    "lobo_guara": {"path":"res://assets/sprites/enemies/ninja_pack/dog_black.png", "kind":"side2", "scale":1.05},
    "bugio": {"path":"res://assets/sprites/enemies/ninja_pack/monkey_brown.png", "kind":"side2", "scale":1.0},
    "carcara": {"path":"res://assets/sprites/enemies/ninja_pack/parrot_red.png", "kind":"side2", "scale":1.0},
    "quero_quero": {"path":"res://assets/sprites/enemies/ninja_pack/parrot_red.png", "kind":"side2", "scale":0.95},
    "veado_campeiro": {"path":"res://assets/sprites/enemies/ninja_pack/horse_brown.png", "kind":"side2", "scale":1.1},
    "ema": {"path":"res://assets/sprites/enemies/ninja_pack/chicken_brown.png", "kind":"side2", "scale":1.0},
    "tatu_peba": {"path":"res://assets/sprites/enemies/ninja_pack/mole.png", "kind":"grid4", "scale":0.95},
    "arara": {"path":"res://assets/sprites/enemies/ninja_pack/parrot_red.png", "kind":"side2", "scale":0.95},
    "mico_leao": {"path":"res://assets/sprites/enemies/ninja_pack/monkey_brown.png", "kind":"side2", "scale":0.95},
    "paca": {"path":"res://assets/sprites/enemies/ninja_pack/mouse.png", "kind":"grid4", "scale":0.9},
    "capivara_amazonica": {"path":"res://assets/sprites/enemies/ninja_pack/pig_black.png", "kind":"side2", "scale":1.15},
    "capivara_pantanal": {"path":"res://assets/sprites/enemies/ninja_pack/pig_black.png", "kind":"side2", "scale":1.15},
    "tamandua_bandeira": {"path":"res://assets/sprites/enemies/ninja_pack/beast.png", "kind":"grid4", "scale":1.1}
}

@onready var health: HealthComponent = $HealthComponent
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

var player: Player
var biome_index := 0
var species_id := "creature"
var creature_name := "Criatura"
var temperament := "passive"
var diet := "herbivore"
var body_size := 1.0
var move_speed := 110.0
var contact_damage := 6.0
var friend_threshold := 12.0
var difficulty := 1.0
var mechanic := ""
var evolution_tier := 0
var is_alpha := false
var plating := 0.0
var max_plating := 0.0
var special_timer := 0.8
var dash_attack_left := 0.0
var dash_attack_direction := Vector2.ZERO
var dash_damage_ready := false
var hidden_timer := 0.0
var peaceful_time := 0.0
var friendship_checked := false

var attack_timer := 0.0
var attack_windup := 0.0
var attack_target_type := ""
var attack_target: Node2D
var wander_timer := 0.0
var wander_direction := Vector2.ZERO
var target_creature: Enemy
var hostile_to_player := 0.0
var flash_time := 0.0
var slow_timer := 0.0
var slow_factor := 1.0
var last_hit_by_player := false
var social_penalty_applied := false
var befriended := false
var companion_attack_timer := 0.0
var health_bar_timer := 0.0
var shell_open_timer := 0.0
var food_search_timer := 0.0
var food_target: Node2D
var flee_timer := 0.0
var steering_phase := 0.0
var use_animated_sprite := false
var animated_mode := "none"
var facing_direction := "right"

func _ready() -> void:
    motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
    up_direction = Vector2.ZERO
    add_to_group("enemies")
    add_to_group("creatures")
    health.died.connect(_on_died)
    health.health_changed.connect(_on_health_changed)
    _ensure_animated_sprite()
    player = get_tree().get_first_node_in_group("player") as Player
    steering_phase = randf_range(0.0, TAU)
    _pick_wander_direction()

func configure_creature(species: Dictionary, biome: int, difficulty_value: float) -> void:
    biome_index = clampi(biome, 0, BiomeDB.BIOMES.size() - 1)
    difficulty = maxf(0.75, difficulty_value)
    species_id = String(species.get("id", "creature"))
    creature_name = String(species.get("name", "Criatura"))
    temperament = String(species.get("temperament", "passive"))
    diet = String(species.get("diet", "herbivore"))
    mechanic = String(species.get("mechanic", ""))
    evolution_tier = _roll_evolution_tier(species)
    if evolution_tier > 0:
        var evolutions: Array = species.get("evolutions", [])
        var evolved: Dictionary = evolutions[mini(evolution_tier - 1, evolutions.size() - 1)]
        creature_name += String(evolved.get("suffix", "+"))
        species = species.duplicate(true)
        for key in evolved: species[key] = evolved[key]
        mechanic = String(species.get("mechanic", mechanic))
    is_alpha = _roll_alpha()
    body_size = float(species.get("size", 1.0)) * (1.25 if is_alpha else 1.0)
    move_speed = float(species.get("speed", 110.0)) * (0.92 + difficulty * 0.05) * (1.10 if is_alpha else 1.0)
    contact_damage = float(species.get("damage", 6.0)) * (0.72 + difficulty * 0.14) * GameSession.pressure_multiplier("enemy_damage") * (1.45 if is_alpha else 1.0)
    friend_threshold = float(species.get("friend", 12.0))
    var alpha_health := 2.0 if is_alpha else 1.0
    health.setup(float(species.get("hp", 45.0)) * (1.06 + difficulty * 0.20) * GameSession.pressure_multiplier("enemy_hp") * alpha_health)
    max_plating = float(species.get("plating", 0.0)) * (1.5 if is_alpha else 1.0)
    plating = max_plating

    var shape := collision_shape.shape.duplicate() as CircleShape2D
    shape.radius = 16.0 * body_size
    collision_shape.shape = shape

    if temperament == "predator":
        add_to_group("predators")
    elif temperament == "prey":
        add_to_group("prey")
    elif temperament == "passive":
        add_to_group("prey")
    elif temperament == "territorial":
        add_to_group("territorial")

    _try_load_sprite()
    queue_redraw()

func _roll_evolution_tier(species: Dictionary) -> int:
    var evolutions: Array = species.get("evolutions", [])
    if evolutions.is_empty(): return 0
    var progress := GameSession.elapsed / GameSession.FINAL_BOSS_SECONDS
    var tier := 0
    if progress >= 0.34 and randf() < 0.30 + progress * 0.25: tier = 1
    if evolutions.size() > 1 and progress >= 0.72 and randf() < 0.24 + progress * 0.18: tier = 2
    if GameSession.is_endless(): tier = mini(evolutions.size(), 1 + int((GameSession.elapsed - GameSession.FINAL_BOSS_SECONDS) / 360.0))
    return clampi(tier, 0, evolutions.size())

func _roll_alpha() -> bool:
    var chance := 0.06 * GameSession.pressure_multiplier("alpha")
    if is_instance_valid(player) and GameSession.selected_genetic == "challenger": chance += 0.30
    chance += minf(0.16, GameSession.elapsed / 2400.0)
    return randf() < chance

func configure(new_region: int, _archetype: int, difficulty_value: float) -> void:
    var pool: Array = BiomeDB.get_creature_pool(new_region)
    if pool.is_empty():
        return
    configure_creature(pool[randi() % pool.size()], new_region, difficulty_value)

func _ensure_animated_sprite() -> void:
    if animated_sprite != null:
        return
    animated_sprite = AnimatedSprite2D.new()
    animated_sprite.name = "AnimatedSprite2D"
    animated_sprite.z_index = 3
    add_child(animated_sprite)

func _try_load_sprite() -> void:
    if _load_local_creature_frames():
        return
    if _load_mapped_pack_sprite():
        return
    var path := "res://assets/sprites/creatures/%s.png" % species_id
    if ResourceLoader.exists(path):
        sprite.texture = load(path) as Texture2D
        var target_size := 54.0 * body_size
        var max_side := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
        sprite.scale = Vector2.ONE * (target_size / maxf(1.0, max_side))

func _apply_animated_scale_from_dimensions(source_width: float, source_height: float, target_size: float = 54.0) -> void:
    var max_side: float = maxf(1.0, maxf(source_width, source_height))
    var fit_scale: float = (target_size * body_size) / max_side
    animated_sprite.scale = Vector2.ONE * fit_scale
    animated_sprite.visible = true
    sprite.visible = false
    use_animated_sprite = true

func _load_local_creature_frames() -> bool:
    var dir := "res://assets/sprites/creatures/frames/%s" % species_id
    if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir)):
        return false
    var paths: Array[String] = []
    for i in range(16):
        var frame_path := "%s/%02d.png" % [dir, i]
        if ResourceLoader.exists(frame_path):
            paths.append(frame_path)
    if paths.is_empty():
        return false
    animated_sprite.sprite_frames = SpriteAnimUtils.create_file_frames(paths)
    animated_mode = "side2"
    var first_tex := load(paths[0]) as Texture2D
    _apply_animated_scale_from_dimensions(float(first_tex.get_width()), float(first_tex.get_height()), 56.0)
    animated_sprite.play("walk_side")
    return true

func _load_mapped_pack_sprite() -> bool:
    if not ANIMATED_VISUALS.has(species_id):
        return false
    var config: Dictionary = ANIMATED_VISUALS[species_id]
    var path := String(config.get("path", ""))
    if not ResourceLoader.exists(path):
        return false
    var tex := load(path) as Texture2D
    var kind := String(config.get("kind", "grid4"))
    if kind == "grid4":
        animated_sprite.sprite_frames = SpriteAnimUtils.create_grid4_frames(tex)
        animated_mode = "grid4"
        _apply_animated_scale_from_dimensions(16.0, 16.0, 54.0 * float(config.get("scale", 1.0)))
    else:
        animated_sprite.sprite_frames = SpriteAnimUtils.create_side_frames(tex)
        animated_mode = "side2"
        var frame_count: int = max(1, int(tex.get_width() / 16))
        _apply_animated_scale_from_dimensions(float(tex.get_width()) / float(frame_count), float(tex.get_height()), 54.0 * float(config.get("scale", 1.0)))
    var first_anim := "idle_right" if animated_mode == "grid4" else "idle_side"
    animated_sprite.play(first_anim)
    return true

func _physics_process(delta: float) -> void:
    attack_timer = maxf(0.0, attack_timer - delta)
    companion_attack_timer = maxf(0.0, companion_attack_timer - delta)
    hostile_to_player = maxf(0.0, hostile_to_player - delta)
    flash_time = maxf(0.0, flash_time - delta)
    health_bar_timer = maxf(0.0, health_bar_timer - delta)
    wander_timer -= delta
    if slow_timer > 0.0:
        slow_timer -= delta
    else:
        slow_factor = 1.0
    special_timer = maxf(0.0, special_timer - delta)
    hidden_timer = maxf(0.0, hidden_timer - delta)
    shell_open_timer = maxf(0.0, shell_open_timer - delta)
    food_search_timer = maxf(0.0, food_search_timer - delta)
    flee_timer = maxf(0.0, flee_timer - delta)
    steering_phase += delta * (2.0 + move_speed / 180.0)
    if not last_hit_by_player and not befriended:
        peaceful_time += delta

    if attack_windup > 0.0:
        attack_windup -= delta
        velocity = Vector2.ZERO
        if attack_windup <= 0.0:
            _resolve_attack()
    else:
        if not is_instance_valid(player):
            player = get_tree().get_first_node_in_group("player") as Player
            return

        if dash_attack_left > 0.0:
            dash_attack_left -= delta
            velocity = dash_attack_direction * move_speed * 2.8
            if dash_damage_ready and global_position.distance_to(player.global_position) <= _attack_range() + 16.0:
                player.take_damage(contact_damage * 1.18)
                dash_damage_ready = false
        elif befriended:
            _update_companion(delta)
        else:
            _update_ecosystem(delta)
            _try_spontaneous_friendship()
    move_and_slide()
    _update_enemy_animation()
    if get_slide_collision_count() > 0 and dash_attack_left <= 0.0:
        _pick_wander_direction()
    queue_redraw()

func _update_enemy_animation() -> void:
    if not use_animated_sprite or animated_sprite == null or animated_sprite.sprite_frames == null:
        return
    var tint := Color.WHITE
    if befriended:
        tint = Color(0.78, 1.0, 0.82, 1.0)
    elif flash_time > 0.0 and not SettingsManager.reduce_flashes:
        tint = Color.WHITE
    animated_sprite.modulate = tint

    var prefix := "idle"
    if attack_windup > 0.0 or dash_attack_left > 0.0:
        prefix = "attack"
    elif velocity.length() > 12.0:
        prefix = "walk"

    var anim := "%s_side" % prefix
    if animated_mode == "grid4":
        if velocity.x > 4.0:
            facing_direction = "right"
        elif velocity.x < -4.0:
            facing_direction = "left"
        anim = "%s_%s" % [prefix, facing_direction]
        if not animated_sprite.sprite_frames.has_animation(anim):
            anim = "%s_right" % prefix
    else:
        if velocity.x > 4.0:
            animated_sprite.flip_h = false
        elif velocity.x < -4.0:
            animated_sprite.flip_h = true
    if animated_sprite.sprite_frames.has_animation(anim) and animated_sprite.animation != anim:
        animated_sprite.play(anim)

func _update_ecosystem(_delta: float) -> void:
    var player_distance := global_position.distance_to(player.global_position)
    var desired := Vector2.ZERO
    var speed_scale := slow_factor

    if flee_timer > 0.0:
        velocity = player.global_position.direction_to(global_position) * move_speed * 1.45 * slow_factor
        return

    if mechanic in ["sand_ambush", "sand_ambush_fast"] and hostile_to_player <= 0.0:
        if player_distance > 245.0 or player.velocity.length() < 30.0:
            modulate.a = 0.24
            velocity = Vector2.ZERO
            return
        if special_timer <= 0.0:
            modulate.a = 1.0
            special_timer = 3.2 if mechanic == "sand_ambush" else 2.3
            dash_attack_direction = global_position.direction_to(player.global_position)
            dash_attack_left = 0.32
            dash_damage_ready = true
            hostile_to_player = 7.0
            return
        modulate.a = 0.34
        velocity = Vector2.ZERO
        return

    if mechanic == "mimic" and hostile_to_player <= 0.0 and player_distance > 92.0:
        velocity = Vector2.ZERO
        return

    if temperament == "prey":
        var danger := _nearest_predator(325.0)
        if mechanic == "poison_contact" and hostile_to_player > 0.0 and player_distance < 190.0:
            desired = global_position.direction_to(player.global_position)
            _try_attack_player(player_distance)
        elif is_instance_valid(danger):
            desired = danger.global_position.direction_to(global_position)
            speed_scale *= 1.28
        elif hostile_to_player > 0.0 and player_distance < 460.0:
            desired = player.global_position.direction_to(global_position)
            speed_scale *= 1.22
        else:
            desired = _forage_or_wander()

    elif temperament == "predator":
        var prey_target := _nearest_prey(430.0)
        var social_deterrence := clampf((player.social - 8.0) * 8.0, 0.0, 120.0)
        var player_aggro_range := 250.0 - social_deterrence
        var packmate := _nearest_packmate(180.0)
        if mechanic in ["rush_flee", "rush_combo"] and health.ratio() < 0.28:
            desired = player.global_position.direction_to(global_position)
            speed_scale *= 1.38
        elif hostile_to_player > 0.0 or player_distance < player_aggro_range:
            desired = global_position.direction_to(player.global_position)
            _try_attack_player(player_distance)
            if is_instance_valid(packmate) and packmate.global_position.distance_to(global_position) > 44.0:
                desired = (desired + global_position.direction_to(packmate.global_position) * 0.35).normalized()
        elif is_instance_valid(prey_target):
            target_creature = prey_target
            desired = global_position.direction_to(prey_target.global_position)
            _try_attack_creature(prey_target)
            if is_instance_valid(packmate) and packmate.global_position.distance_to(global_position) > 60.0:
                desired = (desired + global_position.direction_to(packmate.global_position) * 0.25).normalized()
        elif is_instance_valid(packmate) and packmate.global_position.distance_to(global_position) > 58.0:
            desired = global_position.direction_to(packmate.global_position)
            speed_scale *= 1.05
        else:
            desired = _forage_or_wander()

    elif temperament == "territorial":
        var territory_range := 145.0 - clampf((player.social - 10.0) * 4.0, 0.0, 60.0)
        if hostile_to_player > 0.0 or player_distance < territory_range:
            desired = global_position.direction_to(player.global_position)
            _try_attack_player(player_distance)
        else:
            desired = _wander()

    else:
        if hostile_to_player > 0.0:
            if mechanic in ["plated", "heavy_plating", "retaliate_tank"] or body_size >= 0.90:
                desired = global_position.direction_to(player.global_position)
                _try_attack_player(player_distance)
            else:
                desired = player.global_position.direction_to(global_position)
                speed_scale *= 1.18
        else:
            desired = _forage_or_wander()

    var separation := _separation_vector(48.0 + body_size * 12.0)
    desired = (desired + separation * 0.72).normalized() if desired.length() > 0.05 else separation
    if mechanic == "zigzag" and desired.length() > 0.05:
        desired = desired.rotated(sin(steering_phase * 2.1) * 0.58)
        speed_scale *= 1.12
    velocity = desired * move_speed * speed_scale
    _try_mechanic_attack(player_distance)

    if player_distance < 76.0 and Input.is_action_just_pressed("interact") and not _player_has_food_in_reach():
        try_befriend()

func _update_companion(_delta: float) -> void:
    var distance := global_position.distance_to(player.global_position)
    var target: Node2D = _nearest_hostile(340.0)
    if is_instance_valid(target):
        velocity = global_position.direction_to(target.global_position) * move_speed * 1.08
        if global_position.distance_to(target.global_position) < 35.0 * body_size and companion_attack_timer <= 0.0:
            companion_attack_timer = 0.95
            if target.has_method("take_ecosystem_damage"):
                target.call("take_ecosystem_damage", contact_damage * 0.70)
            elif target.has_method("take_damage"):
                target.call("take_damage", contact_damage * 0.70)
    elif distance > 105.0:
        velocity = global_position.direction_to(player.global_position) * move_speed * 1.15
    else:
        velocity = _wander() * move_speed * 0.35

func _wander() -> Vector2:
    if wander_timer <= 0.0:
        _pick_wander_direction()
    return wander_direction

func _pick_wander_direction() -> void:
    wander_timer = randf_range(1.2, 3.8)
    wander_direction = Vector2.from_angle(randf_range(0.0, TAU))
    if randf() < 0.24:
        wander_direction = Vector2.ZERO

func _forage_or_wander() -> Vector2:
    if food_search_timer <= 0.0 or not is_instance_valid(food_target):
        food_search_timer = randf_range(0.45, 0.85)
        food_target = _nearest_edible_food(260.0)
    if not is_instance_valid(food_target):
        return _wander()
    var distance := global_position.distance_to(food_target.global_position)
    if distance <= 27.0 * body_size:
        if mechanic in ["plated", "heavy_plating", "retaliate_tank"]:
            shell_open_timer = 0.9
        if food_target.has_method("consume_by_creature"):
            food_target.call("consume_by_creature")
        food_target = null
        wander_timer = 0.0
        return Vector2.ZERO
    return global_position.direction_to(food_target.global_position)

func _nearest_edible_food(max_distance: float) -> Node2D:
    var best: Node2D
    var best_distance := max_distance
    for node in get_tree().get_nodes_in_group("food"):
        if not is_instance_valid(node) or not (node is Node2D):
            continue
        var food_name := String(node.get("fruit_name"))
        var is_meat := food_name in ["carne", "peixe", "carne seca"]
        if diet == "carnivore" and not is_meat:
            continue
        if diet == "herbivore" and is_meat:
            continue
        var candidate := node as Node2D
        var distance := global_position.distance_to(candidate.global_position)
        if distance < best_distance:
            best_distance = distance
            best = candidate
    return best

func _separation_vector(radius: float) -> Vector2:
    var separation := Vector2.ZERO
    for node in get_tree().get_nodes_in_group("creatures"):
        if node == self or not is_instance_valid(node) or not (node is Node2D):
            continue
        var other := node as Node2D
        var offset := global_position - other.global_position
        var distance := offset.length()
        if distance > 0.1 and distance < radius:
            separation += offset.normalized() * (1.0 - distance / radius)
    return separation.normalized() if separation.length() > 0.01 else Vector2.ZERO

func _player_has_food_in_reach() -> bool:
    if not is_instance_valid(player):
        return false
    var reach := player.get_consumption_radius()
    for node in get_tree().get_nodes_in_group("food"):
        if is_instance_valid(node) and node is Node2D and player.global_position.distance_to(node.global_position) <= reach:
            return true
    return false

func _nearest_predator(max_distance: float) -> Enemy:
    var best: Enemy
    var best_distance := max_distance
    for node in get_tree().get_nodes_in_group("predators"):
        if node == self or not is_instance_valid(node) or node.befriended:
            continue
        var d := global_position.distance_to(node.global_position)
        if d < best_distance:
            best_distance = d
            best = node as Enemy
    return best

func _nearest_prey(max_distance: float) -> Enemy:
    var best: Enemy
    var best_distance := max_distance
    for node in get_tree().get_nodes_in_group("prey"):
        if node == self or not is_instance_valid(node) or node.befriended:
            continue
        var d := global_position.distance_to(node.global_position)
        if d < best_distance:
            best_distance = d
            best = node as Enemy
    return best

func _nearest_packmate(max_distance: float) -> Enemy:
    var best: Enemy
    var best_distance := max_distance
    for node in get_tree().get_nodes_in_group("predators"):
        if node == self or not is_instance_valid(node) or node.befriended:
            continue
        var mate := node as Enemy
        if mate.species_id != species_id:
            continue
        var d := global_position.distance_to(mate.global_position)
        if d < best_distance:
            best_distance = d
            best = mate
    return best

func _nearest_hostile(max_distance: float) -> Node2D:
    var best: Node2D
    var best_distance := max_distance
    for node in get_tree().get_nodes_in_group("enemies"):
        if node == self or not is_instance_valid(node) or not (node is Node2D):
            continue
        if node is Enemy:
            var candidate := node as Enemy
            if candidate.befriended:
                continue
            if candidate.temperament != "predator" and candidate.hostile_to_player <= 0.0:
                continue
        var target := node as Node2D
        var d := global_position.distance_to(target.global_position)
        if d < best_distance:
            best_distance = d
            best = target
    return best

func _attack_range() -> float:
    return 28.0 + 18.0 * body_size

func _try_attack_player(distance: float) -> void:
    if distance <= _attack_range() and attack_timer <= 0.0 and attack_windup <= 0.0:
        attack_windup = 0.34 + 0.05 * body_size
        attack_timer = 1.05
        attack_target_type = "player"
        attack_target = player
        if mechanic in ["plated", "heavy_plating", "retaliate_tank"]:
            shell_open_timer = attack_windup + 0.55

func _try_mechanic_attack(player_distance: float) -> void:
    if special_timer > 0.0 or not is_instance_valid(player): return
    if mechanic in ["rush_flee", "rush_combo"] and health.ratio() < 0.28: return
    match mechanic:
        "flying_dash", "poison_cloud", "rush_flee", "rush_combo", "mimic", "mimic_rush", "mimic_burst", "sand_ambush_fast":
            if player_distance < 330.0:
                special_timer = randf_range(2.0, 3.4)
                dash_attack_direction = global_position.direction_to(player.global_position)
                dash_attack_left = 0.22
                dash_damage_ready = true
        "water_ranged", "amphibious_ranged", "stone_throw", "creature_throw", "tongue_stun", "tongue_fast":
            if player_distance < 430.0:
                special_timer = 1.4 if mechanic in ["tongue_fast", "amphibious_ranged"] else 2.2
                var effect := "slow" if mechanic in ["tongue_stun", "tongue_fast"] else ""
                get_tree().call_group("game_world", "spawn_boss_projectile", global_position, global_position.direction_to(player.global_position), 390.0, contact_damage * 0.78, 6.0, effect)
        "thief":
            var stolen_food := _nearest_edible_food(42.0)
            if is_instance_valid(stolen_food) and stolen_food.has_method("consume_by_creature"):
                stolen_food.call("consume_by_creature")
                special_timer = 4.0
                flee_timer = 2.2
                get_tree().call_group("game_world", "show_banner", "%s roubou comida do chão!" % creature_name, 1.0)
        "burrow_escape", "burrow_decoy":
            if player_distance < 150.0:
                special_timer = 5.0
                hidden_timer = 1.1
                modulate.a = 0.25
                velocity = player.global_position.direction_to(global_position) * move_speed * 1.5

func _try_spontaneous_friendship() -> void:
    if friendship_checked or peaceful_time < 14.0 or temperament == "predator" or not is_instance_valid(player): return
    friendship_checked = true
    var chance := clampf((player.social - friend_threshold) * 0.025, 0.0, 0.48)
    if randf() < chance and player.can_add_companion():
        force_befriend()
        get_tree().call_group("game_world", "show_banner", "%s se aproximou por vontade propria." % creature_name, 1.8)

func _try_attack_creature(target: Enemy) -> void:
    if not is_instance_valid(target):
        return
    if global_position.distance_to(target.global_position) <= _attack_range() and attack_timer <= 0.0 and attack_windup <= 0.0:
        attack_windup = 0.36 + 0.05 * body_size
        attack_timer = 1.10
        attack_target_type = "creature"
        attack_target = target

func _resolve_attack() -> void:
    var target := attack_target
    var distance_ok := is_instance_valid(target) and global_position.distance_to(target.global_position) <= _attack_range() + 8.0
    if distance_ok:
        if attack_target_type == "player" and target.has_method("take_damage"):
            if mechanic == "poison_contact" and target.has_method("take_poison_damage"):
                target.call("take_poison_damage", contact_damage)
            else:
                target.call("take_damage", contact_damage)
        elif attack_target_type == "creature" and target.has_method("take_ecosystem_damage"):
            target.call("take_ecosystem_damage", contact_damage)
    attack_target = null
    attack_target_type = ""

func try_befriend() -> void:
    if befriended or temperament == "predator" and player.social < friend_threshold + 4.0:
        return
    if not player.can_add_companion():
        get_tree().call_group("game_world", "show_banner", "Seu grupo já está cheio (máx. 4 companheiros).", 1.5)
        return
    if player.social < friend_threshold:
        get_tree().call_group("game_world", "show_banner", "%s ainda não confia em você. Social %.0f / %.0f" % [creature_name, player.social, friend_threshold], 1.5)
        return
    befriended = true
    remove_from_group("enemies")
    remove_from_group("predators")
    remove_from_group("prey")
    remove_from_group("territorial")
    add_to_group("companions")
    collision_layer = 0
    collision_mask = 0
    hostile_to_player = 0.0
    player.modify_social(0.5)
    player.register_companion(creature_name)
    get_tree().call_group("game_world", "show_banner", "%s decidiu acompanhar você." % creature_name, 1.8)
    queue_redraw()

func force_befriend() -> bool:
    if befriended:
        return true
    if is_instance_valid(player) and not player.can_add_companion():
        return false
    befriended = true
    remove_from_group("enemies")
    remove_from_group("predators")
    remove_from_group("prey")
    remove_from_group("territorial")
    add_to_group("companions")
    collision_layer = 0
    collision_mask = 0
    hostile_to_player = 0.0
    if is_instance_valid(player):
        player.register_companion(creature_name)
    queue_redraw()
    return true

func take_damage(amount: float) -> void:
    if befriended:
        return
    last_hit_by_player = true
    peaceful_time = 0.0
    hostile_to_player = 9.0
    if (temperament == "prey" or temperament == "passive") and not social_penalty_applied and is_instance_valid(player):
        social_penalty_applied = true
        player.modify_social(-0.7)
    if is_alpha and is_instance_valid(player): amount *= player.alpha_damage_multiplier
    _apply_incoming_damage(amount)
    flash_time = 0.0 if SettingsManager.reduce_flashes else 0.08

func take_ecosystem_damage(amount: float) -> void:
    if befriended:
        return
    last_hit_by_player = false
    _apply_incoming_damage(amount)
    flash_time = 0.0 if SettingsManager.reduce_flashes else 0.08

func apply_slow(factor: float, duration: float) -> void:
    slow_factor = minf(slow_factor, clampf(factor, 0.25, 1.0))
    slow_timer = maxf(slow_timer, duration)

func _apply_incoming_damage(amount: float) -> void:
    if plating > 0.0:
        var armor_efficiency := 0.25 if shell_open_timer > 0.0 else 1.0
        var absorbed := minf(plating, amount * armor_efficiency)
        plating -= absorbed
        amount -= absorbed
    if amount > 0.0: health.damage(amount)

func _on_health_changed(_current: float, _maximum: float) -> void:
    health_bar_timer = 2.6

func _on_died() -> void:
    if last_hit_by_player and is_instance_valid(player):
        player.on_enemy_killed(biome_index, temperament)
        if is_alpha:
            player.add_mutagen(4 + evolution_tier * 2)
        elif evolution_tier > 0 and randf() < 0.35:
            player.add_mutagen(1)
    if mechanic == "poison_cloud":
        for i in range(8):
            var direction := Vector2.from_angle(TAU * float(i) / 8.0)
            get_tree().call_group("game_world", "spawn_boss_projectile", global_position, direction, 145.0, contact_damage * 0.35, 8.0, "poison")
    var meat_count := 1
    if body_size >= 1.30:
        meat_count += 1
    if is_alpha:
        meat_count += 1
    for index in range(meat_count):
        var food_rarity := _roll_meat_rarity()
        var offset := Vector2.from_angle(TAU * float(index) / float(meat_count)) * (10.0 + float(index) * 3.0)
        get_tree().call_group("game_world", "spawn_fruit", global_position + offset, "carne", biome_index, food_rarity)
    queue_free()

func _roll_meat_rarity() -> int:
    var roll := randf()
    var rarity := 1
    if roll >= 0.99:
        rarity = 4
    elif roll >= 0.94:
        rarity = 3
    elif roll >= 0.75:
        rarity = 2
    if evolution_tier > 0 and randf() < 0.30:
        rarity = mini(4, rarity + 1)
    if is_alpha:
        rarity = maxi(2, rarity)
    return rarity

func _draw_health_bar(radius: float) -> void:
    var visible_bar := health_bar_timer > 0.0 or health.current_health < health.max_health
    if is_instance_valid(player) and global_position.distance_to(player.global_position) < 160.0:
        visible_bar = true
    if not visible_bar:
        return
    var width := 34.0 * body_size
    var pos := Vector2(-width * 0.5, -radius - 16.0)
    draw_rect(Rect2(pos, Vector2(width, 5.0)), Color(0.04, 0.04, 0.04, 0.85), true)
    draw_rect(Rect2(pos + Vector2(1,1), Vector2((width - 2.0) * health.ratio(), 3.0)), Color("#d65a50") if not befriended else Color("#66c88a"), true)
    draw_rect(Rect2(pos, Vector2(width, 5.0)), Color("#ead6a8", 0.9), false, 1.0)

func _draw_attack_telegraph(radius: float) -> void:
    if attack_windup <= 0.0 or not is_instance_valid(attack_target):
        return
    var aim := global_position.direction_to(attack_target.global_position)
    var center := aim * radius * 0.70
    var attack_radius := radius * 0.95
    draw_circle(center, attack_radius, Color(1.0, 0.25, 0.25, 0.15))
    draw_arc(center, attack_radius, 0.0, TAU, 24, Color(1.0, 0.45, 0.45, 0.95), 2.0)

func _draw() -> void:
    var biome_data: Dictionary = BiomeDB.get_biome(biome_index)
    var c: Color = biome_data["accent"]
    if temperament == "predator":
        c = Color("#a5483e")
    elif temperament == "territorial":
        c = Color("#bd803d")
    elif temperament == "prey":
        c = c.lightened(0.18)
    if flash_time > 0.0:
        c = Color.WHITE
    if befriended:
        c = Color("#66c88a")

    if hidden_timer <= 0.0 and mechanic not in ["sand_ambush", "sand_ambush_fast"] and modulate.a < 1.0:
        modulate.a = 1.0
    var radius := 14.0 * body_size
    _draw_attack_telegraph(radius)

    if sprite.texture == null and not use_animated_sprite:
        draw_circle(Vector2.ZERO, radius, c)
        if SettingsManager.high_contrast:
            draw_arc(Vector2.ZERO, radius + 2.0, 0.0, TAU, 24, Color.BLACK, 2.0)
        draw_circle(Vector2(-radius * 0.32, -radius * 0.2), 2.2, Color("#f5e5b1"))
        draw_circle(Vector2(radius * 0.32, -radius * 0.2), 2.2, Color("#f5e5b1"))
        if temperament == "predator":
            draw_colored_polygon(PackedVector2Array([Vector2(-radius*0.65,-radius*0.6), Vector2(-radius*0.25,-radius*1.25), Vector2(-radius*0.08,-radius*0.55)]), c)
            draw_colored_polygon(PackedVector2Array([Vector2(radius*0.65,-radius*0.6), Vector2(radius*0.25,-radius*1.25), Vector2(radius*0.08,-radius*0.55)]), c)
    if befriended:
        draw_string(ThemeDB.fallback_font, Vector2(-8, -radius - 12), "♥", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#fff0ad"))
    elif is_instance_valid(player) and global_position.distance_to(player.global_position) < 76.0 and temperament != "predator":
        draw_string(ThemeDB.fallback_font, Vector2(-32, -radius - 12), "E amizade", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#fff0ad"))
    if is_alpha:
        draw_string(ThemeDB.fallback_font, Vector2(-35, -radius - 27), "ALPHA", HORIZONTAL_ALIGNMENT_CENTER, 70.0, 13, Color("#ffd45b"))
    if max_plating > 0.0 and plating > 0.0:
        draw_arc(Vector2.ZERO, radius + 5.0, 0.0, TAU * clampf(plating / max_plating, 0.0, 1.0), 28, Color("#a8c4d4"), 3.0)
    _draw_health_bar(radius)
