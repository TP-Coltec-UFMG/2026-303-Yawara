class_name Yawara
extends CharacterBody2D

signal boss_health_changed(current: float, maximum: float)
signal boss_died

@onready var health: HealthComponent = $HealthComponent
@onready var sprite: Sprite2D = $Sprite2D

var player: Player
var phase := 1
var move_speed := 105.0
var contact_damage := 18.0
var contact_timer := 0.0
var special_timer := 2.2
var dash_timer := 2.8
var dash_left := 0.0
var dash_direction := Vector2.ZERO
var flash_time := 0.0
var meteor_timer := 4.5
var breath_timer := 6.5
var add_timer := 8.0
var stun_time := 0.0
var stun_resistance := 0.0

func _ready() -> void:
    add_to_group("enemies")
    add_to_group("boss")
    player = get_tree().get_first_node_in_group("player") as Player
    var endless_scale := 1.0 + maxf(0.0, GameSession.elapsed - GameSession.FINAL_BOSS_SECONDS) / 720.0
    health.setup(3200.0 * GameSession.pressure_multiplier("enemy_hp") * endless_scale)
    health.health_changed.connect(_on_health_changed)
    health.died.connect(_on_died)
    _try_load_sprite()
    AudioManager.play_sfx("boss_roar.wav")
    queue_redraw()

func _try_load_sprite() -> void:
    var path := "res://assets/sprites/boss/yawara.png"
    if ResourceLoader.exists(path):
        sprite.texture = load(path)
        var max_side := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
        sprite.scale = Vector2.ONE * (126.0 / maxf(1.0, max_side))

func _physics_process(delta: float) -> void:
    if not is_instance_valid(player):
        return
    contact_timer = maxf(0.0, contact_timer - delta)
    special_timer -= delta
    dash_timer -= delta
    flash_time = maxf(0.0, flash_time - delta)
    meteor_timer -= delta
    breath_timer -= delta
    add_timer -= delta
    stun_time = maxf(0.0, stun_time - delta)
    _update_phase()

    if stun_time > 0.0:
        velocity = Vector2.ZERO
        move_and_slide()
        queue_redraw()
        return

    if dash_left > 0.0:
        dash_left -= delta
        velocity = dash_direction * (520.0 + phase * 55.0)
    else:
        velocity = global_position.direction_to(player.global_position) * move_speed
        if dash_timer <= 0.0:
            dash_timer = 3.0 if phase == 1 else (2.2 if phase == 2 else 1.45)
            dash_direction = global_position.direction_to(player.global_position)
            dash_left = 0.24

    move_and_slide()

    if global_position.distance_to(player.global_position) < 58.0 and contact_timer <= 0.0:
        contact_timer = 0.72
        player.take_damage(contact_damage + float(phase - 1) * 3.0)

    if special_timer <= 0.0:
        _special_attack()
    if meteor_timer <= 0.0:
        meteor_timer = 5.5 if phase == 1 else (3.8 if phase == 2 else 1.35)
        _meteor_rain(3 if phase == 1 else (5 if phase == 2 else 7))
    if phase >= 2 and breath_timer <= 0.0:
        breath_timer = 7.0 if phase == 2 else 4.8
        _poison_breath()
    if phase >= 2 and add_timer <= 0.0:
        add_timer = 10.0 if phase == 2 else 7.0
        _summon_adds(2 if phase == 2 else 3)

    queue_redraw()

func _update_phase() -> void:
    var ratio := health.ratio()
    var new_phase := 1
    if ratio <= 0.66:
        new_phase = 2
    if ratio <= 0.33:
        new_phase = 3
    if new_phase != phase:
        phase = new_phase
        move_speed = 105.0 + float(phase - 1) * 28.0
        AudioManager.play_sfx("boss_roar.wav")
        get_tree().call_group("game_world", "show_banner", "YAWARA — FASE %d" % phase, 2.0)

func _special_attack() -> void:
    if phase == 1:
        special_timer = 3.1
        _radial_wave(8, 285.0, 13.0, 8.0)
    elif phase == 2:
        special_timer = 2.35
        _radial_wave(12, 330.0, 15.0, 8.0)
        _aimed_burst(2, 430.0, 16.0)
    else:
        special_timer = 1.65
        _radial_wave(16, 380.0, 17.0, 9.0)
        _aimed_burst(3, 510.0, 18.0)

func _radial_wave(count: int, projectile_speed: float, projectile_damage: float, size: float) -> void:
    for i in range(count):
        var angle := TAU * float(i) / float(count) + Time.get_ticks_msec() * 0.0003
        var dir := Vector2.from_angle(angle)
        get_tree().call_group("game_world", "spawn_boss_projectile", global_position + dir * 34.0, dir, projectile_speed, projectile_damage, size)

func _aimed_burst(count: int, projectile_speed: float, projectile_damage: float) -> void:
    var base := global_position.direction_to(player.global_position).angle()
    for i in range(count):
        var offset := (float(i) - float(count - 1) / 2.0) * 0.18
        var dir := Vector2.from_angle(base + offset)
        get_tree().call_group("game_world", "spawn_boss_projectile", global_position + dir * 34.0, dir, projectile_speed, projectile_damage, 7.0)

func _meteor_rain(count: int) -> void:
    for i in range(count):
        var offset := Vector2.from_angle(randf_range(0.0, TAU)) * randf_range(30.0, 260.0)
        var target := player.global_position + offset
        get_tree().call_group("game_world", "spawn_hazard_zone", target, 48.0 + phase * 5.0, 0.95 + float(i) * 0.08, 16.0 + phase * 3.0, "meteor", 0.22)

func _poison_breath() -> void:
    var direction := global_position.direction_to(player.global_position)
    for i in range(1, 6):
        var target := global_position + direction * (70.0 + float(i) * 58.0)
        get_tree().call_group("game_world", "spawn_hazard_zone", target, 54.0, 0.72 + float(i) * 0.06, 7.0 + phase * 2.0, "poison", 2.4)

func _summon_adds(count: int) -> void:
    for i in range(count):
        var add_id := "raiz_yawara" if phase == 3 and i == 0 else "curumim_corrompido"
        var pos := global_position + Vector2.from_angle(TAU * float(i) / float(count)) * 95.0
        get_tree().call_group("game_world", "spawn_boss_add", pos, add_id)

func apply_stun(duration: float) -> void:
    var effective := duration * maxf(0.15, 1.0 - stun_resistance)
    stun_time = maxf(stun_time, effective)
    stun_resistance = minf(0.88, stun_resistance + 0.18)

func take_damage(amount: float) -> void:
    health.damage(amount)
    flash_time = 0.0 if SettingsManager.reduce_flashes else 0.08

func _on_health_changed(current: float, maximum: float) -> void:
    boss_health_changed.emit(current, maximum)

func _on_died() -> void:
    boss_died.emit()
    queue_free()

func _draw() -> void:
    if sprite.texture != null:
        return
    var c := Color("#caa24a")
    if phase == 2:
        c = Color("#b9743d")
    elif phase == 3:
        c = Color("#a34646")
    if flash_time > 0.0 and not SettingsManager.reduce_flashes:
        c = Color.WHITE
    draw_circle(Vector2.ZERO, 43.0, c)
    draw_circle(Vector2(-25, -31), 15.0, c)
    draw_circle(Vector2(25, -31), 15.0, c)
    draw_circle(Vector2(-14, -7), 4.0, Color("#f8e5a4"))
    draw_circle(Vector2(14, -7), 4.0, Color("#f8e5a4"))
    draw_line(Vector2(-32, 8), Vector2(-52, 4), Color("#33251e"), 4.0)
    draw_line(Vector2(32, 8), Vector2(52, 4), Color("#33251e"), 4.0)
    draw_arc(Vector2.ZERO, 50.0, 0.0, TAU, 48, Color("#4c2428"), 5.0)
