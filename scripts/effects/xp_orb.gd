class_name XPOrb
extends Area2D

var amount := 8
var player: Player
var speed := 0.0
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    add_to_group("xp_orb")
    body_entered.connect(_on_body_entered)
    player = get_tree().get_first_node_in_group("player") as Player
    var path := "res://assets/sprites/effects/essence.png"
    if ResourceLoader.exists(path):
        sprite.texture = load(path)
        var max_side := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
        sprite.scale = Vector2.ONE * (20.0 / maxf(1.0, max_side))
    queue_redraw()

func configure(value: int) -> void:
    amount = value

func _physics_process(delta: float) -> void:
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Player
        return
    var distance := global_position.distance_to(player.global_position)
    var attraction_distance := 175.0 * clampf(player.senses, 0.8, 2.0)
    if distance < attraction_distance:
        speed = minf(620.0, speed + 900.0 * delta)
        global_position += global_position.direction_to(player.global_position) * speed * delta

func _on_body_entered(body: Node) -> void:
    if body is Player:
        body.add_xp(amount)
        queue_free()

func _draw() -> void:
    if sprite.texture != null:
        return
    draw_circle(Vector2.ZERO, 7.0, Color("#80e8ff"))
    draw_circle(Vector2.ZERO, 3.0, Color.WHITE)
