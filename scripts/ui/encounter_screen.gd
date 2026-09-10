class_name EncounterScreen
extends CanvasLayer

signal choice_selected(choice_id: String)

@onready var root: Control = $Root
@onready var title_label: Label = $Root/Center/Panel/Box/Title
@onready var description_label: Label = $Root/Center/Panel/Box/Description
@onready var options_box: VBoxContainer = $Root/Center/Panel/Box/Options
@onready var close_button: Button = $Root/Center/Panel/Box/Close

var opened := false
var previous_pause_state := false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    root.visible = false
    close_button.pressed.connect(close)
    SettingsManager.language_changed.connect(_on_language_changed)
    SettingsManager.register_accessibility_ui(root)
    _on_language_changed(SettingsManager.language)

func _on_language_changed(_locale: String) -> void:
    close_button.text = SettingsManager.t("leave")
    SettingsManager.apply_accessibility(root)

func open_screen(title: String, description: String, options: Array) -> void:
    previous_pause_state = get_tree().paused
    get_tree().paused = true
    opened = true
    root.visible = true
    title_label.text = title
    description_label.text = description
    for child in options_box.get_children():
        child.queue_free()
    for option_value in options:
        var option: Dictionary = option_value
        var button := Button.new()
        button.custom_minimum_size = Vector2(0, 54)
        button.text = String(option.get("text", "Escolher"))
        button.disabled = not bool(option.get("enabled", true))
        button.tooltip_text = String(option.get("tooltip", ""))
        button.add_theme_font_size_override("font_size", 17)
        var choice_id := String(option.get("id", ""))
        button.pressed.connect(_choose.bind(choice_id))
        options_box.add_child(button)
    SettingsManager.apply_accessibility(root)

func _unhandled_input(event: InputEvent) -> void:
    if not opened:
        return
    if event.is_action_pressed("ui_cancel"):
        close()
        get_viewport().set_input_as_handled()

func _choose(choice_id: String) -> void:
    if choice_id.is_empty():
        return
    choice_selected.emit(choice_id)
    close()

func close() -> void:
    if not opened:
        return
    opened = false
    root.visible = false
    get_tree().paused = previous_pause_state
