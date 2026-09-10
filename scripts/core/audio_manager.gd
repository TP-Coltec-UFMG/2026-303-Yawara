extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE := 6

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    music_player = AudioStreamPlayer.new()
    music_player.bus = "Music"
    add_child(music_player)
    for _i in range(SFX_POOL_SIZE):
        var player := AudioStreamPlayer.new()
        player.bus = "SFX"
        add_child(player)
        sfx_players.append(player)

func _load_if_exists(path: String) -> AudioStream:
    if ResourceLoader.exists(path):
        return load(path) as AudioStream
    return null

func play_music(file_name: String) -> void:
    var stream := _load_if_exists("res://assets/audio/" + file_name)
    if stream == null:
        return
    if music_player.stream == stream and music_player.playing:
        return
    music_player.stream = stream
    music_player.play()

func stop_music() -> void:
    if is_instance_valid(music_player):
        music_player.stop()

func play_sfx(file_name: String) -> void:
    var stream := _load_if_exists("res://assets/audio/" + file_name)
    if stream == null:
        return
    var target: AudioStreamPlayer = null
    for player in sfx_players:
        if not player.playing:
            target = player
            break
    if target == null and not sfx_players.is_empty():
        target = sfx_players[0]
    if target != null:
        target.stream = stream
        target.play()
