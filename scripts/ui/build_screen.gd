class_name BuildScreen
extends CanvasLayer

@onready var root: Control = $Root
@onready var evolution_grid: GridContainer = $Root/Margin/Main/Left/LeftBox/EvolutionScroll/EvolutionGrid
@onready var close_button: Button = $Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/Header/CloseButton
@onready var preview: BuildPlayerPreview = $Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/PrimaryContent/Preview
@onready var radar: RegionRadarChart = $Root/Margin/Main/Center/AffinityPanel/AffinityBox/AffinityContent/Radar
@onready var mutagen_bar: ProgressBar = $Root/Margin/Main/Center/AffinityPanel/AffinityBox/AffinityContent/MutagenBox/MutagenBar
@onready var mutagen_value: Label = $Root/Margin/Main/Center/AffinityPanel/AffinityBox/AffinityContent/MutagenBox/MutagenValue
@onready var build_summary: Label = $Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/BuildSummary

@onready var primary_values := {
    "physical": $Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/PrimaryContent/PrimaryGrid/PhysicalValue,
    "skill": $Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/PrimaryContent/PrimaryGrid/SkillValue,
    "max_hp": $Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/PrimaryContent/PrimaryGrid/HPValue,
    "social": $Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/PrimaryContent/PrimaryGrid/SocialValue,
    "speed": $Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/PrimaryContent/PrimaryGrid/SpeedValue
}

@onready var secondary_values := {
    "damage": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OffenseGrid/DamageValue,
    "reloads": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OffenseGrid/ReloadValue,
    "attack_area": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OffenseGrid/AreaValue,
    "attack_penalty": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OffenseGrid/PenaltyValue,
    "size": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OffenseGrid/SizeValue,
    "regeneration": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/RegenValue,
    "madness": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/MadnessValue,
    "damage_resistance": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/DamageResValue,
    "poison_resistance": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/PoisonResValue,
    "dodge": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/DodgeValue,
    "heat_adaptation": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/HeatValue,
    "cold_adaptation": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/ColdValue,
    "food_progress": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/ConsumptionGrid/FoodValue,
    "consumption_speed": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/ConsumptionGrid/ConsumeSpeedValue,
    "consumption_distance": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/ConsumptionGrid/ConsumeDistanceValue,
    "terrain_adaptation": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OtherGrid/TerrainValue,
    "senses": $Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OtherGrid/SensesValue
}

var previous_pause_state := false
var opened := false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    root.visible = false
    close_button.pressed.connect(close)
    SettingsManager.language_changed.connect(_on_language_changed)
    SettingsManager.register_accessibility_ui(root)
    _refresh_static_texts()

func _on_language_changed(_locale: String) -> void:
    _refresh_static_texts()
    if opened:
        var player := get_tree().get_first_node_in_group("player") as Player
        if is_instance_valid(player):
            _refresh(player)

func _refresh_static_texts() -> void:
    if not is_node_ready():
        return
    var labels := {
        "Root/Margin/Main/Left/LeftBox/Title":"evolutions",
        "Root/Margin/Main/Left/LeftBox/Hint":"evolution_tip",
        "Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/Header/Title":"primary_attributes",
        "Root/Margin/Main/Center/AffinityPanel/AffinityBox/Title":"regional_affinities",
        "Root/Margin/Main/Right/RightBox/Title":"secondary_attributes",
        "Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/PrimaryContent/PrimaryGrid/PhysicalLabel":"physical",
        "Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/PrimaryContent/PrimaryGrid/SkillLabel":"skill",
        "Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/PrimaryContent/PrimaryGrid/HPLabel":"max_hp",
        "Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/PrimaryContent/PrimaryGrid/SocialLabel":"social",
        "Root/Margin/Main/Center/PrimaryPanel/PrimaryBox/PrimaryContent/PrimaryGrid/SpeedLabel":"speed",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OffenseTitle":"offense",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OffenseGrid/DamageLabel":"damage",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OffenseGrid/ReloadLabel":"reloads",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OffenseGrid/AreaLabel":"attack_area",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OffenseGrid/PenaltyLabel":"attack_penalty",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OffenseGrid/SizeLabel":"size",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalTitle":"survival",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/RegenLabel":"regeneration",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/MadnessLabel":"madness",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/DamageResLabel":"damage_resistance",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/PoisonResLabel":"poison_resistance",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/DodgeLabel":"dodge",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/HeatLabel":"heat_adaptation",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/SurvivalGrid/ColdLabel":"cold_adaptation",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/ConsumptionTitle":"consumption",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/ConsumptionGrid/FoodLabel":"food_progress_attr",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/ConsumptionGrid/ConsumeSpeedLabel":"consumption_speed",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/ConsumptionGrid/ConsumeDistanceLabel":"consumption_distance",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OtherTitle":"other",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OtherGrid/TerrainLabel":"terrain_adaptation",
        "Root/Margin/Main/Right/RightBox/SecondaryScroll/SecondaryBox/OtherGrid/SensesLabel":"senses"
    }
    for path in labels:
        var node := get_node_or_null(path)
        if node is Label:
            node.text = SettingsManager.t(String(labels[path]))
    close_button.text = SettingsManager.t("close_c")
    SettingsManager.apply_accessibility(root)

func _input(event: InputEvent) -> void:
    var key_event: InputEventKey = event as InputEventKey
    var tab_pressed := is_instance_valid(key_event) and key_event.pressed and not key_event.echo and (key_event.keycode == KEY_TAB or key_event.physical_keycode == KEY_TAB)
    if event.is_action_pressed("build_screen") or tab_pressed:
        if opened:
            close()
        else:
            open()
        get_viewport().set_input_as_handled()
    elif opened and is_instance_valid(key_event) and key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE:
        close()
        get_viewport().set_input_as_handled()

func open() -> void:
    var player := get_tree().get_first_node_in_group("player") as Player
    if not is_instance_valid(player):
        return
    if player.pending_level_up or GameSession.run_finished:
        return
    previous_pause_state = get_tree().paused
    get_tree().paused = true
    opened = true
    root.visible = true
    _refresh(player)

func close() -> void:
    if not opened:
        return
    opened = false
    root.visible = false
    get_tree().paused = previous_pause_state

func _refresh(player: Player) -> void:
    var stats := player.get_build_stats()
    primary_values["physical"].text = "%.1f" % float(stats["physical"])
    primary_values["skill"].text = "%.1f" % float(stats["skill"])
    primary_values["max_hp"].text = "%d" % int(round(float(stats["max_hp"])))
    primary_values["social"].text = "%.0f" % float(stats["social"])
    primary_values["speed"].text = "%.1f" % float(stats["speed"])

    _set_percent("damage", stats)
    _set_percent("reloads", stats)
    _set_percent("attack_area", stats)
    _set_percent("attack_penalty", stats)
    _set_percent("size", stats)
    secondary_values["regeneration"].text = "%.1f/s" % float(stats["regeneration"])
    secondary_values["madness"].text = "%d%%" % int(round(float(stats["madness"]) * 100.0))
    _set_percent("damage_resistance", stats)
    _set_percent("poison_resistance", stats)
    _set_percent("dodge", stats)
    _set_percent("heat_adaptation", stats)
    _set_percent("cold_adaptation", stats)
    _set_percent("food_progress", stats)
    _set_percent("consumption_speed", stats)
    secondary_values["consumption_distance"].text = "%.1f" % float(stats["consumption_distance"])
    _set_percent("terrain_adaptation", stats)
    _set_percent("senses", stats)

    var ultimate_name := String(CombatDB.ULTIMATES[String(stats["equipped_ultimate"])]["name"])
    var movement_name := String(CombatDB.MOVEMENTS[String(stats["equipped_movement"])]["name"])
    build_summary.text = "Nv. %d • %d/%d Progress • Arma: %s\nUltimate: %s • Dash: %s • Genetic: %s • 51 stats internos" % [int(stats["level"]), int(stats["xp"]), int(stats["xp_needed"]), String(stats["current_weapon"]), ultimate_name, movement_name, String(stats["genetic"])]

    preview.set_build(player.upgrade_levels, player.level, float(stats["size"]))
    radar.set_values(stats["build_affinities"])
    mutagen_bar.value = minf(100.0, float(stats["mutagen"]))
    mutagen_value.text = "%d" % int(stats["mutagen"])
    _rebuild_evolution_cards(player.upgrade_levels, player.upgrade_rarities)
    SettingsManager.apply_accessibility(root)

func _join_values(values: Array) -> String:
    var parts := PackedStringArray()
    for value in values:
        parts.append(String(value))
    return ", ".join(parts)

func _set_percent(key: String, stats: Dictionary) -> void:
    secondary_values[key].text = "%d%%" % int(round(float(stats[key]) * 100.0))

func _rebuild_evolution_cards(levels: Dictionary, rarities: Dictionary) -> void:
    for child in evolution_grid.get_children():
        child.queue_free()

    var acquired: Array[Dictionary] = []
    for upgrade in UpgradeDB.ALL_UPGRADES:
        var upgrade_id := String(upgrade["id"])
        var current := int(levels.get(upgrade_id, 0))
        if current > 0:
            acquired.append(upgrade)
    acquired.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        var level_a := int(levels.get(String(a["id"]), 0))
        var level_b := int(levels.get(String(b["id"]), 0))
        if level_a == level_b:
            return String(a["name"]) < String(b["name"])
        return level_a > level_b
    )
    if acquired.is_empty():
        var empty_label := Label.new()
        empty_label.text = "Suas Evolucoes aparecerao aqui.\nAlimente-se para obter Progress."
        empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        empty_label.add_theme_color_override("font_color", Color("#6e402d"))
        evolution_grid.add_child(empty_label)
        return
    for upgrade in acquired:
        var upgrade_id := String(upgrade["id"])
        var current := int(levels.get(upgrade_id, 0))
        var maximum := int(upgrade["max"])
        var rarity := String(rarities.get(upgrade_id, "common"))
        evolution_grid.add_child(_make_evolution_card(upgrade, current, maximum, rarity))

func _make_evolution_card(upgrade: Dictionary, current: int, maximum: int, rarity: String) -> Control:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(100.0, 116.0)
    panel.tooltip_text = "%s\n%s" % [String(upgrade["name"]), String(upgrade["desc"])]

    var style := StyleBoxFlat.new()
    var rarity_colors: Dictionary = {
        "common": Color("#8e6c43"),
        "rare": Color("#2f83b9"),
        "epic": Color("#873aa5"),
        "legendary": Color("#c75b20")
    }
    var border_color: Color = rarity_colors.get(rarity, Color("#8e6c43"))
    style.bg_color = Color("#70482d")
    style.border_color = border_color
    style.border_width_left = 3
    style.border_width_top = 3
    style.border_width_right = 3
    style.border_width_bottom = 3
    style.corner_radius_top_left = 5
    style.corner_radius_top_right = 5
    style.corner_radius_bottom_left = 5
    style.corner_radius_bottom_right = 5
    panel.add_theme_stylebox_override("panel", style)

    var box := VBoxContainer.new()
    box.alignment = BoxContainer.ALIGNMENT_CENTER
    panel.add_child(box)

    var icon_path := "res://assets/sprites/ui/evolutions/%s.png" % String(upgrade["id"])
    if ResourceLoader.exists(icon_path):
        var icon := TextureRect.new()
        icon.custom_minimum_size = Vector2(0.0, 62.0)
        icon.texture = load(icon_path) as Texture2D
        icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        box.add_child(icon)
    else:
        var placeholder := Label.new()
        placeholder.custom_minimum_size = Vector2(0.0, 56.0)
        placeholder.text = String(upgrade["name"]).left(2).to_upper()
        placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        placeholder.add_theme_font_size_override("font_size", 24)
        placeholder.add_theme_color_override("font_color", Color("#f9e6b1"))
        box.add_child(placeholder)

    var name_label := Label.new()
    name_label.text = String(upgrade["name"])
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    name_label.add_theme_font_size_override("font_size", 11)
    name_label.add_theme_color_override("font_color", Color("#fff0c3"))
    box.add_child(name_label)

    var pips := ""
    for i in range(maximum):
        pips += "●" if i < current else "○"
    var pip_label := Label.new()
    pip_label.text = pips
    pip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    pip_label.add_theme_font_size_override("font_size", 11)
    pip_label.add_theme_color_override("font_color", Color("#ffe05c") if current > 0 else Color("#b8a993"))
    box.add_child(pip_label)
    return panel
