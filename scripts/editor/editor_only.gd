@tool
extends Node2D
## Esta amostra serve para inspecionar arte e escala no editor.
## A partida usa o gerador procedural, com uma nova distribuição de terreno.
func _ready() -> void:
    visible = Engine.is_editor_hint()
    if not Engine.is_editor_hint():
        queue_free()
