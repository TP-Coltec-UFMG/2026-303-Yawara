class_name EndScreen
extends CanvasLayer

@onready var root: Control = $Root
@onready var title: Label = $Root/Panel/Box/Title
@onready var message: Label = $Root/Panel/Box/Message
@onready var restart_button: Button = $Root/Panel/Box/Restart
@onready var menu_button: Button = $Root/Panel/Box/Menu
var last_victory := false
var last_level := 1

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    restart_button.pressed.connect(_restart)
    menu_button.pressed.connect(_menu)
    SettingsManager.register_accessibility_ui($Root)
    SettingsManager.language_changed.connect(_on_language_changed)
    root.visible = false
    _refresh_buttons()

func _refresh_buttons() -> void:
    restart_button.text = SettingsManager.t("restart")
    menu_button.text = SettingsManager.t("menu")

func _on_language_changed(_locale: String) -> void:
    _refresh_buttons()
    if root.visible: show_result(last_victory, last_level, false)

func show_result(victory: bool, level: int, play_sound: bool = true) -> void:
    last_victory = victory; last_level = level
    root.visible = true
    if victory:
        title.text = SettingsManager.t("victory")
        message.text = SettingsManager.t("victory_msg") % level
        if play_sound: AudioManager.play_sfx("victory.wav")
    else:
        title.text = SettingsManager.t("defeat")
        message.text = SettingsManager.t("defeat_msg") % level
        if play_sound: AudioManager.play_sfx("defeat.wav")
    SettingsManager.apply_accessibility($Root)

func _restart() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()

func _menu() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
