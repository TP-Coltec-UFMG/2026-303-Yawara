class_name Yawara
extends CharacterBody2D

signal boss_health_changed(current: float, maximum: float)
signal boss_died

@onready var health: HealthComponent = $HealthComponent
@onready var sprite: Sprite2D = $Sprite2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var animation_attack_time := 0.0

var player: Player
var phase := 1
var move_speed := 92.0
var contact_damage := 14.0
var contact_timer := 0.0
# Distância de combate: a chefe circula o jogador, em vez de tentar ocupá-lo.
const PREFERRED_DISTANCE := 192.0
const MIN_DISTANCE := 148.0
const MAX_DISTANCE := 246.0
var orbit_direction := 1.0
var orbit_timer := 4.5
var dash_windup := 0.0
var dash_recovery := 0.0
var visual_hit_flash := 0.0
var special_timer := 3.2
var dash_timer := 2.8
var dash_left := 0.0
var dash_direction := Vector2.ZERO
var flash_time := 0.0
var meteor_timer := 6.8
var breath_timer := 8.0
var add_timer := 12.0
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
    orbit_direction = -1.0 if randf() < 0.5 else 1.0
    AudioManager.play_sfx("boss_roar.wav")
    queue_redraw()

func _try_load_sprite() -> void:
    # Arte nova de 3 fases; a forma vetorial antiga fica oculta.
    sprite.hide()
    if has_node("Visual"):
        $Visual.hide()
    animated_sprite.show()
    animated_sprite.play("phase_1_idle")

func _update_boss_visual(delta: float) -> void:
    animation_attack_time = maxf(0.0, animation_attack_time - delta)
    visual_hit_flash = maxf(0.0, visual_hit_flash - delta)
    var motion := "attack" if animation_attack_time > 0.0 else ("walk" if velocity.length() > 12.0 else "idle")
    var desired := "phase_%d_%s" % [phase, motion]
    if animated_sprite.sprite_frames.has_animation(desired):
        if animated_sprite.animation != desired:
            animated_sprite.play(desired)
        elif not animated_sprite.is_playing() and motion == "attack":
            animation_attack_time = 0.0
    animated_sprite.flip_h = velocity.x < -6.0
    animated_sprite.modulate = Color(1.12, 1.02, 0.80) if dash_windup > 0.0 else Color.WHITE
    if visual_hit_flash > 0.0 and not SettingsManager.reduce_flashes:
        animated_sprite.modulate = Color(1.20, 1.05, 1.05)

func _physics_process(delta: float) -> void:
    if not is_instance_valid(player) or health.current_health <= 0.0:
        return
    contact_timer = maxf(0.0, contact_timer - delta)
    special_timer -= delta
    dash_timer -= delta
    flash_time = maxf(0.0, flash_time - delta)
    meteor_timer -= delta
    breath_timer -= delta
    add_timer -= delta
    stun_time = maxf(0.0, stun_time - delta)
    orbit_timer -= delta
    if orbit_timer <= 0.0:
        orbit_timer = randf_range(3.2, 5.4)
        orbit_direction *= -1.0

    _update_phase()
    var offset: Vector2 = player.global_position - global_position
    var distance := offset.length()
    var toward: Vector2 = offset / maxf(distance, 0.001)
    var tangent := Vector2(-toward.y, toward.x) * orbit_direction

    if stun_time > 0.0:
        velocity = Vector2.ZERO
    elif dash_windup > 0.0:
        # A direção é travada durante a preparação para dar tempo de desviar.
        dash_windup = maxf(0.0, dash_windup - delta)
        velocity = Vector2.ZERO
        if dash_windup <= 0.0:
            dash_left = 0.17
            animation_attack_time = 0.40
    elif dash_left > 0.0:
        dash_left = maxf(0.0, dash_left - delta)
        # Interrompe a investida antes de colar no Aruan.
        if distance < 120.0:
            dash_left = 0.0
            velocity = -toward * 130.0
        else:
            velocity = dash_direction * (335.0 + float(phase) * 28.0)
        if dash_left <= 0.0:
            dash_recovery = 0.35
    elif dash_recovery > 0.0:
        dash_recovery = maxf(0.0, dash_recovery - delta)
        velocity = -toward * move_speed * 0.5 if distance < PREFERRED_DISTANCE else Vector2.ZERO
    else:
        # Aproxima de longe, circula a meia distância e recua quando muito perto.
        if distance > MAX_DISTANCE:
            velocity = (toward * 0.88 + tangent * 0.25).normalized() * move_speed
        elif distance < MIN_DISTANCE:
            velocity = (-toward * 1.25 + tangent * 0.28).normalized() * move_speed
        else:
            var adjust: float = clampf((distance - PREFERRED_DISTANCE) / 90.0, -0.42, 0.42)
            velocity = (tangent * 0.78 + toward * adjust).normalized() * move_speed * 0.80
        if dash_timer <= 0.0 and distance > 180.0 and distance < 420.0:
            dash_timer = 4.2 if phase == 1 else (3.5 if phase == 2 else 3.0)
            dash_direction = toward
            dash_windup = 0.46
            velocity = Vector2.ZERO

    move_and_slide()
    # Dano de contato com cooldown, sem depender de colisões contínuas.
    if global_position.distance_to(player.global_position) < 78.0 and contact_timer <= 0.0:
        contact_timer = 1.45
        player.take_damage(contact_damage + float(phase - 1) * 2.0)

    if special_timer <= 0.0:
        _special_attack()
    if meteor_timer <= 0.0:
        meteor_timer = 6.8 if phase == 1 else (6.0 if phase == 2 else 5.2)
        _meteor_rain(2 if phase == 1 else (3 if phase == 2 else 4))
    if phase >= 2 and breath_timer <= 0.0:
        breath_timer = 9.0 if phase == 2 else 7.0
        _poison_breath()
    if phase >= 2 and add_timer <= 0.0:
        add_timer = 14.0 if phase == 2 else 11.0
        _summon_adds(1 if phase == 2 else 2)

    _update_boss_visual(delta)

func _update_phase() -> void:
    var ratio := health.ratio()
    var new_phase := 1
    if ratio <= 0.66:
        new_phase = 2
    if ratio <= 0.33:
        new_phase = 3
    if new_phase != phase:
        phase = new_phase
        move_speed = 92.0 + float(phase - 1) * 15.0
        dash_left = 0.0
        dash_windup = 0.0
        dash_recovery = 0.55
        AudioManager.play_sfx("boss_roar.wav")
        get_tree().call_group("game_world", "show_banner", "YAWARA — FASE %d" % phase, 2.0)

func _special_attack() -> void:
    animation_attack_time = 0.31
    if phase == 1:
        special_timer = 4.2
        _radial_wave(6, 255.0, 11.0, 7.0)
    elif phase == 2:
        special_timer = 3.5
        _radial_wave(8, 285.0, 13.0, 7.0)
        _aimed_burst(2, 345.0, 13.0)
    else:
        special_timer = 2.9
        _radial_wave(10, 325.0, 15.0, 8.0)
        _aimed_burst(3, 380.0, 15.0)

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
    # Um ponto de perigo perto do jogador e outros ao redor: nunca uma parede de alvos.
    var target_center := player.global_position
    for i in range(count):
        var offset := Vector2.ZERO
        if i > 0:
            offset = Vector2.from_angle(TAU * float(i - 1) / maxf(float(count - 1), 1.0) + float(phase) * 0.6) * randf_range(125.0, 215.0)
        var target := target_center + offset
        get_tree().call_group("game_world", "spawn_hazard_zone", target, 36.0 + float(phase) * 3.0, 1.25 + float(i) * 0.13, 13.0 + float(phase) * 2.0, "meteor", 0.18)

func _poison_breath() -> void:
    var direction := global_position.direction_to(player.global_position)
    for i in range(3):
        var target := global_position + direction * (120.0 + float(i) * 84.0)
        get_tree().call_group("game_world", "spawn_hazard_zone", target, 37.0, 1.0 + float(i) * 0.12, 5.0 + float(phase), "poison", 1.2)

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
    visual_hit_flash = flash_time

func _on_health_changed(current: float, maximum: float) -> void:
    boss_health_changed.emit(current, maximum)

func _on_died() -> void:
    boss_died.emit()
    queue_free()

func _draw() -> void:
    if animated_sprite.visible or sprite.texture != null:
        if has_node("Visual"):
            $Visual.hide()
        return
    var c := Color("#caa24a")
    if phase == 2:
        c = Color("#b9743d")
    elif phase == 3:
        c = Color("#a34646")
    if flash_time > 0.0 and not SettingsManager.reduce_flashes:
        c = Color.WHITE
    if has_node("Visual"):
        $Visual/Body.color = c
        $Visual/LeftEar.color = c
        $Visual/RightEar.color = c
        return
    draw_circle(Vector2.ZERO, 43.0, c)
    draw_circle(Vector2(-25, -31), 15.0, c)
    draw_circle(Vector2(25, -31), 15.0, c)
    draw_circle(Vector2(-14, -7), 4.0, Color("#f8e5a4"))
    draw_circle(Vector2(14, -7), 4.0, Color("#f8e5a4"))
    draw_line(Vector2(-32, 8), Vector2(-52, 4), Color("#33251e"), 4.0)
    draw_line(Vector2(32, 8), Vector2(52, 4), Color("#33251e"), 4.0)
    draw_arc(Vector2.ZERO, 50.0, 0.0, TAU, 48, Color("#4c2428"), 5.0)
