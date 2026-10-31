extends Control

@onready var start_button: Button = $Buttons/Start
@onready var settings_button: Button = $Buttons/Settings
@onready var quit_button: Button = $Buttons/Quit
@onready var run_button: Button = $Buttons/RunOptions
@onready var settings_panel: SettingsPanel = $SettingsPanel
@onready var run_options: Control = $RunOptions
@onready var mode_option: OptionButton = $RunOptions/Center/Panel/Margin/Box/Mode
@onready var pressure_spin: SpinBox = $RunOptions/Center/Panel/Margin/Box/Pressure
@onready var genetic_option: OptionButton = $RunOptions/Center/Panel/Margin/Box/Genetic
@onready var splice_option: OptionButton = $RunOptions/Center/Panel/Margin/Box/Splice

func _ready() -> void:
	YawaraSkin.apply(self)
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.pressed.connect(_start_game)
	settings_button.pressed.connect(_open_settings)
	quit_button.pressed.connect(func() -> void: get_tree().quit())
	run_button.pressed.connect(_open_run_options)
	$RunOptions/Center/Panel/Margin/Box/Close.pressed.connect(_close_run_options)
	settings_panel.close_requested.connect(_close_settings)
	settings_panel.hide()
	run_options.hide()
	SettingsManager.settings_changed.connect(_refresh_texts)
	SettingsManager.language_changed.connect(_language_changed)
	SettingsManager.register_accessibility_ui(self)
	_populate_run_options()
	mode_option.item_selected.connect(_on_mode_changed)
	_on_mode_changed(mode_option.selected)
	_refresh_texts()
	AudioManager.play_music("music_menu.ogg")
	start_button.grab_focus()

func _language_changed(_locale: String) -> void:
	_refresh_texts()

func _refresh_texts() -> void:
	if not is_node_ready():
		return
	start_button.text = SettingsManager.t("start")
	settings_button.text = SettingsManager.t("settings")
	run_button.text = {"pt_BR":"PREPARAR PARTIDA", "en":"RUN OPTIONS", "es":"OPCIONES DE PARTIDA"}.get(SettingsManager.language, "PREPARAR PARTIDA")
	quit_button.text = SettingsManager.t("quit")
	SettingsManager.apply_accessibility(self)

func _start_game() -> void:
	if run_options.visible or settings_panel.visible:
		return
	var genetic_id := String(genetic_option.get_item_metadata(genetic_option.selected))
	var secondary := String(splice_option.get_item_metadata(splice_option.selected))
	if secondary == genetic_id:
		secondary = ""  # Evita aplicar a mesma Genetic duas vezes.
	GameSession.configure_run(mode_option.selected, int(pressure_spin.value), genetic_id, secondary)
	get_tree().paused = false
	var world_path := "res://scenes/world/game_world.tscn"
	var world_scene := load(world_path) as PackedScene
	if world_scene == null:
		_show_start_error("O mapa não pôde ser carregado. Confira o primeiro erro vermelho na aba Saída da Godot.")
		return
	var error := get_tree().change_scene_to_packed(world_scene)
	if error != OK:
		_show_start_error("Falha ao iniciar o mapa (código %d). Confira a aba Saída." % error)

func _show_start_error(message: String) -> void:
	push_error(message)
	var dialog := AcceptDialog.new()
	dialog.title = "Não foi possível iniciar a partida"
	dialog.dialog_text = message
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(540, 180))

func _populate_run_options() -> void:
	mode_option.clear()
	mode_option.add_item("Normal — Yawara em 08:00")
	mode_option.add_item("Pressão — dificuldade 0 a 20")
	mode_option.add_item("Sem fim — continua após Yawara")
	genetic_option.clear()
	splice_option.clear()
	splice_option.add_item("Sem Splicing")
	splice_option.set_item_metadata(0, "")
	var ids: Array = GeneticsDB.GENETICS.keys()
	ids.sort()
	for id_value in ids:
		var id := String(id_value)
		var display_name := String(GeneticsDB.GENETICS[id]["name"])
		genetic_option.add_item(display_name)
		genetic_option.set_item_metadata(genetic_option.item_count - 1, id)
		splice_option.add_item(display_name)
		splice_option.set_item_metadata(splice_option.item_count - 1, id)
	genetic_option.select(maxi(0, ids.find("standard")))

func _on_mode_changed(index: int) -> void:
	pressure_spin.editable = index == GameSession.RunMode.PRESSURE
	pressure_spin.tooltip_text = "A pressão só altera a dificuldade no modo Pressão."

func _open_settings() -> void:
	$Buttons.hide()
	settings_panel.open_panel()

func _close_settings() -> void:
	settings_panel.hide()
	$Buttons.show()
	settings_button.grab_focus()

func _open_run_options() -> void:
	$Buttons.hide()
	run_options.show()
	mode_option.grab_focus()

func _close_run_options() -> void:
	run_options.hide()
	$Buttons.show()
	run_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if settings_panel.visible:
			_close_settings()
			get_viewport().set_input_as_handled()
		elif run_options.visible:
			_close_run_options()
			get_viewport().set_input_as_handled()
