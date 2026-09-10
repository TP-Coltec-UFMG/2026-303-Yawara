class_name PauseMenu
extends CanvasLayer

@onready var root: Control = $Root
@onready var main_panel: Control = $Root/Center/MenuPanel
@onready var title: Label = $Root/Center/MenuPanel/Margin/Box/Title
@onready var resume_button: Button = $Root/Center/MenuPanel/Margin/Box/Resume
@onready var settings_button: Button = $Root/Center/MenuPanel/Margin/Box/Settings
@onready var menu_button: Button = $Root/Center/MenuPanel/Margin/Box/MainMenu
@onready var quit_button: Button = $Root/Center/MenuPanel/Margin/Box/Quit
@onready var hint: Label = $Root/Center/MenuPanel/Margin/Box/Hint
@onready var settings_panel: SettingsPanel = $Root/SettingsPanel

var opened := false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    root.visible = false
    settings_panel.visible = false
    resume_button.pressed.connect(close_pause)
    settings_button.pressed.connect(_open_settings)
    menu_button.pressed.connect(_go_to_menu)
    quit_button.pressed.connect(_quit)
    settings_panel.close_requested.connect(_close_settings)
    SettingsManager.language_changed.connect(_language_changed)
    SettingsManager.register_accessibility_ui(root)
    _refresh_texts()

func _language_changed(_locale: String) -> void:
    _refresh_texts()

func _refresh_texts() -> void:
    if not is_node_ready(): return
    title.text = SettingsManager.t("paused")
    resume_button.text = SettingsManager.t("resume")
    settings_button.text = SettingsManager.t("settings_access")
    menu_button.text = SettingsManager.t("main_menu")
    quit_button.text = SettingsManager.t("quit_game")
    hint.text = SettingsManager.t("pause_resume_hint")
    SettingsManager.apply_accessibility(root)

func _unhandled_input(event: InputEvent) -> void:
    if not event.is_action_pressed("ui_cancel"): return
    if opened:
        if settings_panel.visible: _close_settings()
        else: close_pause()
        get_viewport().set_input_as_handled()
    elif not get_tree().paused:
        open_pause()
        get_viewport().set_input_as_handled()

func open_pause() -> void:
    if opened: return
    opened = true
    root.visible = true
    main_panel.visible = true
    settings_panel.visible = false
    get_tree().paused = true
    resume_button.grab_focus()

func close_pause() -> void:
    if not opened: return
    opened = false
    root.visible = false
    settings_panel.visible = false
    get_tree().paused = false

func _open_settings() -> void:
    main_panel.visible = false
    settings_panel.open_panel()

func _close_settings() -> void:
    settings_panel.visible = false
    main_panel.visible = true
    settings_button.grab_focus()

func _go_to_menu() -> void:
    opened = false
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")

func _quit() -> void:
    get_tree().quit()
