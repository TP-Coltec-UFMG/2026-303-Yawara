extends Node

const ORDER := ["claws", "spear", "blowgun", "boleadeira", "maraca"]

const WEAPONS := {
    "claws": {
        "name":"Garras da Onca Ancestral",
        "desc":"Golpe corpo a corpo amplo. Escala muito bem com tamanho e dano.",
        "type":"melee",
        "damage":1.00,
        "cooldown":1.00,
        "area":1.00
    },
    "spear": {
        "name":"Lanca dos Guardioes",
        "desc":"Golpe estreito e longo. Bom para criaturas grandes e lentas.",
        "type":"thrust",
        "damage":1.28,
        "cooldown":1.16,
        "area":0.72
    },
    "blowgun": {
        "name":"Sopro da Mata",
        "desc":"Projétil rápido e seguro. O dano depende mais de habilidade do que de tamanho.",
        "type":"projectile",
        "damage":0.72,
        "cooldown":0.70,
        "area":0.35
    },
    "boleadeira": {
        "name":"Laco do Vento Sul",
        "desc":"Projétil pesado que desacelera o alvo. Útil para controle e caça.",
        "type":"slow_projectile",
        "damage":0.92,
        "cooldown":1.34,
        "area":0.52
    },
    "maraca": {
        "name":"Maraca do Eclipse de Yawara",
        "desc":"Pulso em volta do jogador. Dano escala com Social e afinidades regionais.",
        "type":"social_pulse",
        "damage":0.62,
        "cooldown":1.45,
        "area":1.42
    }
}

func get_weapon(id: String) -> Dictionary:
    return WEAPONS.get(id, WEAPONS["claws"])

func get_weapon_name(id: String) -> String:
    return String(get_weapon(id)["name"])
