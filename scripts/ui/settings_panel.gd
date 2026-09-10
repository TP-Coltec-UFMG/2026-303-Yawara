class_name SettingsPanel
extends Control

signal close_requested

@onready var title_label: Label = $Shade/Center/Panel/Margin/Box/Title
@onready var subtitle_label: Label = $Shade/Center/Panel/Margin/Box/Subtitle
@onready var options: VBoxContainer = $Shade/Center/Panel/Margin/Box/Scroll/Options
@onready var master_slider: HSlider = $Shade/Center/Panel/Margin/Box/Scroll/Options/MasterRow/Master
@onready var music_slider: HSlider = $Shade/Center/Panel/Margin/Box/Scroll/Options/MusicRow/Music
@onready var sfx_slider: HSlider = $Shade/Center/Panel/Margin/Box/Scroll/Options/SFXRow/SFX
@onready var fullscreen_check: CheckButton = $Shade/Center/Panel/Margin/Box/Scroll/Options/Fullscreen
@onready var language_option: OptionButton = $Shade/Center/Panel/Margin/Box/Scroll/Options/LanguageRow/Language
@onready var contrast_check: CheckButton = $Shade/Center/Panel/Margin/Box/Scroll/Options/HighContrast
@onready var motion_check: CheckButton = $Shade/Center/Panel/Margin/Box/Scroll/Options/ReduceMotion
@onready var flashes_check: CheckButton = $Shade/Center/Panel/Margin/Box/Scroll/Options/ReduceFlashes
@onready var shake_check: CheckButton = $Shade/Center/Panel/Margin/Box/Scroll/Options/ScreenShake
@onready var shake_slider: HSlider = $Shade/Center/Panel/Margin/Box/Scroll/Options/ShakeRow/Shake
@onready var text_slider: HSlider = $Shade/Center/Panel/Margin/Box/Scroll/Options/TextRow/TextScale
@onready var aim_option: OptionButton = $Shade/Center/Panel/Margin/Box/Scroll/Options/AimRow/Aim
@onready var hint_label: Label = $Shade/Center/Panel/Margin/Box/Scroll/Options/Hint
@onready var back_button: Button = $Shade/Center/Panel/Margin/Box/Back

var syncing := false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _populate_options()
    master_slider.value_changed.connect(_on_master_changed)
    music_slider.value_changed.connect(_on_music_changed)
    sfx_slider.value_changed.connect(_on_sfx_changed)
    fullscreen_check.toggled.connect(_on_fullscreen_toggled)
    language_option.item_selected.connect(_on_language_selected)
    contrast_check.toggled.connect(_on_contrast_toggled)
    motion_check.toggled.connect(_on_motion_toggled)
    flashes_check.toggled.connect(_on_flashes_toggled)
    shake_check.toggled.connect(_on_shake_toggled)
    shake_slider.value_changed.connect(_on_shake_intensity_changed)
    text_slider.value_changed.connect(_on_text_scale_changed)
    aim_option.item_selected.connect(_on_aim_selected)
    back_button.pressed.connect(_on_back_pressed)
    SettingsManager.settings_changed.connect(_sync_from_manager)
    SettingsManager.language_changed.connect(_on_language_changed)
    _sync_from_manager()
    _refresh_texts()
    SettingsManager.register_accessibility_ui(self)

func _populate_options() -> void:
    language_option.clear()
    for locale in SettingsManager.SUPPORTED_LANGUAGES:
        language_option.add_item(String(SettingsManager.LANGUAGE_NAMES[locale]))
        language_option.set_item_metadata(language_option.item_count - 1, locale)
    _populate_aim_options()

func _populate_aim_options() -> void:
    var selected := clampi(SettingsManager.aim_assist, 0, 2)
    aim_option.clear()
    aim_option.add_item(SettingsManager.t("aim_off"), 0)
    aim_option.add_item(SettingsManager.t("aim_light"), 1)
    aim_option.add_item(SettingsManager.t("aim_strong"), 2)
    aim_option.select(selected)

func open_panel() -> void:
    visible = true
    SettingsManager.sync_fullscreen_from_window()
    _sync_from_manager()
    _refresh_texts()
    back_button.grab_focus()

func _sync_from_manager() -> void:
    if not is_node_ready(): return
    syncing = true
    master_slider.value = SettingsManager.master_volume
    music_slider.value = SettingsManager.music_volume
    sfx_slider.value = SettingsManager.sfx_volume
    fullscreen_check.button_pressed = SettingsManager.fullscreen
    contrast_check.button_pressed = SettingsManager.high_contrast
    motion_check.button_pressed = SettingsManager.reduce_motion
    flashes_check.button_pressed = SettingsManager.reduce_flashes
    shake_check.button_pressed = SettingsManager.screen_shake
    shake_slider.value = SettingsManager.shake_intensity
    text_slider.value = SettingsManager.text_scale
    aim_option.select(clampi(SettingsManager.aim_assist, 0, 2))
    for i in range(language_option.item_count):
        if String(language_option.get_item_metadata(i)) == SettingsManager.language:
            language_option.select(i)
            break
    syncing = false
    SettingsManager.apply_accessibility(self)

func _refresh_texts() -> void:
    title_label.text = SettingsManager.t("settings")
    subtitle_label.text = SettingsManager.t("settings_subtitle")
    options.get_node("AudioTitle").text = SettingsManager.t("audio")
    options.get_node("VideoTitle").text = SettingsManager.t("video")
    options.get_node("LanguageTitle").text = SettingsManager.t("language")
    options.get_node("AccessTitle").text = SettingsManager.t("accessibility")
    options.get_node("MasterRow/Label").text = SettingsManager.t("master_volume")
    options.get_node("MusicRow/Label").text = SettingsManager.t("music")
    options.get_node("SFXRow/Label").text = SettingsManager.t("sfx")
    fullscreen_check.text = SettingsManager.t("fullscreen")
    options.get_node("LanguageRow/Label").text = SettingsManager.t("language")
    contrast_check.text = SettingsManager.t("high_contrast")
    motion_check.text = SettingsManager.t("reduce_motion")
    flashes_check.text = SettingsManager.t("reduce_flashes")
    shake_check.text = SettingsManager.t("screen_shake")
    options.get_node("ShakeRow/Label").text = SettingsManager.t("shake_intensity")
    options.get_node("TextRow/Label").text = SettingsManager.t("text_size")
    options.get_node("AimRow/Label").text = SettingsManager.t("aim_assist")
    hint_label.text = SettingsManager.t("settings_hint")
    back_button.text = SettingsManager.t("back")
    _populate_aim_options()

func _on_language_changed(_locale: String) -> void:
    _refresh_texts()
    _sync_from_manager()

func _on_master_changed(value: float) -> void:
    if not syncing: SettingsManager.update_setting("master_volume", value)
func _on_music_changed(value: float) -> void:
    if not syncing: SettingsManager.update_setting("music_volume", value)
func _on_sfx_changed(value: float) -> void:
    if not syncing: SettingsManager.update_setting("sfx_volume", value)
func _on_fullscreen_toggled(enabled: bool) -> void:
    if not syncing: SettingsManager.update_setting("fullscreen", enabled)
func _on_language_selected(index: int) -> void:
    if syncing: return
    var locale := String(language_option.get_item_metadata(index))
    SettingsManager.update_setting("language", locale)
func _on_contrast_toggled(enabled: bool) -> void:
    if not syncing: SettingsManager.update_setting("high_contrast", enabled)
func _on_motion_toggled(enabled: bool) -> void:
    if not syncing: SettingsManager.update_setting("reduce_motion", enabled)
func _on_flashes_toggled(enabled: bool) -> void:
    if not syncing: SettingsManager.update_setting("reduce_flashes", enabled)
func _on_shake_toggled(enabled: bool) -> void:
    if not syncing: SettingsManager.update_setting("screen_shake", enabled)
func _on_shake_intensity_changed(value: float) -> void:
    if not syncing: SettingsManager.update_setting("shake_intensity", value)
func _on_text_scale_changed(value: float) -> void:
    if not syncing: SettingsManager.update_setting("text_scale", value)
func _on_aim_selected(index: int) -> void:
    if not syncing: SettingsManager.update_setting("aim_assist", index)
func _on_back_pressed() -> void:
    visible = false
    close_requested.emit()
