class_name HealthComponent
extends Node

signal health_changed(current: float, maximum: float)
signal died

@export var max_health: float = 100.0
var current_health: float

func _ready() -> void:
    current_health = max_health
    health_changed.emit(current_health, max_health)

func setup(value: float) -> void:
    max_health = value
    current_health = value
    health_changed.emit(current_health, max_health)

func damage(amount: float) -> void:
    if current_health <= 0.0:
        return
    current_health = maxf(0.0, current_health - amount)
    health_changed.emit(current_health, max_health)
    if current_health <= 0.0:
        died.emit()

func heal(amount: float) -> void:
    if current_health <= 0.0:
        return
    current_health = minf(max_health, current_health + amount)
    health_changed.emit(current_health, max_health)

func increase_max(amount: float, heal_bonus: float = 0.0) -> void:
    max_health += amount
    current_health = minf(max_health, current_health + heal_bonus)
    health_changed.emit(current_health, max_health)

func ratio() -> float:
    if max_health <= 0.0:
        return 0.0
    return current_health / max_health
