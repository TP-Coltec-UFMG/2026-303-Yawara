class_name FruitPickup
extends Area2D

const RARITY_NAMES: Array[String] = ["", "Comum", "Rara", "Epica", "Lendaria"]

var fruit_name := "fruta"
var biome_index := 0
var food_value := 1
var life := 120.0
var player: Node2D
var bites_taken := 0
var bite_timer := 0.0
var feeding := false
var player_in_range := false
var active_target := false
var rejected_by_diet := false
var asset_name := ""
var base_sprite_scale := Vector2.ONE

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    add_to_group("food")
    collision_layer = 0
    collision_mask = 0
    queue_redraw()

func configure(name_value: String, biome: int, value: int = 1) -> void:
    fruit_name = name_value
    biome_index = clampi(biome, 0, BiomeDB.BIOMES.size() - 1)
    food_value = clampi(value, 1, 4)
    var biome_data: Dictionary = BiomeDB.get_biome(biome_index)
    asset_name = String(biome_data["food_asset"])
    if fruit_name == "carne":
        asset_name = "meat"
    elif fruit_name == "fruto ancestral":
        asset_name = "ancestral_fruit"
    var path := "res://assets/sprites/food/%s.png" % asset_name
    if ResourceLoader.exists(path):
        sprite.texture = load(path) as Texture2D
        var max_side := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
        var target := 22.0 + float(maxi(0, food_value - 1)) * 4.0
        sprite.scale = Vector2.ONE * (target / maxf(1.0, max_side))
        base_sprite_scale = sprite.scale
    queue_redraw()

func _physics_process(delta: float) -> void:
    life -= delta
    if life <= 0.0:
        queue_free()
        return
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node2D
        player_in_range = false
        queue_redraw()
        return

    var consume_distance := 72.0
    if player.has_method("get_consumption_radius"):
        consume_distance = float(player.call("get_consumption_radius"))
    var was_in_range := player_in_range
    var was_active_target := active_target
    player_in_range = global_position.distance_to(player.global_position) <= consume_distance
    var diet_accepts := not player.has_method("can_eat_food") or bool(player.call("can_eat_food", fruit_name))
    var is_active_food := player_in_range and diet_accepts and _is_closest_food_to_player()
    active_target = is_active_food
    if not is_active_food:
        feeding = false
        bite_timer = 0.0
        if not player_in_range:
            rejected_by_diet = false
    elif rejected_by_diet:
        feeding = false
    elif not feeding:
        # A primeira mordida acontece automaticamente ao entrar na area.
        feeding = true
        if _take_bite(player):
            bite_timer = _feeding_interval(player)
    else:
        # As mordidas seguintes continuam respeitando Consumption Speed.
        bite_timer -= delta
        if bite_timer <= 0.0:
            if _take_bite(player):
                bite_timer = _feeding_interval(player)
    if was_in_range != player_in_range or was_active_target != active_target or feeding:
        queue_redraw()

func _is_closest_food_to_player() -> bool:
    # Impede que duas frutas sobrepostas sejam comidas ao mesmo tempo.
    var my_distance := global_position.distance_squared_to(player.global_position)
    for candidate in get_tree().get_nodes_in_group("food"):
        if candidate == self or not is_instance_valid(candidate) or not (candidate is Node2D):
            continue
        var candidate_food_name := String(candidate.get("fruit_name"))
        if player.has_method("can_eat_food") and not bool(player.call("can_eat_food", candidate_food_name)):
            continue
        var other := candidate as Node2D
        var other_distance := other.global_position.distance_squared_to(player.global_position)
        if other_distance + 0.01 < my_distance:
            return false
    return true

func _feeding_interval(body: Node) -> float:
    if body.has_method("get_feeding_interval"):
        return float(body.call("get_feeding_interval"))
    return 0.5

func _take_bite(body: Node) -> bool:
    if is_queued_for_deletion() or not body.has_method("consume_food_bite"):
        return false
    var bites_required := 1 if fruit_name == "fruto ancestral" else 4
    var next_bite := bites_taken + 1
    var is_final := next_bite >= bites_required
    var accepted := bool(body.call("consume_food_bite", fruit_name, biome_index, food_value, next_bite, is_final))
    if not accepted:
        feeding = false
        rejected_by_diet = true
        return false
    bites_taken = next_bite
    _update_bite_visual()
    if is_final:
        queue_free()
    return true

func _update_bite_visual() -> void:
    # Se existirem artes por mordida, elas sao usadas automaticamente.
    var bite_path := "res://assets/sprites/food/%s_bite_%d.png" % [asset_name, bites_taken]
    if ResourceLoader.exists(bite_path):
        sprite.texture = load(bite_path) as Texture2D
        sprite.scale = base_sprite_scale
        sprite.modulate = Color.WHITE
    elif sprite.texture != null:
        # Fallback visivel enquanto os frames definitivos nao forem desenhados.
        var remaining := maxf(0.46, 1.0 - float(bites_taken) * 0.17)
        sprite.scale = base_sprite_scale * remaining
        sprite.modulate = Color.WHITE.darkened(float(bites_taken) * 0.07)
    queue_redraw()

func consume_by_creature() -> bool:
    if is_queued_for_deletion():
        return false
    queue_free()
    return true

func _draw() -> void:
    if sprite.texture == null:
        var colors: Array[Color] = [Color("#7c2d63"), Color("#8eb64a"), Color("#d7a229"), Color("#b78c4a")]
        var color: Color = Color("#a94d45") if fruit_name == "carne" else colors[biome_index]
        var remaining := maxf(0.46, 1.0 - float(bites_taken) * 0.17)
        var radius := (8.0 + float(food_value) * 1.6) * remaining
        if food_value >= 2:
            draw_circle(Vector2.ZERO, radius + 4.0, Color(1.0, 0.96, 0.62, 0.16))
        draw_circle(Vector2.ZERO, radius, color)
        draw_circle(Vector2(-2.0, -2.0), 2.0, color.lightened(0.45))
    elif food_value >= 2:
        draw_circle(Vector2.ZERO, 12.0 + float(food_value), Color(1.0, 0.96, 0.62, 0.18))

    if food_value >= 2:
        draw_string(ThemeDB.fallback_font, Vector2(-4.0, -15.0), "★", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color("#ffe28a"))
    if not active_target:
        return
    var bites_required := 1 if fruit_name == "fruto ancestral" else 4
    var pips := ""
    for index in range(bites_required):
        pips += "●" if index < bites_taken else "○"
    var rarity_name: String = RARITY_NAMES[food_value]
    var prompt := "COMENDO • %s • %s  %s" % [fruit_name.capitalize(), rarity_name, pips]
    draw_rect(Rect2(-95.0, -45.0, 190.0, 24.0), Color(0.08, 0.05, 0.03, 0.84), true)
    draw_string(ThemeDB.fallback_font, Vector2(-89.0, -28.0), prompt, HORIZONTAL_ALIGNMENT_CENTER, 178.0, 12, Color("#fff0bd"))
