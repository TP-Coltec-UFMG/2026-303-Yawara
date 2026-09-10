extends Node

# Os 51 atributos internos ficam centralizados aqui. A interface mostra apenas
# os mais legiveis; os demais continuam disponiveis para evolucoes e Genetics.
const STAT_NAMES := [
    "max_health", "health_regeneration", "plating", "max_plating", "physical",
    "ability", "social", "speed", "size", "attack_area", "attack_cooldown",
    "dash_distance", "dash_cooldown", "dodge_chance", "damage_reduction",
    "poison_damage_multiplier", "extra_poison_ticks", "poison_tick_speed",
    "poison_reduction", "heat_reduction", "cold_reduction", "soak_reduction",
    "terrain_adaptation", "feeding_speed", "feeding_distance", "food_progress",
    "progress_gain", "mutagen_gain", "rarity_luck", "critical_chance",
    "critical_multiplier", "senses", "charm_chance", "ally_limit", "ally_damage",
    "ally_speed", "burrow_duration", "day_damage", "night_damage",
    "projectile_speed", "projectile_count", "knockback", "stun_power",
    "stun_resistance", "cooldown_reduction", "attack_slots", "ultimate_slots",
    "dash_slots", "boss_damage", "alpha_damage", "environmental_resistance"
]

const DEFAULTS := {
    "max_health": 140.0, "health_regeneration": 0.0, "plating": 0.0,
    "max_plating": 0.0, "physical": 24.0, "ability": 10.0, "social": 10.0,
    "speed": 280.0, "size": 0.82, "attack_area": 72.0,
    "attack_cooldown": 0.48, "dash_distance": 121.6, "dash_cooldown": 1.15,
    "dodge_chance": 0.0, "damage_reduction": 0.0,
    "poison_damage_multiplier": 1.0, "extra_poison_ticks": 0.0,
    "poison_tick_speed": 1.0, "poison_reduction": 0.0, "heat_reduction": 0.0,
    "cold_reduction": 0.0, "soak_reduction": 0.0, "terrain_adaptation": 1.0,
    "feeding_speed": 1.0, "feeding_distance": 1.0, "food_progress": 1.0,
    "progress_gain": 1.0, "mutagen_gain": 1.0, "rarity_luck": 0.0,
    "critical_chance": 0.05, "critical_multiplier": 1.8, "senses": 1.0,
    "charm_chance": 0.0, "ally_limit": 4.0, "ally_damage": 1.0,
    "ally_speed": 1.0, "burrow_duration": 4.0, "day_damage": 1.0,
    "night_damage": 1.0, "projectile_speed": 1.0, "projectile_count": 1.0,
    "knockback": 1.0, "stun_power": 1.0, "stun_resistance": 0.0,
    "cooldown_reduction": 0.0, "attack_slots": 2.0, "ultimate_slots": 1.0,
    "dash_slots": 1.0, "boss_damage": 1.0, "alpha_damage": 1.0,
    "environmental_resistance": 0.0
}

func make_defaults() -> Dictionary:
    return DEFAULTS.duplicate(true)

func validate(stats: Dictionary) -> bool:
    if stats.size() != 51:
        return false
    for stat_name in STAT_NAMES:
        if not stats.has(stat_name):
            return false
    return true
