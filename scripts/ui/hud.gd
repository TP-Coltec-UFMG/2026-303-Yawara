class_name GameHUD
extends CanvasLayer

@onready var health_bar: ProgressBar = $Root/Top/Row/HealthBar
@onready var xp_bar: ProgressBar = $Root/Top/Row/XPBar
@onready var level_label: Label = $Root/Top/Row/Level
@onready var timer_label: Label = $Root/Top/Row/Timer
@onready var region_label: Label = $Root/Top/Row/Region
@onready var weapon_label: Label = $Root/Weapon
@onready var environment_label: Label = $Root/Environment
@onready var food_bar: ProgressBar = $Root/FoodBar
@onready var objective_label: Label = $Root/Objective
@onready var boss_container: VBoxContainer = $Root/Boss
@onready var boss_bar: ProgressBar = $Root/Boss/BossBar
@onready var boss_timer: Label = $Root/Boss/BossTimer
@onready var banner: Label = $Root/Banner
@onready var mutagen_label: Label = $Root/Mutagen
@onready var root_control: Control = $Root
@onready var top_panel: PanelContainer = $Root/Top

var banner_token := 0
var last_health := 0.0
var last_max_health := 1.0
var last_xp := 0
var last_xp_needed := 1
var last_level := 1
var last_weapon := ""
var last_food := 0.0
var last_food_max := 100.0
var last_prep_time := 0.0
var last_boss_time := 0.0
var boss_mode := false
var base_environment := ""
var env_heat := false
var env_cold := false
var last_mutagen := 0

func _ready() -> void:
    SettingsManager.register_accessibility_ui($Root)
    SettingsManager.language_changed.connect(_on_language_changed)
    get_viewport().size_changed.connect(_update_layout)
    call_deferred("_update_layout")

func _on_language_changed(_locale: String) -> void:
    set_health(last_health, last_max_health)
    set_xp(last_xp, last_xp_needed, last_level)
    if not last_weapon.is_empty(): set_weapon(last_weapon)
    set_food(last_food, last_food_max)
    if not base_environment.is_empty(): set_environment(base_environment, env_heat, env_cold)
    if boss_mode:
        timer_label.text = SettingsManager.t("final_fight")
        objective_label.text = SettingsManager.t("boss_objective")
        set_boss_time(last_boss_time)
    else:
        set_preparation_time(last_prep_time)
    SettingsManager.apply_accessibility($Root)

func set_health(current: float, maximum: float) -> void:
    last_health = current; last_max_health = maximum
    health_bar.max_value = maximum
    health_bar.value = current
    health_bar.tooltip_text = SettingsManager.t("health") % [int(current), int(maximum)]

func set_xp(current: int, needed: int, level: int) -> void:
    last_xp = current; last_xp_needed = needed; last_level = level
    xp_bar.max_value = needed
    xp_bar.value = current
    level_label.text = SettingsManager.t("level") % level

func set_region(region_name: String, biome: String) -> void:
    region_label.text = "%s — %s" % [region_name, biome]

func set_weapon(weapon_name: String) -> void:
    last_weapon = weapon_name
    weapon_label.text = SettingsManager.t("weapon") % weapon_name.to_upper()

func set_food(current: float, maximum: float) -> void:
    last_food = current; last_food_max = maximum
    food_bar.max_value = maximum
    food_bar.value = current
    food_bar.tooltip_text = SettingsManager.t("food_progress") % [int(current), int(maximum)]

func set_mutagen(current: int) -> void:
    last_mutagen = current
    mutagen_label.text = "Mutagen: %d" % current

func set_environment(text: String, heat_danger: bool, cold_danger: bool) -> void:
    base_environment = text; env_heat = heat_danger; env_cold = cold_danger
    environment_label.text = text
    if heat_danger:
        environment_label.text += " • " + SettingsManager.t("heat")
        environment_label.add_theme_color_override("font_color", Color("#ff9a55"))
    elif cold_danger:
        environment_label.text += " • " + SettingsManager.t("cold")
        environment_label.add_theme_color_override("font_color", Color("#87c9f2"))
    else:
        environment_label.add_theme_color_override("font_color", Color("#e8ddb7"))

func set_preparation_time(seconds_left: float) -> void:
    boss_mode = false
    last_prep_time = seconds_left
    timer_label.text = SettingsManager.t("preparation") % _format_time(seconds_left)
    objective_label.text = SettingsManager.t("objective")

func set_run_time(elapsed: float, next_event: String) -> void:
    boss_mode = false
    timer_label.text = "TEMPO  %s" % _format_elapsed(elapsed)
    objective_label.text = next_event

func set_elapsed_time(elapsed: float) -> void:
    timer_label.text = "TEMPO  %s" % _format_elapsed(elapsed)

func show_boss(maximum: float) -> void:
    boss_mode = true
    boss_container.visible = true
    boss_bar.max_value = maximum
    boss_bar.value = maximum
    timer_label.text = "TEMPO  08:00"
    objective_label.text = SettingsManager.t("boss_objective")

func set_boss_health(current: float, maximum: float) -> void:
    boss_bar.max_value = maximum
    boss_bar.value = current

func set_boss_time(seconds_left: float) -> void:
    last_boss_time = seconds_left
    boss_timer.text = SettingsManager.t("time_left") % _format_time(seconds_left)

func hide_boss() -> void:
    boss_mode = false
    boss_container.visible = false

func _update_layout() -> void:
    if not is_node_ready():
        return
    var size := get_viewport().get_visible_rect().size
    top_panel.offset_right = -20.0
    var compact := size.x < 1120.0
    health_bar.custom_minimum_size.x = 180.0 if compact else 250.0
    xp_bar.custom_minimum_size.x = 180.0 if compact else 250.0
    region_label.add_theme_font_size_override("font_size", 18 if compact else 20)
    timer_label.add_theme_font_size_override("font_size", 19 if compact else 22)
    objective_label.add_theme_font_size_override("font_size", 16 if compact else 18)
    objective_label.visible = true
    environment_label.add_theme_font_size_override("font_size", 16 if compact else 18)
    weapon_label.add_theme_font_size_override("font_size", 18 if compact else 20)

func show_banner(_text: String, _duration: float = 2.3) -> void:
    # Mensagens grandes no centro da tela foram removidas.
    # Informacoes persistentes continuam no HUD, menus e barras.
    banner_token += 1
    banner.visible = false

func _format_time(value: float) -> String:
    var total := maxi(0, int(ceil(value)))
    return "%02d:%02d" % [floori(float(total) / 60.0), total % 60]

func _format_elapsed(value: float) -> String:
    var total := maxi(0, int(floor(value)))
    return "%02d:%02d" % [floori(float(total) / 60.0), total % 60]
