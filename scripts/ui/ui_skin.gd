# Identidade visual de Yawara: verde de mata, creme e detalhes dourados.
# Tema aplicado a menus, caixas de diálogo e interfaces de combate.
# O alto contraste permanece controlado por SettingsManager.
class_name YawaraSkin
extends RefCounted

static func _panel(color: Color, edge: Color, radius: int = 13, border: int = 2) -> StyleBoxFlat:
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = color
    style.border_color = edge
    style.set_border_width_all(border)
    style.set_corner_radius_all(radius)
    style.content_margin_left = 16.0
    style.content_margin_right = 16.0
    style.content_margin_top = 10.0
    style.content_margin_bottom = 10.0
    style.shadow_color = Color("#12291f", 0.30)
    style.shadow_size = 5
    style.shadow_offset = Vector2(0.0, 3.0)
    return style

static func apply(root: Control) -> void:
    var skin: Theme = Theme.new()
    skin.default_font_size = 17

    skin.set_color("font_color", "Label", Color("#fff1d8"))
    skin.set_color("font_shadow_color", "Label", Color(0.06, 0.09, 0.06, 0.45))
    skin.set_constant("shadow_offset_x", "Label", 1)
    skin.set_constant("shadow_offset_y", "Label", 1)

    skin.set_color("font_color", "Button", Color("#fff4d9"))
    skin.set_color("font_hover_color", "Button", Color("#fffaf0"))
    skin.set_color("font_pressed_color", "Button", Color("#fff7df"))
    skin.set_color("font_focus_color", "Button", Color("#fffaf0"))
    skin.set_color("font_disabled_color", "Button", Color("#9dac99"))
    skin.set_font_size("font_size", "Button", 18)
    # Botões translúcidos: mostram a arte atrás sem sacrificar o contraste.
    skin.set_stylebox("normal", "Button", _panel(Color(0.06, 0.14, 0.10, 0.14), Color(0.95, 0.88, 0.68, 0.55), 12, 1))
    skin.set_stylebox("hover", "Button", _panel(Color(0.16, 0.34, 0.25, 0.52), Color("#f4d997"), 12, 2))
    skin.set_stylebox("pressed", "Button", _panel(Color(0.33, 0.48, 0.32, 0.68), Color("#fff0ba"), 12, 2))
    skin.set_stylebox("disabled", "Button", _panel(Color(0.14, 0.19, 0.15, 0.16), Color(0.50, 0.58, 0.47, 0.35), 12, 1))
    skin.set_stylebox("focus", "Button", _panel(Color(0, 0, 0, 0), Color("#ffe4a0"), 14, 3))

    skin.set_color("font_color", "OptionButton", Color("#fff4df"))
    skin.set_color("font_hover_color", "OptionButton", Color.WHITE)
    skin.set_stylebox("normal", "OptionButton", _panel(Color("#385e46"), Color("#b8ce9e"), 12, 2))
    skin.set_stylebox("hover", "OptionButton", _panel(Color("#5a8260"), Color("#f5d98f"), 12, 2))
    skin.set_stylebox("pressed", "OptionButton", _panel(Color("#557f5c"), Color("#f5d98f"), 12, 2))
    skin.set_stylebox("focus", "OptionButton", _panel(Color(0, 0, 0, 0), Color("#ffe4a0"), 12, 2))

    skin.set_stylebox("panel", "PanelContainer", _panel(Color("#273f31", 0.97), Color("#e4c389"), 17, 2))
    skin.set_stylebox("panel", "Panel", _panel(Color("#273f31", 0.97), Color("#e4c389"), 17, 2))
    skin.set_stylebox("background", "ProgressBar", _panel(Color("#1c3229"), Color("#829e77"), 7, 1))
    skin.set_stylebox("fill", "ProgressBar", _panel(Color("#8dc58e"), Color("#b7dfa0"), 7, 0))
    skin.set_color("font_color", "CheckButton", Color("#fff4df"))
    skin.set_color("font_color", "CheckBox", Color("#fff4df"))
    skin.set_color("font_color", "SpinBox", Color("#fff4df"))
    skin.set_color("font_color", "LineEdit", Color("#fff4df"))
    skin.set_stylebox("normal", "LineEdit", _panel(Color("#345340"), Color("#acc597"), 10, 2))
    skin.set_stylebox("focus", "LineEdit", _panel(Color("#416a4d"), Color("#efcf87"), 10, 2))
    root.theme = skin
