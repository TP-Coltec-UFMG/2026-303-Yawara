class_name UpgradeMenu
extends CanvasLayer

signal upgrade_selected(upgrade_id: String, rarity: String)
signal reroll_requested
signal rarity_upgrade_requested(option_index: int)

@onready var root: Control = $Root
@onready var title: Label = $Root/Panel/Margin/Layout/Left/Title
@onready var hint: Label = $Root/Panel/Margin/Layout/Left/Hint
@onready var detail_title: Label = $Root/Panel/Margin/Layout/Right/Margin/VBox/DetailTitle
@onready var detail_body: Label = $Root/Panel/Margin/Layout/Right/Margin/VBox/DetailBody
@onready var buttons: Array[Button] = [
    $Root/Panel/Margin/Layout/Left/Choices/Choice1,
    $Root/Panel/Margin/Layout/Left/Choices/Choice2,
    $Root/Panel/Margin/Layout/Left/Choices/Choice3
]

var options: Array[Dictionary] = []
var current_levels: Dictionary = {}
var current_player_level := 1
var current_rarity_luck := 0.0
var current_choice_count := 3
var current_forced_minimum := ""
var input_unlocked := false
var focused_option := 0
var branching_mode := false
var reroll_uses := 0
var rarity_upgrade_uses := 0

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    for i in range(buttons.size()):
        buttons[i].pressed.connect(_choose.bind(i))
        buttons[i].mouse_entered.connect(_focus_option.bind(i))
        buttons[i].focus_entered.connect(_focus_option.bind(i))
    SettingsManager.register_accessibility_ui(root)
    SettingsManager.language_changed.connect(_on_language_changed)
    root.visible = false

func _on_language_changed(_locale: String) -> void:
    if root.visible:
        _fill_texts()
    SettingsManager.apply_accessibility(root)

func open(levels: Dictionary, player_level: int, rarity_luck: float = 0.0, choice_count: int = 3, forced_minimum: String = "") -> void:
    current_levels = levels.duplicate()
    current_player_level = player_level
    current_rarity_luck = rarity_luck
    current_choice_count = clampi(choice_count, 1, 3)
    current_forced_minimum = forced_minimum
    branching_mode = false
    reroll_uses = 0
    rarity_upgrade_uses = 0
    options = UpgradeDB.get_options(levels, current_choice_count, rarity_luck, forced_minimum)
    _present_options()

func open_branching(levels: Dictionary, player_level: int, choice_count: int = 3) -> void:
    current_levels = levels.duplicate()
    current_player_level = player_level
    current_rarity_luck = 0.0
    current_choice_count = clampi(choice_count, 1, 3)
    current_forced_minimum = "legendary"
    branching_mode = true
    reroll_uses = 0
    rarity_upgrade_uses = 0
    options = UpgradeDB.get_branching_options(levels, current_choice_count)
    _present_options()

func _present_options() -> void:
    input_unlocked = false
    _fill_texts()
    for button in buttons:
        button.visible = false
        button.disabled = true
    root.visible = true
    await get_tree().create_timer(0.12, true, false, true).timeout
    for i in range(mini(buttons.size(), options.size())):
        buttons[i].visible = true
        buttons[i].modulate.a = 0.0
        var tween := create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(buttons[i], "modulate:a", 1.0, 0.16)
        await get_tree().create_timer(0.18, true, false, true).timeout
        buttons[i].disabled = false
    # pequena trava após a última carta: evita clique de ataque residual.
    await get_tree().create_timer(0.32, true, false, true).timeout
    input_unlocked = true
    if not options.is_empty():
        _focus_option(0)
        buttons[0].grab_focus()

func _fill_texts() -> void:
    title.text = "EVOLUCAO CORPORAL" if branching_mode else SettingsManager.t("evolution") % current_player_level
    hint.text = "Escolha um novo ramo. X troca as opcoes por Mutagen." if branching_mode else SettingsManager.t("evolution_hint")
    detail_title.text = "Escolha um ramo ancestral" if branching_mode else SettingsManager.t("select_evolution")
    detail_body.text = "O Fruto Ancestral altera o corpo e abre novas evolucoes." if branching_mode else SettingsManager.t("evolution_help")
    for i in range(buttons.size()):
        if i < options.size():
            var up: Dictionary = options[i]
            var current := int(current_levels.get(up["id"], 0))
            var rarity: Dictionary = CombatDB.RARITIES[String(up.get("rarity", "rare"))]
            buttons[i].text = "%d. [%s] %s\n%s\n%s" % [i + 1, String(rarity["name"]), up["name"], SettingsManager.t("level_short") % [current + 1, up["max"]], up["desc"]]
            buttons[i].add_theme_color_override("font_color", rarity["color"])
        else:
            buttons[i].text = ""

func _focus_option(index: int) -> void:
    if index < 0 or index >= options.size(): return
    focused_option = index
    var up: Dictionary = options[index]
    detail_title.text = String(up["name"])
    var rarity: Dictionary = CombatDB.RARITIES[String(up.get("rarity", "rare"))]
    if branching_mode:
        detail_body.text = "%s\n\nRamo corporal unico.\n%s\n\nX: novas opcoes (%d Mutagen)" % [String(up["desc"]), SettingsManager.t("category") % String(up["id"]), get_reroll_cost()]
    else:
        detail_body.text = "%s\n\nRaridade: %s (x%.2f)\n%s\n\nX: reroll (%d Mutagen) • U: elevar raridade (%d)" % [String(up["desc"]), String(rarity["name"]), float(rarity["power"]), SettingsManager.t("category") % String(up["id"]), get_reroll_cost(), get_rarity_upgrade_cost()]

func _unhandled_input(event: InputEvent) -> void:
    if not root.visible or not input_unlocked: return
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_1: _choose(0)
        elif event.keycode == KEY_2: _choose(1)
        elif event.keycode == KEY_3: _choose(2)
        elif event.keycode == KEY_X: reroll_requested.emit()
        elif event.keycode == KEY_U and not branching_mode: rarity_upgrade_requested.emit(focused_option)

func _choose(index: int) -> void:
    if not input_unlocked or index < 0 or index >= options.size(): return
    root.visible = false
    input_unlocked = false
    upgrade_selected.emit(String(options[index]["id"]), String(options[index].get("rarity", "rare")))

func reroll() -> void:
    reroll_uses += 1
    if branching_mode:
        options = UpgradeDB.get_branching_options(current_levels, current_choice_count)
    else:
        options = UpgradeDB.get_options(current_levels, current_choice_count, current_rarity_luck, current_forced_minimum)
    _fill_texts()
    if not options.is_empty(): _focus_option(0)

func upgrade_rarity(index: int) -> void:
    if branching_mode or index < 0 or index >= options.size(): return
    var order: Array[String] = ["common", "rare", "epic", "legendary"]
    var current := String(options[index].get("rarity", "common"))
    var next_index := mini(order.size() - 1, order.find(current) + 1)
    options[index]["rarity"] = order[next_index]
    rarity_upgrade_uses += 1
    _fill_texts()
    _focus_option(index)

func get_reroll_cost() -> int:
    return (10 if branching_mode else 1) * (reroll_uses + 1)

func get_rarity_upgrade_cost() -> int:
    return 10 * (rarity_upgrade_uses + 1)
