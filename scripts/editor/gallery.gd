@tool
extends Node2D

func _enter_tree() -> void:
    if Engine.is_editor_hint():
        return
    _disable_gameplay(self)

func _disable_gameplay(node: Node) -> void:
    for child in node.get_children():
        _disable_gameplay(child)
        child.set_script(null)
        if child is Camera2D and child.name != "PreviewCamera":
            child.enabled = false
