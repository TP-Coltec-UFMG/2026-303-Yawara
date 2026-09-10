class_name GameProjectile
extends Area2D

var direction := Vector2.RIGHT
var speed := 500.0
var damage := 10.0
var life := 4.0
var targets_player := false
var radius := 7.0
var tint := Color("#f4ce65")
var effect_id := ""
var max_hits := 1
var hit_count := 0
var hit_bodies: Dictionary = {}
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    queue_redraw()

func configure(dir: Vector2, new_speed: float, new_damage: float, hits_player: bool, new_radius: float = 7.0, new_effect_id: String = "", new_max_hits: int = 1) -> void:
    direction = dir.normalized()
    speed = new_speed
    damage = new_damage
    targets_player = hits_player
    radius = new_radius
    effect_id = new_effect_id
    max_hits = maxi(1, new_max_hits)
    collision_mask = 1 if targets_player else 2
    tint = Color("#d65252") if targets_player else Color("#f4ce65")
    if effect_id == "slow":
        tint = Color("#7cc7df")
        radius = maxf(radius, 8.0)
    elif effect_id == "burn":
        tint = Color("#f27635")
    elif effect_id == "poison":
        tint = Color("#9ccc52")
    var sprite_path := "res://assets/sprites/effects/projectile_yawara.png" if targets_player else "res://assets/sprites/effects/projectile_player.png"
    if ResourceLoader.exists(sprite_path):
        sprite.texture = load(sprite_path) as Texture2D
        var max_side := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
        sprite.scale = Vector2.ONE * ((radius * 2.4) / maxf(1.0, max_side))
    $CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
    var shape := $CollisionShape2D.shape as CircleShape2D
    shape.radius = radius
    queue_redraw()

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta
    life -= delta
    if life <= 0.0:
        queue_free()

func _on_body_entered(body: Node) -> void:
    if hit_bodies.has(body):
        return
    if targets_player and body is Player:
        hit_bodies[body] = true
        if effect_id == "poison":
            body.take_poison_damage(damage)
        else:
            body.take_damage(damage)
        queue_free()
    elif not targets_player and body.is_in_group("enemies"):
        hit_bodies[body] = true
        if body.has_method("take_damage"):
            body.take_damage(damage)
        if effect_id == "slow" and body.has_method("apply_slow"):
            body.apply_slow(0.52, 2.4)
        hit_count += 1
        if hit_count >= max_hits:
            queue_free()

func _draw() -> void:
    if sprite.texture != null:
        return
    draw_circle(Vector2.ZERO, radius, tint)
    draw_circle(Vector2.ZERO, radius * 0.45, Color.WHITE)
