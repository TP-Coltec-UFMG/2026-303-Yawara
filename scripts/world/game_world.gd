extends Node2D

const ENEMY_SCENE := preload("res://scenes/enemies/enemy.tscn")
const MINIBOSS_SCENE := preload("res://scenes/enemies/miniboss.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const YAWARA_SCENE := preload("res://scenes/boss/yawara.tscn")
const XP_ORB_SCENE := preload("res://scenes/effects/xp_orb.tscn")
const FRUIT_SCENE := preload("res://scenes/world/fruit_pickup.tscn")
const PROJECTILE_SCENE := preload("res://scenes/effects/projectile.tscn")
const MELEE_EFFECT_SCENE := preload("res://scenes/effects/melee_effect.tscn")
const HAZARD_ZONE_SCENE := preload("res://scenes/effects/hazard_zone.tscn")

@onready var procedural_world: ProceduralWorld = $ProceduralWorld
@onready var entities: Node2D = $Entities
@onready var effects: Node2D = $Effects
@onready var hud: GameHUD = $HUD
@onready var upgrade_menu: UpgradeMenu = $UpgradeMenu
@onready var build_screen: BuildScreen = $BuildScreen
@onready var encounter_screen: EncounterScreen = $EncounterScreen
@onready var end_screen: EndScreen = $EndScreen

var player: Player
var boss: Yawara
var prep_left := GameSession.PREPARATION_SECONDS
var boss_left := GameSession.BOSS_SECONDS
var spawn_timer := 0.35
var cleanup_timer := 2.0
var environment_timer := 0.0
var current_region := 0
var boss_started := false
var ended := false
var visited_regions: Dictionary = {}
var defeated_minibosses: Dictionary = {}
var current_encounter: EncounterPoint
var first_miniboss_triggered := false
var second_miniboss_triggered := false
var final_boss_triggered := false
var pending_miniboss_events := 0
var endless_next_event := GameSession.FINAL_BOSS_SECONDS + GameSession.ENDLESS_BOSS_INTERVAL

const DAY_CYCLE_SECONDS := 120.0

func _ready() -> void:
    add_to_group("game_world")
    randomize()
    GameSession.reset_run()
    _spawn_player()
    current_region = procedural_world.get_biome_at(player.global_position)
    _set_region(current_region, true)
    upgrade_menu.upgrade_selected.connect(_on_upgrade_selected)
    upgrade_menu.reroll_requested.connect(_on_reroll_requested)
    upgrade_menu.rarity_upgrade_requested.connect(_on_rarity_upgrade_requested)
    encounter_screen.choice_selected.connect(_on_encounter_choice)
    player.weapon_changed.connect(hud.set_weapon)
    player.food_changed.connect(hud.set_food)
    player.mutagen_changed.connect(hud.set_mutagen)
    hud.set_weapon(WeaponDB.get_weapon_name(player.current_weapon))
    hud.set_food(player.food_meter, 100.0)
    hud.set_mutagen(player.mutagen)
    AudioManager.play_music("music_regions.ogg")
    var data: Dictionary = BiomeDB.get_biome(current_region)
    hud.show_banner("%s — %s\nMundo infinito. Comida automática • E: interagir • C/Tab: build • Q/R: armas" % [String(data["name"]).to_upper(), String(data["biome"]).to_upper()], 4.0)
    _spawn_initial_ecosystem()

func _process(delta: float) -> void:
    if ended:
        return
    if not boss_started:
        _update_preparation(delta)
    else:
        _update_boss(delta)
    _debug_shortcuts()

func _spawn_player() -> void:
    player = PLAYER_SCENE.instantiate() as Player
    player.global_position = Vector2(480.0, 480.0)
    entities.add_child(player)
    procedural_world.set_player(player)
    player.health_changed.connect(hud.set_health)
    player.xp_changed.connect(hud.set_xp)
    player.level_up_requested.connect(_on_level_up_requested)
    player.player_died.connect(_on_player_died)
    hud.set_health(player.health.current_health, player.health.max_health)
    hud.set_xp(player.xp, player.xp_needed, player.level)

func _update_preparation(delta: float) -> void:
    GameSession.elapsed += delta
    prep_left = maxf(0.0, GameSession.FINAL_BOSS_SECONDS - GameSession.elapsed)
    hud.set_run_time(GameSession.elapsed, _next_event_text())
    _update_boss_schedule()

    environment_timer -= delta
    if environment_timer <= 0.0:
        environment_timer = 0.20
        _update_player_environment()

    var progress := minf(1.0, GameSession.elapsed / GameSession.PREPARATION_SECONDS)
    var max_creatures := int((20 + int(progress * 12.0)) * GameSession.pressure_multiplier("spawn"))
    spawn_timer -= delta
    if spawn_timer <= 0.0 and get_tree().get_nodes_in_group("creatures").size() < max_creatures:
        _spawn_creature()
        spawn_timer = lerpf(1.10, 0.60, progress) * randf_range(0.76, 1.32)

    _try_spawn_scheduled_miniboss()

    cleanup_timer -= delta
    if cleanup_timer <= 0.0:
        cleanup_timer = 2.0
        _cleanup_distant_entities()

    if GameSession.elapsed >= GameSession.FINAL_BOSS_SECONDS and not final_boss_triggered:
        final_boss_triggered = true
        _start_boss()
    elif GameSession.is_endless() and final_boss_triggered and not boss_started and GameSession.elapsed >= endless_next_event:
        endless_next_event += GameSession.ENDLESS_BOSS_INTERVAL
        pending_miniboss_events += 1

func _update_boss(delta: float) -> void:
    GameSession.elapsed += delta
    boss_left = maxf(0.0, boss_left - delta)
    hud.set_elapsed_time(GameSession.elapsed)
    hud.set_boss_time(boss_left)
    _update_player_environment()
    if boss_left <= 0.0 and not GameSession.is_endless():
        _finish(false)
    elif boss_left <= 0.0 and GameSession.is_endless():
        boss_left = GameSession.BOSS_SECONDS

func _update_player_environment() -> void:
    if not is_instance_valid(player):
        return
    var env: Dictionary = procedural_world.get_environment_at(player.global_position)
    var detected_region := int(env["biome"])
    if detected_region != current_region:
        _set_region(detected_region, false)
    var is_day := _is_daytime()
    var climate_active := _is_climate_active(detected_region)
    player.set_environment_state(detected_region, bool(env["water"]), is_day, climate_active)
    var terrain_text := "Água/Lama" if bool(env["water"]) else "Terra firme"
    var cycle_text := "Dia" if is_day else "Noite"
    var climate_text := ""
    if climate_active:
        climate_text = ["Chuva forte", "Onda de calor", "Cheia", "Nevasca"][detected_region]
    var full_text := "%s • %s" % [cycle_text, terrain_text]
    if not climate_text.is_empty(): full_text += " • " + climate_text
    hud.set_environment(full_text, player.heat_damage_per_second > 0.0, player.cold_damage_per_second > 0.0)

func _is_daytime() -> bool:
    return fmod(GameSession.elapsed, DAY_CYCLE_SECONDS) < DAY_CYCLE_SECONDS * 0.5

func _is_climate_active(biome: int) -> bool:
    return fmod(GameSession.elapsed + float(biome) * 11.0, 52.0) < 18.0

func _spawn_initial_ecosystem() -> void:
    for _i in range(14):
        _spawn_creature(randf_range(260.0, 760.0))

func _spawn_creature(forced_max_distance: float = -1.0) -> Enemy:
    if not is_instance_valid(player):
        return null
    var max_distance := forced_max_distance if forced_max_distance > 0.0 else randf_range(650.0, 940.0)
    var min_distance := 220.0 if forced_max_distance > 0.0 else 520.0
    var spawn_position := procedural_world.random_land_position_near(player.global_position, min_distance, max_distance)
    var biome := procedural_world.get_biome_at(spawn_position)
    var local_rng := RandomNumberGenerator.new()
    local_rng.seed = int(Time.get_ticks_usec()) ^ randi()
    var species := BiomeDB.random_creature(biome, local_rng)
    if species.is_empty():
        return null
    if String(species.get("mechanic", "")) == "water_ranged":
        spawn_position = procedural_world.random_water_position_near(player.global_position, min_distance, max_distance, biome)
    var creature := ENEMY_SCENE.instantiate() as Enemy
    creature.global_position = spawn_position
    entities.add_child(creature)
    var progress := GameSession.elapsed / GameSession.PREPARATION_SECONDS
    creature.configure_creature(species, biome, 0.95 + progress * 1.65)
    return creature

func _update_boss_schedule() -> void:
    if not first_miniboss_triggered and GameSession.elapsed >= GameSession.FIRST_MINIBOSS_SECONDS:
        first_miniboss_triggered = true
        pending_miniboss_events += 1
    if not second_miniboss_triggered and GameSession.elapsed >= GameSession.SECOND_MINIBOSS_SECONDS:
        second_miniboss_triggered = true
        pending_miniboss_events += 1

func _try_spawn_scheduled_miniboss() -> void:
    if boss_started or pending_miniboss_events <= 0: return
    if not get_tree().get_nodes_in_group("minibosses").is_empty(): return
    pending_miniboss_events -= 1
    _spawn_miniboss(current_region)

func _spawn_miniboss(biome: int) -> void:
    var boss_id := BiomeDB.choose_miniboss_for_biome(biome, defeated_minibosses)
    var spawn_position := procedural_world.random_land_position_near(player.global_position, 430.0, 620.0)
    for _attempt in range(18):
        var candidate := procedural_world.random_land_position_near(player.global_position, 430.0, 720.0)
        if procedural_world.get_biome_at(candidate) == biome:
            spawn_position = candidate
            break
    var miniboss := MINIBOSS_SCENE.instantiate() as BiomeMiniboss
    miniboss.global_position = spawn_position
    entities.add_child(miniboss)
    var progress := minf(1.8, GameSession.elapsed / GameSession.PREPARATION_SECONDS)
    miniboss.configure(biome, (0.95 + progress * 1.45) * GameSession.pressure_multiplier("enemy_hp"), boss_id)
    var data: Dictionary = BiomeDB.get_miniboss(boss_id)
    hud.show_banner("GUARDIAO DO BIOMA — %s\nRecompensa: %s" % [String(data["name"]), String(data["power"])], 3.0)

func on_miniboss_defeated(biome_index: int, boss_id: String, boss_name: String, power_name: String, defeat_position: Vector2) -> void:
    var first_defeat := not defeated_minibosses.has(boss_id)
    defeated_minibosses[boss_id] = true
    if first_defeat:
        player.apply_miniboss_power(boss_id)
    player.add_mutagen(10 + int(GameSession.elapsed / 180.0) * 2)
    var skip_first_fruit := GameSession.selected_genetic == "precocious" and defeated_minibosses.size() == 1
    if not player.independent_rule and not skip_first_fruit:
        spawn_fruit(defeat_position, "fruto ancestral", biome_index, 4)
    if defeated_minibosses.size() >= 2:
        player.activate_underdog()
    var desc := String(BiomeDB.get_miniboss(boss_id)["power_desc"])
    var reward_text := "Voce recebeu %s e um Fruto Ancestral" % power_name if first_defeat else "Guardiao ascendido: Mutagen e carne rara"
    if player.independent_rule or skip_first_fruit:
        reward_text = "Voce recebeu %s; esta Genetic impede o fruto" % power_name
    hud.show_banner("%s FOI PURIFICADO\n%s\n%s" % [boss_name, reward_text, desc], 4.0)

func _cleanup_distant_entities() -> void:
    if not is_instance_valid(player):
        return
    for node in get_tree().get_nodes_in_group("enemies"):
        if is_instance_valid(node) and node.global_position.distance_to(player.global_position) > 1650.0:
            node.queue_free()
    for orb in get_tree().get_nodes_in_group("xp_orb"):
        if is_instance_valid(orb) and orb.global_position.distance_to(player.global_position) > 1450.0:
            orb.queue_free()
    for food in get_tree().get_nodes_in_group("food"):
        if is_instance_valid(food) and food.global_position.distance_to(player.global_position) > 1450.0:
            food.queue_free()

func _set_region(index: int, first: bool) -> void:
    current_region = clampi(index, 0, BiomeDB.BIOMES.size() - 1)
    GameSession.current_region = current_region
    var data: Dictionary = BiomeDB.get_biome(current_region)
    hud.set_region(String(data["name"]), String(data["biome"]))

    var first_visit := not visited_regions.has(current_region)
    if first_visit:
        visited_regions[current_region] = true
        if is_instance_valid(player):
            player.apply_regional_blessing(current_region)

    if not first and is_instance_valid(player):
        var blessing_note := "Primeira visita: afinidade + bênção regional" if first_visit else "Bioma conhecido"
        hud.show_banner("%s — %s\n%s" % [String(data["name"]).to_upper(), String(data["biome"]).to_upper(), blessing_note], 2.4)

func open_encounter(point: EncounterPoint) -> void:
    if ended or boss_started or not is_instance_valid(point) or point.used:
        return
    current_encounter = point
    var data: Dictionary = BiomeDB.get_biome(point.biome_index)
    var options: Array = []
    var description := ""
    if BiomeDB.POIS.has(point.encounter_type):
        var poi: Dictionary = BiomeDB.POIS[point.encounter_type]
        description = "%s\n%s" % [String(poi["name"]), String(poi["effect"])]
        options = [
            {"id":"poi_power", "text":"Absorver a forca do lugar", "enabled":true, "tooltip":"Bonus mecanico ligado a este POI."},
            {"id":"poi_social", "text":"Preservar e estudar", "enabled":true, "tooltip":"Social, Progress e afinidade sem destruir o local."}
        ]
        encounter_screen.open_screen("%s — %s" % [point.encounter_name, String(data["name"])], description, options)
        return
    match point.encounter_type:
        "community":
            description = "Pessoas e viajantes descansam neste ponto. Social alto abre caminhos que não exigem combate."
            options = [
                {"id":"community_talk", "text":"Conversar e pedir orientação  [Social 6]", "enabled":player.social >= 6.0, "tooltip":"Ganha Social, Sentidos, XP pacífico e afinidade."},
                {"id":"community_weapon", "text":"Aprender uma técnica / arma  [Social 12]", "enabled":player.social >= 12.0, "tooltip":"Desbloqueia uma arma que você ainda não possui."},
                {"id":"community_rest", "text":"Descansar na fogueira", "enabled":true, "tooltip":"Recupera PV e melhora um pouco o vínculo social."}
            ]
        "shrine":
            description = "Um lugar antigo concentra histórias e forças do bioma %s." % String(data["biome"])
            options = [
                {"id":"shrine_respect", "text":"Observar e prestar respeito", "enabled":true, "tooltip":"Adaptação, afinidade e XP sem combate."},
                {"id":"shrine_blessing", "text":"Pedir uma bênção intensa  [Social 10]", "enabled":player.social >= 10.0, "tooltip":"Grande bônus, mas aumenta Loucura."},
                {"id":"shrine_story", "text":"Ouvir as histórias do lugar  [Social 7]", "enabled":player.social >= 7.0, "tooltip":"Aumenta Sentidos e afinidade regional."}
            ]
        _:
            description = "Animais e plantas usam esta clareira como refúgio. É possível ganhar poder sem caçar."
            options = [
                {"id":"natural_observe", "text":"Observar sem interferir", "enabled":true, "tooltip":"Social e XP pacífico."},
                {"id":"natural_friend", "text":"Convidar um animal para acompanhar  [Social 14]", "enabled":player.social >= 14.0 and player.can_add_companion(), "tooltip":"Cria um companheiro que ataca predadores e chefes."},
                {"id":"natural_forage", "text":"Forragear frutas", "enabled":true, "tooltip":"Espalha várias frutas do bioma perto do ponto."}
            ]
    encounter_screen.open_screen("%s — %s" % [point.encounter_name, String(data["name"])], description, options)

func _on_encounter_choice(choice_id: String) -> void:
    if not is_instance_valid(current_encounter):
        return
    var point := current_encounter
    var biome := point.biome_index
    point.mark_used()
    if choice_id in ["poi_power", "poi_social"]:
        player.apply_poi(point.encounter_type, biome, choice_id == "poi_social")
        current_encounter = null
        return
    match choice_id:
        "community_talk":
            player.register_peaceful_encounter(biome, 16)
            player.grant_senses(0.08)
            hud.show_banner("A conversa revelou rotas, hábitos dos animais e histórias do bioma.", 2.0)
        "community_weapon":
            player.register_peaceful_encounter(biome, 12)
            var weapon_id := player.unlock_random_weapon()
            if weapon_id.is_empty():
                player.attack_damage *= 1.08
                hud.show_banner("Você já conhece todas as armas. Recebeu +8% de dano.", 2.0)
            else:
                hud.show_banner("Nova arma aprendida: %s" % WeaponDB.get_weapon_name(weapon_id), 2.2)
        "community_rest":
            player.heal_amount(42.0 + player.social * 0.8)
            player.modify_social(0.25)
            player.add_nature_xp(7)
            hud.show_banner("A fogueira trouxe descanso e confiança.", 1.8)
        "shrine_respect":
            player.grant_adaptation(0.08, 0.06, 0.06)
            player.register_peaceful_encounter(biome, 14)
            hud.show_banner("O ambiente parece menos hostil.", 1.8)
        "shrine_blessing":
            player.madness = minf(1.0, player.madness + 0.06)
            player.attack_damage *= 1.10
            player.passive_regeneration += 0.25
            player.modify_social(0.3)
            player.increase_affinity(biome, 4)
            hud.show_banner("A bênção é poderosa, mas algo antigo passou a observar você.", 2.2)
        "shrine_story":
            player.grant_senses(0.16)
            player.modify_social(0.5)
            player.increase_affinity(biome, 5)
            player.add_nature_xp(13)
            hud.show_banner("Você aprendeu a reconhecer sinais escondidos do bioma.", 2.0)
        "natural_observe":
            player.register_peaceful_encounter(biome, 18)
            hud.show_banner("Observar sem ferir também ensina.", 1.8)
        "natural_friend":
            player.register_peaceful_encounter(biome, 12)
            _spawn_friendly_creature(biome)
        "natural_forage":
            player.register_peaceful_encounter(biome, 8)
            var fruit_name := String(BiomeDB.get_biome(biome)["fruit"])
            for i in range(6):
                spawn_fruit(point.global_position + Vector2.from_angle(TAU * float(i) / 6.0) * randf_range(42.0, 85.0), fruit_name, biome, 1)
            hud.show_banner("Você encontrou uma área rica em %s." % fruit_name, 1.8)
    current_encounter = null

func _spawn_friendly_creature(biome: int) -> void:
    var pool: Array = BiomeDB.get_creature_pool(biome)
    var candidates: Array[Dictionary] = []
    for value in pool:
        var species: Dictionary = value
        if String(species["temperament"]) != "predator":
            candidates.append(species)
    if candidates.is_empty():
        return
    candidates.shuffle()
    var creature := ENEMY_SCENE.instantiate() as Enemy
    creature.global_position = player.global_position + Vector2.from_angle(randf_range(0.0, TAU)) * 92.0
    entities.add_child(creature)
    creature.configure_creature(candidates[0], biome, 1.0)
    if creature.force_befriend():
        hud.show_banner("%s passou a acompanhar sua jornada." % creature.creature_name, 2.0)
    else:
        creature.queue_free()

func _clear_boss_arena(center: Vector2, radius: float) -> void:
    # A Yawara pode despertar em qualquer ponto do mundo. Retirar a colisão de
    # vegetação próxima evita que uma geração aleatória torne a luta impossível.
    for node in get_tree().get_nodes_in_group("world_props"):
        if not is_instance_valid(node) or not (node is Node2D):
            continue
        var prop := node as Node2D
        if prop.global_position.distance_to(center) <= radius:
            var collider := prop as CollisionObject2D
            if is_instance_valid(collider):
                collider.collision_layer = 0
            prop.modulate.a = minf(prop.modulate.a, 0.34)

func _apply_social_boss_support() -> void:
    # Encontros pacíficos e Social alto retornam como apoio real no confronto final.
    var encounter_tier := int(floor(float(player.peaceful_encounters) / 2.0))
    var social_tier := int(floor(maxf(0.0, player.social - 10.0) / 8.0))
    var support_tier := clampi(encounter_tier + social_tier, 0, 4)
    if support_tier <= 0:
        return
    player.passive_regeneration += 0.22 * float(support_tier)
    player.damage_reduction = minf(0.70, player.damage_reduction + 0.025 * float(support_tier))
    var companions_to_call := mini(support_tier, 4 - get_tree().get_nodes_in_group("companions").size())
    for _i in range(companions_to_call):
        _spawn_friendly_creature(current_region)
    hud.show_banner("A REDE DE ALIANÇAS RESPONDEU\nApoio social nível %d: proteção, regeneração e aliados." % support_tier, 3.0)

func _start_boss() -> void:
    boss_started = true
    GameSession.in_boss_fight = true
    # Limpa ameaças, mas preserva companheiros e o cenário procedural ao redor.
    for node in get_tree().get_nodes_in_group("enemies"):
        if is_instance_valid(node):
            node.queue_free()
    for orb in get_tree().get_nodes_in_group("xp_orb"):
        if is_instance_valid(orb):
            orb.queue_free()

    _apply_social_boss_support()

    _clear_boss_arena(player.global_position, 520.0)
    boss = YAWARA_SCENE.instantiate() as Yawara
    boss.global_position = procedural_world.random_land_position_near(player.global_position, 360.0, 510.0)
    entities.add_child(boss)
    boss.boss_health_changed.connect(hud.set_boss_health)
    boss.boss_died.connect(_on_boss_died)
    hud.show_boss(boss.health.max_health)
    hud.set_boss_time(boss_left)
    hud.show_banner("UM RUGIDO ANCESTRAL ECOA PELO MUNDO\nYAWARA DESPERTOU", 3.2)
    AudioManager.play_music("music_boss.ogg")

func _on_level_up_requested() -> void:
    if ended:
        return
    get_tree().paused = true
    var first_precocious_branch := GameSession.selected_genetic == "precocious" and player.level == 2
    var independent_branch := player.independent_rule and player.level % 12 == 0
    if first_precocious_branch or independent_branch:
        upgrade_menu.open_branching(player.upgrade_levels, player.level, player.get_evolution_choice_count())
    else:
        upgrade_menu.open(player.upgrade_levels, player.level, player.get_rarity_luck(), player.get_evolution_choice_count(), player.forced_minimum_rarity())

func request_branching_evolution() -> void:
    if ended or not is_instance_valid(player) or upgrade_menu.root.visible:
        return
    get_tree().paused = true
    upgrade_menu.open_branching(player.upgrade_levels, player.level, player.get_evolution_choice_count())

func _on_upgrade_selected(upgrade_id: String, rarity: String) -> void:
    player.apply_upgrade(upgrade_id, rarity)
    get_tree().paused = player.pending_level_up

func _on_reroll_requested() -> void:
    var cost := upgrade_menu.get_reroll_cost()
    if player.spend_mutagen(cost):
        upgrade_menu.reroll()
    else:
        hud.show_banner("Sao necessarios %d Mutagen para novas opcoes." % cost, 1.2)

func _on_rarity_upgrade_requested(option_index: int) -> void:
    var cost := upgrade_menu.get_rarity_upgrade_cost()
    if player.spend_mutagen(cost):
        upgrade_menu.upgrade_rarity(option_index)
    else:
        hud.show_banner("Sao necessarios %d Mutagen para elevar a raridade." % cost, 1.2)

func _on_player_died() -> void:
    _finish(false)

func _on_boss_died() -> void:
    if is_instance_valid(boss):
        for index in range(6):
            var offset := Vector2.from_angle(TAU * float(index) / 6.0) * 52.0
            spawn_fruit(boss.global_position + offset, "carne", current_region, 4 if index == 0 else 3)
    if GameSession.is_endless():
        boss_started = false
        GameSession.in_boss_fight = false
        boss = null
        hud.hide_boss()
        hud.show_banner("YAWARA FOI PURIFICADO\nENDLESS CONTINUA: o ecossistema nao para de evoluir.", 4.0)
        AudioManager.play_music("music_regions.ogg")
    else:
        _finish(true)

func _next_event_text() -> String:
    if not first_miniboss_triggered: return "Guardiao do bioma em 03:00"
    if not second_miniboss_triggered: return "Proximo guardiao em 06:00"
    if not final_boss_triggered: return "Yawara desperta em 08:00"
    if GameSession.is_endless(): return "ENDLESS • proxima escalada em %s" % hud._format_time(maxf(0.0, endless_next_event - GameSession.elapsed))
    return "Enfrente Yawara"

func _finish(victory: bool) -> void:
    if ended:
        return
    ended = true
    GameSession.run_finished = true
    if is_instance_valid(build_screen) and build_screen.opened:
        build_screen.close()
    if is_instance_valid(encounter_screen) and encounter_screen.opened:
        encounter_screen.close()
    get_tree().paused = true
    end_screen.show_result(victory, player.level if is_instance_valid(player) else 1)

func spawn_xp_orb(pos: Vector2, amount: int) -> void:
    call_deferred("_deferred_spawn_xp_orb", pos, amount)

func _deferred_spawn_xp_orb(pos: Vector2, amount: int) -> void:
    var orb := XP_ORB_SCENE.instantiate() as XPOrb
    orb.global_position = pos
    orb.configure(amount)
    effects.add_child(orb)

func spawn_fruit(pos: Vector2, fruit_name: String, biome_index: int, value: int = 1) -> void:
    call_deferred("_deferred_spawn_fruit", pos, fruit_name, biome_index, value)

func _deferred_spawn_fruit(pos: Vector2, fruit_name: String, biome_index: int, value: int = 1) -> void:
    var fruit := FRUIT_SCENE.instantiate() as FruitPickup
    fruit.global_position = pos
    effects.add_child(fruit)
    fruit.configure(fruit_name, biome_index, value)

func spawn_melee_effect(pos: Vector2, direction: Vector2, radius: float) -> void:
    var effect := MELEE_EFFECT_SCENE.instantiate()
    effect.global_position = pos
    effect.rotation = direction.angle()
    effect.configure(radius)
    effects.add_child(effect)

func spawn_player_projectile(pos: Vector2, direction: Vector2, damage: float, effect_id: String = "", max_hits: int = 1) -> void:
    var projectile := PROJECTILE_SCENE.instantiate() as GameProjectile
    projectile.global_position = pos
    effects.add_child(projectile)
    var speed := 760.0 if effect_id != "slow" else 590.0
    var radius := 6.0 if effect_id != "slow" else 9.0
    projectile.configure(direction, speed, damage, false, radius, effect_id, max_hits)

func spawn_boss_projectile(pos: Vector2, direction: Vector2, speed: float, damage: float, size: float, effect_id: String = "") -> void:
    var projectile := PROJECTILE_SCENE.instantiate() as GameProjectile
    projectile.global_position = pos
    effects.add_child(projectile)
    projectile.configure(direction, speed, damage, true, size, effect_id)

func spawn_hazard_zone(pos: Vector2, radius: float, windup: float, damage: float, effect_id: String = "meteor", duration: float = 0.18) -> void:
    var hazard := HAZARD_ZONE_SCENE.instantiate() as HazardZone
    hazard.global_position = pos
    effects.add_child(hazard)
    hazard.configure(radius, windup, damage, effect_id, duration)

func spawn_boss_add(pos: Vector2, add_id: String = "curumim_corrompido") -> void:
    var data: Dictionary = BiomeDB.BOSS_ADDS.get(add_id, BiomeDB.BOSS_ADDS["curumim_corrompido"])
    var species := {
        "id":add_id, "name":data["name"], "temperament":"predator", "diet":"carnivore",
        "size":0.58 if add_id == "curumim_corrompido" else 0.82,
        "speed":data["speed"], "hp":data["hp"], "damage":data["damage"],
        "xp":3, "friend":99.0, "mechanic":"rush_combo" if add_id == "curumim_corrompido" else "tongue_stun", "evolutions":[]
    }
    var add := ENEMY_SCENE.instantiate() as Enemy
    add.global_position = pos
    entities.add_child(add)
    add.configure_creature(species, current_region, 1.25 + GameSession.elapsed / 480.0)

func show_banner(text: String, duration: float = 2.0) -> void:
    hud.show_banner(text, duration)

func _debug_shortcuts() -> void:
    if not OS.is_debug_build():
        return
    if Input.is_key_pressed(KEY_F2) and not boss_started:
        GameSession.elapsed = GameSession.FINAL_BOSS_SECONDS - 2.0
    if Input.is_key_pressed(KEY_F3) and is_instance_valid(player):
        player.add_xp(5)
    if Input.is_key_pressed(KEY_F4) and is_instance_valid(boss):
        boss.take_damage(80.0)
    if Input.is_key_pressed(KEY_F5) and not boss_started and get_tree().get_nodes_in_group("minibosses").is_empty():
        _spawn_miniboss(current_region)
