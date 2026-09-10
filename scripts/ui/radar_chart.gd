class_name RegionRadarChart
extends Control

const LABELS: Array[String] = ["PRED", "PRESA", "TRIQ", "IMP", "SOC"]
var values: Array[int] = [0, 0, 0, 0, 0]
var max_value := 25.0

func set_values(new_values: Array) -> void:
    values.clear()
    for value in new_values:
        values.append(int(value))
    while values.size() < LABELS.size():
        values.append(0)
    queue_redraw()

func _draw() -> void:
    var center := size * Vector2(0.50, 0.51)
    var radius := minf(size.x, size.y) * 0.34
    if radius <= 8.0:
        return

    for ring in range(1, 6):
        var ring_points := PackedVector2Array()
        for i in range(LABELS.size()):
            var angle := -PI / 2.0 + TAU * float(i) / float(LABELS.size())
            ring_points.append(center + Vector2.from_angle(angle) * radius * float(ring) / 5.0)
        ring_points.append(ring_points[0])
        draw_polyline(ring_points, Color(0.23, 0.12, 0.08, 0.46), 1.0)

    for i in range(LABELS.size()):
        var angle := -PI / 2.0 + TAU * float(i) / float(LABELS.size())
        var axis_end := center + Vector2.from_angle(angle) * radius
        draw_line(center, axis_end, Color(0.20, 0.10, 0.06, 0.66), 2.0)

    var polygon := PackedVector2Array()
    for i in range(LABELS.size()):
        var angle := -PI / 2.0 + TAU * float(i) / float(LABELS.size())
        var ratio := clampf(float(values[i]) / max_value, 0.0, 1.0)
        polygon.append(center + Vector2.from_angle(angle) * radius * ratio)
    if polygon.size() >= 3:
        draw_colored_polygon(polygon, Color(1.0, 0.96, 0.73, 0.62))
        var outline := polygon.duplicate()
        outline.append(polygon[0])
        draw_polyline(outline, Color("#fff3c7"), 2.0)

    for i in range(LABELS.size()):
        var angle := -PI / 2.0 + TAU * float(i) / float(LABELS.size())
        var label_pos := center + Vector2.from_angle(angle) * (radius + 25.0) - Vector2(28.0, -6.0)
        draw_string(ThemeDB.fallback_font, label_pos, "%s %d" % [LABELS[i], values[i]], HORIZONTAL_ALIGNMENT_CENTER, 56.0, 13, Color("#6e402d"))
