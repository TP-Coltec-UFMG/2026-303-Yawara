extends Node

const PREPARATION_SECONDS := 480.0
const FIRST_MINIBOSS_SECONDS := 180.0
const SECOND_MINIBOSS_SECONDS := 360.0
const FINAL_BOSS_SECONDS := 480.0
const BOSS_SECONDS := 120.0
const ENDLESS_BOSS_INTERVAL := 180.0

enum RunMode { NORMAL, PRESSURE, ENDLESS }

var elapsed := 0.0
var current_region := 0
var in_boss_fight := false
var run_finished := false
var run_mode := RunMode.NORMAL
var pressure_level := 0
var selected_genetic := "standard"
var selected_secondary_genetic := ""
var run_seed := 0

func reset_run() -> void:
    elapsed = 0.0
    current_region = 0
    in_boss_fight = false
    run_finished = false
    run_seed = int(Time.get_unix_time_from_system()) ^ int(Time.get_ticks_usec())

func configure_run(mode: int, pressure: int = 0, genetic: String = "standard", secondary: String = "") -> void:
    run_mode = mode
    pressure_level = clampi(pressure, 0, 20)
    selected_genetic = genetic if GeneticsDB.GENETICS.has(genetic) else "standard"
    selected_secondary_genetic = secondary if GeneticsDB.GENETICS.has(secondary) else ""

func pressure_multiplier(category: String) -> float:
    if run_mode == RunMode.NORMAL or pressure_level <= 0:
        return 1.0
    match category:
        "enemy_hp": return 1.0 + float(pressure_level) * 0.065
        "enemy_damage": return 1.0 + float(pressure_level) * 0.045
        "spawn": return 1.0 + float(pressure_level) * 0.035
        "progress": return 1.0 + float(pressure_level) * 0.028
        "environment": return 1.0 + float(pressure_level) * 0.035
        "alpha": return 1.0 + float(pressure_level) * 0.06
    return 1.0

func is_endless() -> bool:
    return run_mode == RunMode.ENDLESS

func next_scheduled_event() -> float:
    if elapsed < FIRST_MINIBOSS_SECONDS:
        return FIRST_MINIBOSS_SECONDS
    if elapsed < SECOND_MINIBOSS_SECONDS:
        return SECOND_MINIBOSS_SECONDS
    if elapsed < FINAL_BOSS_SECONDS:
        return FINAL_BOSS_SECONDS
    if is_endless():
        var cycles := floori((elapsed - FINAL_BOSS_SECONDS) / ENDLESS_BOSS_INTERVAL) + 1
        return FINAL_BOSS_SECONDS + float(cycles) * ENDLESS_BOSS_INTERVAL
    return FINAL_BOSS_SECONDS
