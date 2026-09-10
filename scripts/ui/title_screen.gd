extends Control

@onready var start_button: Button = $MainLayout/MenuPanel/Margin/Box/Buttons/Start
@onready var settings_button: Button = $MainLayout/MenuPanel/Margin/Box/Buttons/Settings
@onready var quit_button: Button = $MainLayout/MenuPanel/Margin/Box/Buttons/Quit
@onready var settings_panel: SettingsPanel = $SettingsPanel
@onready var heading: Label = $MainLayout/MenuPanel/Margin/Box/Heading
@onready var hint: Label = $MainLayout/MenuPanel/Margin/Box/Hint
@onready var pitch: Label = $MainLayout/InfoPanel/Margin/Box/Pitch
@onready var lore: Label = $MainLayout/InfoPanel/Margin/Box/Lore
@onready var controls: Label = $MainLayout/InfoPanel/Margin/Box/Controls
@onready var duration: Label = $MainLayout/InfoPanel/Margin/Box/Duration
@onready var mode_option: OptionButton = $MainLayout/MenuPanel/Margin/Box/Buttons/ModeRow/Mode
@onready var pressure_spin: SpinBox = $MainLayout/MenuPanel/Margin/Box/Buttons/PressureRow/Pressure
@onready var genetic_option: OptionButton = $MainLayout/MenuPanel/Margin/Box/Buttons/GeneticRow/Genetic
@onready var splice_option: OptionButton = $MainLayout/MenuPanel/Margin/Box/Buttons/SpliceRow/Splice
@onready var title_label: Label = $Title
@onready var subtitle_label: Label = $Subtitle
@onready var main_layout: HBoxContainer = $MainLayout
@onready var menu_panel: PanelContainer = $MainLayout/MenuPanel
@onready var info_panel: PanelContainer = $MainLayout/InfoPanel

var _base_title_size := 46
var _base_subtitle_size := 21

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    start_button.pressed.connect(_start_game)
    settings_button.pressed.connect(_open_settings)
    quit_button.pressed.connect(_quit)
    settings_panel.close_requested.connect(_close_settings)
    settings_panel.visible = false
    SettingsManager.settings_changed.connect(_refresh_texts)
    SettingsManager.language_changed.connect(_language_changed)
    SettingsManager.register_accessibility_ui(self)
    get_viewport().size_changed.connect(_update_layout)
    _populate_run_options()
    _refresh_texts()
    call_deferred("_update_layout")
    AudioManager.play_music("music_menu.ogg")
    start_button.grab_focus()

func _language_changed(_locale: String) -> void:
    _refresh_texts()

func _refresh_texts() -> void:
    if not is_node_ready(): return
    _base_title_size = 46
    _base_subtitle_size = 21
    heading.text = SettingsManager.t("journey")
    start_button.text = SettingsManager.t("start")
    settings_button.text = SettingsManager.t("settings")
    quit_button.text = SettingsManager.t("quit")
    hint.text = SettingsManager.t("pause_hint")
    pitch.text = SettingsManager.t("pitch")
    lore.text = SettingsManager.t("lore")
    controls.text = SettingsManager.t("controls")
    duration.text = SettingsManager.t("duration")
    SettingsManager.apply_accessibility(self)
    _refresh_option_row_labels()
    _update_layout()

func _unhandled_input(event: InputEvent) -> void:
    if settings_panel.visible and event.is_action_pressed("ui_cancel"):
        _close_settings()
        get_viewport().set_input_as_handled()

func _start_game() -> void:
    var mode := GameSession.RunMode.NORMAL
    if mode_option.selected == 1: mode = GameSession.RunMode.PRESSURE
    elif mode_option.selected == 2: mode = GameSession.RunMode.ENDLESS
    var genetic_id := String(genetic_option.get_item_metadata(genetic_option.selected))
    var secondary := String(splice_option.get_item_metadata(splice_option.selected))
    GameSession.configure_run(mode, int(pressure_spin.value), genetic_id, secondary)
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/world/game_world.tscn")

func _populate_run_options() -> void:
    mode_option.clear()
    mode_option.add_item("Normal — Yawara em 08:00")
    mode_option.add_item("Pressure — dificuldade 0 a 20")
    mode_option.add_item("Endless — continua apos Yawara")
    genetic_option.clear()
    splice_option.clear()
    splice_option.add_item("Sem Splicing")
    splice_option.set_item_metadata(0, "")
    var ids: Array = GeneticsDB.GENETICS.keys()
    ids.sort()
    for id_value in ids:
        var id := String(id_value)
        var name_value := String(GeneticsDB.GENETICS[id]["name"])
        genetic_option.add_item(name_value)
        genetic_option.set_item_metadata(genetic_option.item_count - 1, id)
        splice_option.add_item(name_value)
        splice_option.set_item_metadata(splice_option.item_count - 1, id)
    var standard_index := ids.find("standard")
    genetic_option.select(maxi(0, standard_index))

func _open_settings() -> void:
    settings_panel.open_panel()

func _close_settings() -> void:
    settings_panel.visible = false
    settings_button.grab_focus()

func _quit() -> void:
    get_tree().quit()

func _refresh_option_row_labels() -> void:
    var mode_label := $MainLayout/MenuPanel/Margin/Box/Buttons/ModeRow/Label as Label
    var pressure_label := $MainLayout/MenuPanel/Margin/Box/Buttons/PressureRow/Label as Label
    var genetic_label := $MainLayout/MenuPanel/Margin/Box/Buttons/GeneticRow/Label as Label
    var splice_label := $MainLayout/MenuPanel/Margin/Box/Buttons/SpliceRow/Label as Label
    if mode_label: mode_label.text = "Modo"
    if pressure_label: pressure_label.text = "Pressão"
    if genetic_label: genetic_label.text = "Base"
    if splice_label: splice_label.text = "Splicing"

func _update_layout() -> void:
    if not is_node_ready():
        return
    var viewport_size := get_viewport().get_visible_rect().size
    var compact := viewport_size.x < 1160.0 or viewport_size.y < 700.0
    var tiny := viewport_size.x < 930.0 or viewport_size.y < 620.0

    menu_panel.custom_minimum_size.x = 280.0 if compact else 320.0
    info_panel.custom_minimum_size.x = 340.0 if compact else 460.0
    main_layout.add_theme_constant_override("separation", 12 if compact else 20)

    title_label.add_theme_font_size_override("font_size", 34 if tiny else (40 if compact else _base_title_size))
    subtitle_label.add_theme_font_size_override("font_size", 17 if tiny else (19 if compact else _base_subtitle_size))

    pitch.add_theme_font_size_override("font_size", 18 if tiny else (20 if compact else 22))
    controls.add_theme_font_size_override("font_size", 14 if tiny else 16)
    duration.add_theme_font_size_override("font_size", 15 if tiny else 16)
    lore.add_theme_font_size_override("font_size", 14 if tiny else 16)

    # Em telas pequenas, simplifica o bloco de descrição para não sair da tela.
    if tiny:
        lore.text = "Explore biomas brasileiros procedurais, evolua sua criatura e prepare-se para Yawara. Guardiões surgem em 03:00 e 06:00; Yawara desperta em 08:00."
    else:
        lore.text = SettingsManager.t("lore")

    if compact:
        controls.text = "WASD mover • Mouse atacar • Espaço dash • F ultimate
E interagir • C/Tab build • Q/R armas • X reroll"
    else:
        controls.text = SettingsManager.t("controls")

