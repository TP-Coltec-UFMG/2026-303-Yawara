extends Node

signal settings_changed
signal language_changed(locale: String)

const SETTINGS_PATH := "user://ecos_settings.cfg"
const SUPPORTED_LANGUAGES := ["pt_BR", "en", "es"]
const LANGUAGE_NAMES := {
    "pt_BR": "Português (Brasil)",
    "en": "English",
    "es": "Español"
}

var master_volume := 1.0
var music_volume := 0.82
var sfx_volume := 0.90
var fullscreen := false
var language := "pt_BR"

# Acessibilidade aplicada globalmente.
var high_contrast := false
var reduce_motion := false
var reduce_flashes := false
var screen_shake := true
var shake_intensity := 1.0
var text_scale := 1.0
var aim_assist := 1 # 0=off, 1=leve, 2=forte

const STRINGS := {
    "pt_BR": {
        "settings": "CONFIGURAÇÕES",
        "settings_subtitle": "Áudio, vídeo, idioma e acessibilidade — as alterações valem para o jogo inteiro.",
        "audio": "ÁUDIO", "video": "VÍDEO", "language": "IDIOMA", "accessibility": "ACESSIBILIDADE",
        "master_volume": "Volume geral", "music": "Música", "sfx": "Efeitos sonoros", "fullscreen": "Tela cheia",
        "high_contrast": "Alto contraste e contorno de textos", "reduce_motion": "Reduzir movimento de câmera",
        "reduce_flashes": "Reduzir flashes de dano", "screen_shake": "Tremor de tela", "shake_intensity": "Intensidade do tremor",
        "text_size": "Tamanho dos textos", "aim_assist": "Assistência de mira", "back": "VOLTAR",
        "aim_off": "Desligada", "aim_light": "Leve", "aim_strong": "Forte",
        "settings_hint": "Calor e frio também aparecem em texto no HUD; nenhuma informação importante depende apenas de cor.",
        "start": "INICIAR", "quit": "SAIR", "journey": "JORNADA", "pause_hint": "ESC abre o menu de pausa durante a partida.",
        "pitch": "EVOLUA. ADAPTE-SE. SOBREVIVA.",
        "lore": "Explore quatro biomas brasileiros procedurais. Evolua por alimentação, Progress, Mutagen e raridades. Guardiões surgem aos 3 e 6 minutos; Yawara desperta aos 8. Genetics, afinidades, Specialisations, Pressure e Endless mudam cada jornada.",
        "controls": "WASD mover • ambos botões do mouse/J atacar • Espaço dash • F ultimate\nComida automática ao passar por cima • E interagir • C/Tab build • Q/R armas • T ultimate • G dash • X/U Mutagen",
        "duration": "8 min de evolução + até 2 min contra Yawara",
        "paused": "PAUSADO", "resume": "CONTINUAR", "settings_access": "CONFIGURAÇÕES / ACESSIBILIDADE",
        "main_menu": "VOLTAR AO MENU INICIAL", "quit_game": "SAIR DO JOGO", "pause_resume_hint": "ESC continua a partida.",
        "level": "Nível %d", "health": "Vida: %d / %d", "food_progress": "Progresso alimentar: %d / %d",
        "weapon": "ARMA • %s   [Q/R]", "preparation": "PREPARAÇÃO  %s", "final_fight": "CONFRONTO FINAL",
        "time_left": "TEMPO RESTANTE: %s", "heat": "CALOR", "cold": "FRIO",
        "objective": "Explore o mundo infinito • passe sobre comida para comer • C/Tab mostra a build • abates deixam carne, não XP.",
        "boss_objective": "Purifique Yawara antes que a corrupção domine o espírito ancestral.",
        "evolution": "EVOLUÇÃO • NÍVEL %d", "evolution_hint": "As opções aparecem uma a uma. Leia antes de escolher.",
        "select_evolution": "Selecione uma evolução", "evolution_help": "Passe o mouse ou use as teclas 1, 2 e 3 depois que todas as cartas surgirem.",
        "level_short": "Nv. %d/%d", "category": "Categoria: %s",
        "victory": "YAWARA FOI PURIFICADA", "defeat": "A CORRUPÇÃO PREVALECEU",
        "victory_msg": "A corrupção se desfaz e o espírito ancestral volta a proteger a mata.\nNível alcançado: %d",
        "defeat_msg": "Sua jornada terminou, mas a memória das cinco regiões permanece.\nNível alcançado: %d",
        "restart": "RECOMEÇAR", "menu": "MENU INICIAL"
    },
    "en": {
        "settings": "SETTINGS",
        "settings_subtitle": "Audio, video, language and accessibility — changes apply to the whole game.",
        "audio": "AUDIO", "video": "VIDEO", "language": "LANGUAGE", "accessibility": "ACCESSIBILITY",
        "master_volume": "Master volume", "music": "Music", "sfx": "Sound effects", "fullscreen": "Fullscreen",
        "high_contrast": "High contrast and text outlines", "reduce_motion": "Reduce camera motion",
        "reduce_flashes": "Reduce damage flashes", "screen_shake": "Screen shake", "shake_intensity": "Shake intensity",
        "text_size": "Text size", "aim_assist": "Aim assist", "back": "BACK",
        "aim_off": "Off", "aim_light": "Light", "aim_strong": "Strong",
        "settings_hint": "Heat and cold are also shown as text in the HUD; important information never depends on color alone.",
        "start": "START", "quit": "QUIT", "journey": "JOURNEY", "pause_hint": "ESC opens the pause menu during gameplay.",
        "pitch": "EVOLVE. ADAPT. SURVIVE.",
        "lore": "Explore four procedural Brazilian biomes. Evolve through food, Progress, Mutagen and rarities. Guardians arrive at minutes 3 and 6; Yawara awakens at minute 8. Genetics, affinities, Specialisations, Pressure and Endless reshape each run.",
        "controls": "WASD move • either mouse button/J attack • Space dash • F ultimate\nFood is eaten automatically on contact • E interact • C/Tab build • Q/R weapons • T ultimate • G dash • X/U Mutagen",
        "duration": "8 min of evolution + up to 2 min against Yawara",
        "paused": "PAUSED", "resume": "RESUME", "settings_access": "SETTINGS / ACCESSIBILITY",
        "main_menu": "RETURN TO MAIN MENU", "quit_game": "QUIT GAME", "pause_resume_hint": "ESC resumes the game.",
        "level": "Level %d", "health": "Health: %d / %d", "food_progress": "Food progress: %d / %d",
        "weapon": "WEAPON • %s   [Q/R]", "preparation": "PREPARATION  %s", "final_fight": "FINAL CONFRONTATION",
        "time_left": "TIME LEFT: %s", "heat": "HEAT", "cold": "COLD",
        "objective": "Explore the endless world • hold E to eat • C/Tab opens build • defeated creatures leave meat, not XP.",
        "boss_objective": "Purify Yawara before corruption consumes the ancestral spirit.",
        "evolution": "EVOLUTION • LEVEL %d", "evolution_hint": "Choices appear one at a time. Read before choosing.",
        "select_evolution": "Select an evolution", "evolution_help": "Hover or use keys 1, 2 and 3 after all cards appear.",
        "level_short": "Lv. %d/%d", "category": "Category: %s",
        "victory": "YAWARA WAS PURIFIED", "defeat": "CORRUPTION PREVAILED",
        "victory_msg": "The corruption fades and the ancestral spirit returns to protect the land.\nLevel reached: %d",
        "defeat_msg": "Your journey ended, but the memory of the five regions remains.\nLevel reached: %d",
        "restart": "RESTART", "menu": "MAIN MENU"
    },
    "es": {
        "settings": "CONFIGURACIÓN",
        "settings_subtitle": "Audio, vídeo, idioma y accesibilidad — los cambios se aplican a todo el juego.",
        "audio": "AUDIO", "video": "VÍDEO", "language": "IDIOMA", "accessibility": "ACCESIBILIDAD",
        "master_volume": "Volumen general", "music": "Música", "sfx": "Efectos de sonido", "fullscreen": "Pantalla completa",
        "high_contrast": "Alto contraste y contorno de texto", "reduce_motion": "Reducir movimiento de cámara",
        "reduce_flashes": "Reducir destellos de daño", "screen_shake": "Temblor de pantalla", "shake_intensity": "Intensidad del temblor",
        "text_size": "Tamaño del texto", "aim_assist": "Asistencia de apuntado", "back": "VOLVER",
        "aim_off": "Desactivada", "aim_light": "Suave", "aim_strong": "Fuerte",
        "settings_hint": "El calor y el frío también aparecen como texto en el HUD; la información importante no depende solo del color.",
        "start": "INICIAR", "quit": "SALIR", "journey": "JORNADA", "pause_hint": "ESC abre el menú de pausa durante la partida.",
        "pitch": "EVOLUCIONA. ADÁPTATE. SOBREVIVE.",
        "lore": "Explora cuatro biomas brasileños procedurales. Evoluciona mediante comida, Progress, Mutagen y rarezas. Los guardianes aparecen en los minutos 3 y 6; Yawara despierta en el minuto 8. Genetics, afinidades, Specialisations, Pressure y Endless cambian cada partida.",
        "controls": "WASD mover • ambos botones del ratón/J atacar • Espacio dash • F ultimate\nLa comida se consume al tocarla • E interactuar • C/Tab build • Q/R armas • T ultimate • G dash • X/U Mutagen",
        "duration": "8 min de evolución + hasta 2 min contra Yawara",
        "paused": "PAUSA", "resume": "CONTINUAR", "settings_access": "CONFIGURACIÓN / ACCESIBILIDAD",
        "main_menu": "VOLVER AL MENÚ PRINCIPAL", "quit_game": "SALIR DEL JUEGO", "pause_resume_hint": "ESC continúa la partida.",
        "level": "Nivel %d", "health": "Vida: %d / %d", "food_progress": "Progreso de comida: %d / %d",
        "weapon": "ARMA • %s   [Q/R]", "preparation": "PREPARACIÓN  %s", "final_fight": "ENFRENTAMIENTO FINAL",
        "time_left": "TIEMPO RESTANTE: %s", "heat": "CALOR", "cold": "FRÍO",
        "objective": "Explora el mundo infinito • pasa sobre la comida para comer • C/Tab muestra la build • las bajas dejan carne, no XP.",
        "boss_objective": "Purifica a Yawara antes de que la corrupción domine al espíritu ancestral.",
        "evolution": "EVOLUCIÓN • NIVEL %d", "evolution_hint": "Las opciones aparecen una a una. Lee antes de elegir.",
        "select_evolution": "Selecciona una evolución", "evolution_help": "Pasa el ratón o usa las teclas 1, 2 y 3 después de que aparezcan todas las cartas.",
        "level_short": "Nv. %d/%d", "category": "Categoría: %s",
        "victory": "YAWARA FUE PURIFICADA", "defeat": "LA CORRUPCIÓN PREVALECIÓ",
        "victory_msg": "La corrupción desaparece y el espíritu ancestral vuelve a proteger la tierra.\nNivel alcanzado: %d",
        "defeat_msg": "Tu jornada terminó, pero la memoria de las cinco regiones permanece.\nNivel alcanzado: %d",
        "restart": "REINICIAR", "menu": "MENÚ PRINCIPAL"
    }
}

const EXTRA_STRINGS := {
    "pt_BR": {
        "evolutions":"Evoluções", "evolution_tip":"Somente Evoluções adquiridas aparecem aqui.", "primary_attributes":"Atributos Principais", "close_c":"C / TAB", "regional_affinities":"Afinidades", "secondary_attributes":"Atributos Secundários",
        "physical":"Físico", "skill":"Habilidade", "max_hp":"PV máx.", "social":"Social", "speed":"Velocidade", "offense":"Ofensiva", "damage":"Dano", "reloads":"Recargas", "attack_area":"Área de Ataque", "attack_penalty":"Penalidade de Ataque", "size":"Tamanho",
        "survival":"Sobrevivência", "regeneration":"Regeneração", "madness":"Loucura", "damage_resistance":"Resistência a Dano", "poison_resistance":"Resistência a Veneno", "dodge":"Esquiva", "heat_adaptation":"Adaptação ao Calor", "cold_adaptation":"Adaptação ao Frio",
        "consumption":"Consumo", "food_progress_attr":"Progresso de Comida", "consumption_speed":"Vel. de Consumo", "consumption_distance":"Distância de Consumo", "other":"Outros", "terrain_adaptation":"Adaptação a Terreno", "senses":"Sentidos", "encounter":"Ponto de Encontro", "leave":"Sair"
    },
    "en": {
        "evolutions":"Evolutions", "evolution_tip":"Only acquired Evolutions appear here.", "primary_attributes":"Primary Attributes", "close_c":"C / TAB", "regional_affinities":"Affinities", "secondary_attributes":"Secondary Attributes",
        "physical":"Physical", "skill":"Skill", "max_hp":"Max HP", "social":"Social", "speed":"Speed", "offense":"Offense", "damage":"Damage", "reloads":"Cooldowns", "attack_area":"Attack Area", "attack_penalty":"Attack Penalty", "size":"Size",
        "survival":"Survival", "regeneration":"Regeneration", "madness":"Madness", "damage_resistance":"Damage Resistance", "poison_resistance":"Poison Resistance", "dodge":"Dodge", "heat_adaptation":"Heat Adaptation", "cold_adaptation":"Cold Adaptation",
        "consumption":"Consumption", "food_progress_attr":"Food Progress", "consumption_speed":"Consumption Speed", "consumption_distance":"Consumption Distance", "other":"Other", "terrain_adaptation":"Terrain Adaptation", "senses":"Senses", "encounter":"Encounter", "leave":"Leave"
    },
    "es": {
        "evolutions":"Evoluciones", "evolution_tip":"Solo aparecen las Evoluciones adquiridas.", "primary_attributes":"Atributos Principales", "close_c":"C / TAB", "regional_affinities":"Afinidades", "secondary_attributes":"Atributos Secundarios",
        "physical":"Físico", "skill":"Habilidad", "max_hp":"PV máx.", "social":"Social", "speed":"Velocidad", "offense":"Ofensiva", "damage":"Daño", "reloads":"Recargas", "attack_area":"Área de Ataque", "attack_penalty":"Penalización de Ataque", "size":"Tamaño",
        "survival":"Supervivencia", "regeneration":"Regeneración", "madness":"Locura", "damage_resistance":"Resistencia al Daño", "poison_resistance":"Resistencia al Veneno", "dodge":"Esquiva", "heat_adaptation":"Adaptación al Calor", "cold_adaptation":"Adaptación al Frío",
        "consumption":"Consumo", "food_progress_attr":"Progreso de Comida", "consumption_speed":"Vel. de Consumo", "consumption_distance":"Distancia de Consumo", "other":"Otros", "terrain_adaptation":"Adaptación al Terreno", "senses":"Sentidos", "encounter":"Punto de Encuentro", "leave":"Salir"
    }
}

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _ensure_audio_buses()
    _load_settings()
    call_deferred("apply_all")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_F11 or (event.keycode == KEY_ENTER and event.alt_pressed):
            update_setting("fullscreen", not fullscreen)
            get_viewport().set_input_as_handled()

func t(key: String) -> String:
    var table: Dictionary = STRINGS.get(language, STRINGS["pt_BR"])
    if table.has(key):
        return String(table[key])
    var extra: Dictionary = EXTRA_STRINGS.get(language, EXTRA_STRINGS["pt_BR"])
    if extra.has(key):
        return String(extra[key])
    if STRINGS["pt_BR"].has(key):
        return String(STRINGS["pt_BR"][key])
    if EXTRA_STRINGS["pt_BR"].has(key):
        return String(EXTRA_STRINGS["pt_BR"][key])
    return key

func set_language(locale: String) -> void:
    if not SUPPORTED_LANGUAGES.has(locale):
        locale = "pt_BR"
    if language == locale:
        return
    language = locale
    TranslationServer.set_locale(locale)
    _save_settings()
    language_changed.emit(language)
    settings_changed.emit()

func update_setting(key: String, value: Variant) -> void:
    match key:
        "master_volume":
            master_volume = clampf(float(value), 0.0, 1.0)
        "music_volume":
            music_volume = clampf(float(value), 0.0, 1.0)
        "sfx_volume":
            sfx_volume = clampf(float(value), 0.0, 1.0)
        "fullscreen":
            fullscreen = bool(value)
        "language":
            set_language(String(value))
            return
        "high_contrast":
            high_contrast = bool(value)
        "reduce_motion":
            reduce_motion = bool(value)
        "reduce_flashes":
            reduce_flashes = bool(value)
        "screen_shake":
            screen_shake = bool(value)
        "shake_intensity":
            shake_intensity = clampf(float(value), 0.0, 1.5)
        "text_scale":
            text_scale = clampf(float(value), 0.90, 1.50)
        "aim_assist":
            aim_assist = clampi(int(value), 0, 2)
        _:
            return
    _save_settings()
    apply_all()

func apply_all() -> void:
    _ensure_audio_buses()
    _set_bus_volume("Master", master_volume)
    _set_bus_volume("Music", music_volume)
    _set_bus_volume("SFX", sfx_volume)
    TranslationServer.set_locale(language)
    call_deferred("_apply_window_mode")
    for node in get_tree().get_nodes_in_group("accessibility_ui"):
        if is_instance_valid(node):
            apply_accessibility(node)
    settings_changed.emit()

func _apply_window_mode() -> void:
    var current := DisplayServer.window_get_mode()
    if fullscreen:
        if current != DisplayServer.WINDOW_MODE_FULLSCREEN and current != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        if current != DisplayServer.WINDOW_MODE_WINDOWED:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        var screen := DisplayServer.window_get_current_screen()
        var screen_size := DisplayServer.screen_get_size(screen)
        # Mantem 16:9 e deixa margem para barra de tarefas e bordas da janela.
        var safe_width := mini(1152, maxi(800, int(float(screen_size.x) * 0.90)))
        var safe_height := int(round(float(safe_width) * 9.0 / 16.0))
        if safe_height > int(float(screen_size.y) * 0.86):
            safe_height = maxi(450, int(float(screen_size.y) * 0.86))
            safe_width = int(round(float(safe_height) * 16.0 / 9.0))
        var target_size := Vector2i(safe_width, safe_height)
        DisplayServer.window_set_size(target_size)
        DisplayServer.window_set_position(Vector2i(
            floori(float(screen_size.x - target_size.x) / 2.0),
            floori(float(screen_size.y - target_size.y) / 2.0)
        ))

func sync_fullscreen_from_window() -> void:
    var mode := DisplayServer.window_get_mode()
    fullscreen = mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func register_accessibility_ui(root_node: Node) -> void:
    if not is_instance_valid(root_node): return
    if not root_node.is_in_group("accessibility_ui"):
        root_node.add_to_group("accessibility_ui")
    apply_accessibility(root_node)

func apply_accessibility(root_node: Node) -> void:
    if is_instance_valid(root_node):
        _apply_control_recursive(root_node)

func _apply_control_recursive(node: Node) -> void:
    if _is_text_control(node):
        var control := node as Control
        if not control.has_meta("a11y_base_font_size"):
            var base := control.get_theme_font_size("font_size")
            if base <= 0: base = 16
            control.set_meta("a11y_base_font_size", base)
            control.set_meta("a11y_had_outline_color", control.has_theme_color_override("font_outline_color"))
            control.set_meta("a11y_outline_color", control.get_theme_color("font_outline_color"))
            control.set_meta("a11y_had_outline_size", control.has_theme_constant_override("outline_size"))
            control.set_meta("a11y_outline_size", control.get_theme_constant("outline_size"))
        var base_size := int(control.get_meta("a11y_base_font_size", 16))
        control.add_theme_font_size_override("font_size", maxi(11, int(round(float(base_size) * text_scale))))
        if high_contrast:
            control.add_theme_color_override("font_outline_color", Color.BLACK)
            control.add_theme_constant_override("outline_size", maxi(2, int(control.get_meta("a11y_outline_size", 0))))
        else:
            if bool(control.get_meta("a11y_had_outline_color", false)):
                control.add_theme_color_override("font_outline_color", control.get_meta("a11y_outline_color", Color.BLACK))
            else:
                control.remove_theme_color_override("font_outline_color")
            if bool(control.get_meta("a11y_had_outline_size", false)):
                control.add_theme_constant_override("outline_size", int(control.get_meta("a11y_outline_size", 0)))
            else:
                control.remove_theme_constant_override("outline_size")
    for child in node.get_children():
        _apply_control_recursive(child)

func _is_text_control(node: Node) -> bool:
    return node is Label or node is BaseButton or node is LineEdit or node is TextEdit or node is RichTextLabel

func _ensure_audio_buses() -> void:
    _ensure_bus("Music")
    _ensure_bus("SFX")

func _ensure_bus(bus_name: String) -> void:
    if AudioServer.get_bus_index(bus_name) >= 0: return
    AudioServer.add_bus()
    AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

func _set_bus_volume(bus_name: String, linear_value: float) -> void:
    var index := AudioServer.get_bus_index(bus_name)
    if index < 0: return
    var value := clampf(linear_value, 0.0, 1.0)
    AudioServer.set_bus_mute(index, value <= 0.001)
    if value > 0.001:
        AudioServer.set_bus_volume_db(index, linear_to_db(value))

func _save_settings() -> void:
    var config := ConfigFile.new()
    config.set_value("audio", "master_volume", master_volume)
    config.set_value("audio", "music_volume", music_volume)
    config.set_value("audio", "sfx_volume", sfx_volume)
    config.set_value("video", "fullscreen", fullscreen)
    config.set_value("general", "language", language)
    config.set_value("accessibility", "high_contrast", high_contrast)
    config.set_value("accessibility", "reduce_motion", reduce_motion)
    config.set_value("accessibility", "reduce_flashes", reduce_flashes)
    config.set_value("accessibility", "screen_shake", screen_shake)
    config.set_value("accessibility", "shake_intensity", shake_intensity)
    config.set_value("accessibility", "text_scale", text_scale)
    config.set_value("accessibility", "aim_assist", aim_assist)
    config.save(SETTINGS_PATH)

func _load_settings() -> void:
    var config := ConfigFile.new()
    if config.load(SETTINGS_PATH) != OK: return
    master_volume = clampf(float(config.get_value("audio", "master_volume", master_volume)), 0.0, 1.0)
    music_volume = clampf(float(config.get_value("audio", "music_volume", music_volume)), 0.0, 1.0)
    sfx_volume = clampf(float(config.get_value("audio", "sfx_volume", sfx_volume)), 0.0, 1.0)
    fullscreen = bool(config.get_value("video", "fullscreen", fullscreen))
    language = String(config.get_value("general", "language", language))
    if not SUPPORTED_LANGUAGES.has(language): language = "pt_BR"
    high_contrast = bool(config.get_value("accessibility", "high_contrast", high_contrast))
    reduce_motion = bool(config.get_value("accessibility", "reduce_motion", reduce_motion))
    reduce_flashes = bool(config.get_value("accessibility", "reduce_flashes", reduce_flashes))
    screen_shake = bool(config.get_value("accessibility", "screen_shake", screen_shake))
    shake_intensity = clampf(float(config.get_value("accessibility", "shake_intensity", shake_intensity)), 0.0, 1.5)
    text_scale = clampf(float(config.get_value("accessibility", "text_scale", text_scale)), 0.90, 1.50)
    aim_assist = clampi(int(config.get_value("accessibility", "aim_assist", aim_assist)), 0, 2)
