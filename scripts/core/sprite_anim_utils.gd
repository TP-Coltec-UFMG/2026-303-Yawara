extends RefCounted
class_name SpriteAnimUtils

static func _make_atlas(texture: Texture2D, region: Rect2) -> AtlasTexture:
    var atlas := AtlasTexture.new()
    atlas.atlas = texture
    atlas.region = region
    return atlas

static func create_directional_frames_from_separate_sheets(idle_tex: Texture2D, walk_tex: Texture2D, attack_tex: Texture2D, dead_tex: Texture2D = null, frame_size: Vector2i = Vector2i(16, 16), order: Array[String] = ["down", "left", "right", "up"]) -> SpriteFrames:
    var frames := SpriteFrames.new()
    var source_map := {
        "idle": idle_tex,
        "walk": walk_tex,
        "attack": attack_tex
    }
    for prefix in source_map.keys():
        var tex: Texture2D = source_map[prefix]
        if tex == null:
            continue
        for row in range(order.size()):
            var dir := String(order[row])
            var anim_name := "%s_%s" % [prefix, dir]
            frames.add_animation(anim_name)
            frames.set_animation_speed(anim_name, 7.0 if prefix == "idle" else (11.0 if prefix == "walk" else 15.0))
            frames.set_animation_loop(anim_name, prefix != "attack")
            for col in range(4):
                frames.add_frame(anim_name, _make_atlas(tex, Rect2(col * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y)))
    if dead_tex != null:
        frames.add_animation("dead")
        frames.set_animation_speed("dead", 7.0)
        frames.set_animation_loop("dead", false)
        var columns: int = maxi(1, int(dead_tex.get_width() / frame_size.x))
        for col in range(columns):
            frames.add_frame("dead", _make_atlas(dead_tex, Rect2(col * frame_size.x, 0, frame_size.x, frame_size.y)))
    return frames

static func create_grid4_frames(texture: Texture2D, frame_size: Vector2i = Vector2i(16, 16), order: Array[String] = ["down", "left", "right", "up"]) -> SpriteFrames:
    var frames := SpriteFrames.new()
    if texture == null:
        return frames
    for row in range(min(order.size(), int(texture.get_height() / frame_size.y))):
        var dir := String(order[row])
        for prefix in ["idle", "walk", "attack"]:
            var anim_name := "%s_%s" % [prefix, dir]
            frames.add_animation(anim_name)
            frames.set_animation_speed(anim_name, 7.0 if prefix == "idle" else (10.0 if prefix == "walk" else 13.0))
            frames.set_animation_loop(anim_name, prefix != "attack")
        var available_cols := int(texture.get_width() / frame_size.x)
        for col in range(min(4, available_cols)):
            var atlas := _make_atlas(texture, Rect2(col * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y))
            frames.add_frame("walk_%s" % dir, atlas)
            if col < 2:
                frames.add_frame("idle_%s" % dir, atlas)
            frames.add_frame("attack_%s" % dir, atlas)
    return frames

static func create_side_frames(texture: Texture2D, frame_size: Vector2i = Vector2i(16, 16), columns: int = 2) -> SpriteFrames:
    var frames := SpriteFrames.new()
    if texture == null:
        return frames
    for anim_name in ["idle_side", "walk_side", "attack_side"]:
        frames.add_animation(anim_name)
        frames.set_animation_speed(anim_name, 8.0 if anim_name == "idle_side" else (9.0 if anim_name == "walk_side" else 12.0))
        frames.set_animation_loop(anim_name, anim_name != "attack_side")
    var cols: int = mini(columns, maxi(1, int(texture.get_width() / frame_size.x)))
    for col in range(cols):
        var atlas := _make_atlas(texture, Rect2(col * frame_size.x, 0, frame_size.x, frame_size.y))
        if col == 0:
            frames.add_frame("idle_side", atlas)
        frames.add_frame("walk_side", atlas)
        frames.add_frame("attack_side", atlas)
    if frames.get_frame_count("idle_side") == 0:
        frames.add_frame("idle_side", _make_atlas(texture, Rect2(0, 0, frame_size.x, frame_size.y)))
    return frames

static func create_file_frames(paths: Array[String]) -> SpriteFrames:
    var frames := SpriteFrames.new()
    for anim_name in ["idle_side", "walk_side", "attack_side"]:
        frames.add_animation(anim_name)
        frames.set_animation_speed(anim_name, 5.0 if anim_name == "idle_side" else (8.0 if anim_name == "walk_side" else 12.0))
        frames.set_animation_loop(anim_name, anim_name != "attack_side")
    for path in paths:
        if not ResourceLoader.exists(path):
            continue
        var tex := load(path) as Texture2D
        frames.add_frame("walk_side", tex)
        frames.add_frame("attack_side", tex)
    if frames.get_frame_count("walk_side") == 0 and paths.size() > 0 and ResourceLoader.exists(paths[0]):
        var tex := load(paths[0]) as Texture2D
        frames.add_frame("walk_side", tex)
        frames.add_frame("attack_side", tex)
    if paths.size() > 0 and ResourceLoader.exists(paths[0]):
        var first := load(paths[0]) as Texture2D
        frames.add_frame("idle_side", first)
    return frames
