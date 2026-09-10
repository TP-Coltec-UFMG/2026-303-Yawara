extends Node

# Quatro biomas funcionais. Eles condensam as cinco regioes brasileiras sem
# perder os cinco guardioes: Mata Atlantica e Amazonia compartilham o bioma de
# floresta, enquanto Yawara permanece o sexto chefe e encerra a run.
const BIOMES := [
    {"id":0,"name":"Grande Floresta","biome":"Amazonia e Mata Atlantica","short":"GRANDE FLORESTA","ground":Color("#173f31"),"accent":Color("#2c7750"),"detail":Color("#8fbd70"),"tree_kind":"amazon_tree","fruit":"acai e jabuticaba","food_asset":"acai","lake_chance":0.28,"base_terrain":1.0,"climate":"rain","miniboss_pool":["mapinguari","corpo_seco"]},
    {"id":1,"name":"Sertao de Pedra","biome":"Caatinga","short":"CAATINGA","ground":Color("#705029"),"accent":Color("#aa7734"),"detail":Color("#d5b45a"),"tree_kind":"caatinga_tree","fruit":"umbu","food_asset":"umbu","lake_chance":0.07,"base_terrain":0.91,"climate":"heatwave","miniboss_pool":["cabra_cabriola"]},
    {"id":2,"name":"Aguas do Pantanal","biome":"Pantanal e Cerrado","short":"PANTANAL","ground":Color("#445129"),"accent":Color("#71863a"),"detail":Color("#a6aa53"),"tree_kind":"cerrado_tree","fruit":"pequi","food_asset":"pequi","lake_chance":0.58,"base_terrain":0.87,"climate":"soak","miniboss_pool":["minhocao"]},
    {"id":3,"name":"Campos de Geada","biome":"Pampas e Araucarias","short":"PAMPAS GELADOS","ground":Color("#2b4335"),"accent":Color("#54715a"),"detail":Color("#b6c9d4"),"tree_kind":"araucaria","fruit":"pinhao","food_asset":"pinhao","lake_chance":0.15,"base_terrain":0.96,"climate":"blizzard","miniboss_pool":["teiniagua"]}
]

const MINIBOSSES := {
    "mapinguari":{"name":"Mapinguari Ancestral","biome":0,"power":"Coracao do Mapinguari","power_desc":"Regeneracao forte, imunidade a veneno e maior alcance de alimentacao.","pattern":"poison"},
    "corpo_seco":{"name":"Corpo-Seco da Serra","biome":0,"power":"Casca da Serra","power_desc":"Resistencia, Size e impacto corpo a corpo.","pattern":"roots"},
    "cabra_cabriola":{"name":"Cabra Cabriola","biome":1,"power":"Sol do Sertao","power_desc":"Imunidade ao calor e rajadas de fogo nos ataques.","pattern":"fire"},
    "minhocao":{"name":"Minhocao do Pantanal","biome":2,"power":"Passo do Pantanal","power_desc":"Ignora agua/lama e o dash cria onda de impacto.","pattern":"wave"},
    "teiniagua":{"name":"Teiniagua Corrompida","biome":3,"power":"Brasa da Teiniagua","power_desc":"Imunidade ao frio e terceiro ataque libera espiritos.","pattern":"spirits"}
}

# As 12 familias regulares possuem linhas +/++ e mudancas mecanicas reais.
const FAMILIES := {
    "marimbondo_onca":{"name":"Marimbondo-Onca","temperament":"predator","diet":"carnivore","size":0.68,"speed":178.0,"hp":20.0,"damage":10.0,"xp":5,"friend":18.0,"mechanic":"flying_dash","biomes":[0,1],"evolutions":[{"suffix":"+","hp":35.0,"damage":18.0,"mechanic":"poison_cloud"}]},
    "minhocao_areia":{"name":"Minhocao-da-Areia","temperament":"predator","diet":"carnivore","size":1.12,"speed":145.0,"hp":45.0,"damage":17.0,"xp":9,"friend":22.0,"mechanic":"sand_ambush","biomes":[1],"evolutions":[{"suffix":"+","hp":65.0,"damage":25.0,"mechanic":"sand_ambush_fast"}]},
    "capivara_couracada":{"name":"Capivara Couracada","temperament":"passive","diet":"herbivore","size":1.32,"speed":82.0,"hp":130.0,"damage":20.0,"xp":13,"friend":11.0,"mechanic":"retaliate_tank","biomes":[2,3],"evolutions":[]},
    "onca_sombra":{"name":"Onca-das-Sombras","temperament":"predator","diet":"carnivore","size":0.98,"speed":185.0,"hp":30.0,"damage":15.0,"xp":10,"friend":21.0,"mechanic":"rush_flee","biomes":[0,3],"evolutions":[{"suffix":"+","hp":52.0,"damage":21.0,"mechanic":"rush_combo"}]},
    "furao_ladrao":{"name":"Furao-Ladrao","temperament":"neutral","diet":"omnivore","size":0.63,"speed":190.0,"hp":20.0,"damage":15.0,"xp":7,"friend":13.0,"mechanic":"thief","biomes":[0,1,3],"evolutions":[{"suffix":"+","hp":34.0,"damage":18.0,"mechanic":"stone_throw"},{"suffix":"++","hp":52.0,"damage":23.0,"mechanic":"creature_throw"}]},
    "sapo_aranha":{"name":"Sapo-Aranha","temperament":"territorial","diet":"insectivore","size":0.62,"speed":138.0,"hp":16.0,"damage":9.0,"xp":6,"friend":16.0,"mechanic":"tongue_stun","biomes":[0,2],"evolutions":[{"suffix":"+","hp":32.0,"damage":15.0,"mechanic":"tongue_fast"}]},
    "fruta_espinho":{"name":"Fruta-Espinho","temperament":"predator","diet":"carnivore","size":0.70,"speed":158.0,"hp":20.0,"damage":8.0,"xp":7,"friend":24.0,"mechanic":"mimic","biomes":[0,1],"evolutions":[{"suffix":"+","hp":36.0,"damage":15.0,"mechanic":"mimic_rush"},{"suffix":"++","hp":55.0,"damage":22.0,"mechanic":"mimic_burst"}]},
    "peixe_cuspidor":{"name":"Peixe-Cuspidor","temperament":"territorial","diet":"piscivore","size":0.66,"speed":168.0,"hp":17.0,"damage":9.0,"xp":7,"friend":17.0,"mechanic":"water_ranged","biomes":[2],"evolutions":[{"suffix":"+","hp":42.0,"damage":18.0,"mechanic":"amphibious_ranged"}]},
    "jabuti_ancestral":{"name":"Jabuti Ancestral","temperament":"passive","diet":"herbivore","size":0.82,"speed":72.0,"hp":20.0,"damage":15.0,"xp":8,"friend":10.0,"mechanic":"plated","plating":40.0,"biomes":[0,1,2],"evolutions":[{"suffix":"+","hp":38.0,"damage":19.0,"mechanic":"heavy_plating","plating":70.0}]},
    "peixe_boi_jovem":{"name":"Peixe-Boi Jovem","temperament":"prey","diet":"herbivore","size":0.88,"speed":88.0,"hp":18.0,"damage":0.1,"xp":4,"friend":7.0,"mechanic":"easy_prey","biomes":[2],"evolutions":[{"suffix":"+","hp":31.0,"damage":6.0,"mechanic":"poison_contact"}]},
    "coruja_oco":{"name":"Coruja-do-Oco","temperament":"prey","diet":"omnivore","size":0.58,"speed":150.0,"hp":22.0,"damage":0.1,"xp":5,"friend":9.0,"mechanic":"burrow_escape","biomes":[0,1,3],"evolutions":[{"suffix":"+","hp":35.0,"damage":4.0,"mechanic":"burrow_decoy"}]},
    "lebre_pampas":{"name":"Lebre-dos-Pampas","temperament":"prey","diet":"herbivore","size":0.52,"speed":222.0,"hp":10.0,"damage":0.1,"xp":5,"friend":8.0,"mechanic":"fast_prey","biomes":[3],"evolutions":[{"suffix":"+","hp":24.0,"damage":5.0,"mechanic":"zigzag"}]},

    # Fauna brasileira adicionada a partir das folhas de sprites fornecidas.
    # Estes animais usam sprites PNG recortados em assets/sprites/creatures/.
    "capivara_amazonica":{"name":"Capivara-amazonica","temperament":"passive","diet":"herbivore","size":1.08,"speed":92.0,"hp":72.0,"damage":7.0,"xp":7,"friend":7.0,"mechanic":"retaliate_tank","biomes":[0,2],"evolutions":[]},
    "ema":{"name":"Ema","temperament":"prey","diet":"omnivore","size":0.92,"speed":205.0,"hp":26.0,"damage":4.0,"xp":6,"friend":9.0,"mechanic":"zigzag","biomes":[1,2,3],"evolutions":[]},
    "mico_leao":{"name":"Mico-leao-dourado","temperament":"prey","diet":"omnivore","size":0.48,"speed":172.0,"hp":18.0,"damage":3.0,"xp":5,"friend":6.0,"mechanic":"fast_prey","biomes":[0],"evolutions":[]},
    "quero_quero":{"name":"Quero-quero","temperament":"territorial","diet":"omnivore","size":0.52,"speed":162.0,"hp":22.0,"damage":8.0,"xp":5,"friend":12.0,"mechanic":"flying_dash","biomes":[2,3],"evolutions":[]},
    "arara":{"name":"Arara","temperament":"prey","diet":"herbivore","size":0.58,"speed":185.0,"hp":20.0,"damage":3.0,"xp":5,"friend":7.0,"mechanic":"flying_dash","biomes":[0],"evolutions":[]},
    "tatu_peba":{"name":"Tatu-peba","temperament":"passive","diet":"omnivore","size":0.62,"speed":95.0,"hp":58.0,"damage":7.0,"xp":6,"friend":8.0,"mechanic":"plated","plating":24.0,"biomes":[1,2],"evolutions":[]},
    "capivara_pantanal":{"name":"Capivara do Pantanal","temperament":"passive","diet":"herbivore","size":1.18,"speed":88.0,"hp":92.0,"damage":8.0,"xp":8,"friend":6.0,"mechanic":"retaliate_tank","biomes":[2],"evolutions":[]},
    "paca":{"name":"Paca","temperament":"prey","diet":"herbivore","size":0.66,"speed":155.0,"hp":24.0,"damage":2.0,"xp":5,"friend":7.0,"mechanic":"fast_prey","biomes":[0,2],"evolutions":[]},
    "graxaim":{"name":"Graxaim","temperament":"predator","diet":"carnivore","size":0.72,"speed":174.0,"hp":34.0,"damage":11.0,"xp":8,"friend":15.0,"mechanic":"rush_flee","biomes":[3],"evolutions":[]},
    "queixada":{"name":"Queixada","temperament":"territorial","diet":"omnivore","size":0.84,"speed":132.0,"hp":62.0,"damage":13.0,"xp":9,"friend":15.0,"mechanic":"rush_combo","biomes":[0,1,2],"evolutions":[]},
    "carcara":{"name":"Carcara","temperament":"predator","diet":"carnivore","size":0.60,"speed":180.0,"hp":24.0,"damage":10.0,"xp":7,"friend":17.0,"mechanic":"flying_dash","biomes":[1,2],"evolutions":[]},
    "tamandua_bandeira":{"name":"Tamandua-bandeira","temperament":"territorial","diet":"insectivore","size":1.05,"speed":102.0,"hp":74.0,"damage":14.0,"xp":10,"friend":13.0,"mechanic":"retaliate_tank","biomes":[0,2],"evolutions":[]},
    "quati":{"name":"Quati","temperament":"neutral","diet":"omnivore","size":0.62,"speed":155.0,"hp":30.0,"damage":7.0,"xp":6,"friend":9.0,"mechanic":"thief","biomes":[0,2],"evolutions":[]},
    "veado_campeiro":{"name":"Veado-campeiro","temperament":"prey","diet":"herbivore","size":0.88,"speed":198.0,"hp":34.0,"damage":3.0,"xp":7,"friend":8.0,"mechanic":"zigzag","biomes":[2,3],"evolutions":[]},
    "onca_corrompida":{"name":"Onca-pintada Corrompida","temperament":"predator","diet":"carnivore","size":1.02,"speed":188.0,"hp":60.0,"damage":18.0,"xp":13,"friend":26.0,"mechanic":"rush_combo","biomes":[0,2],"evolutions":[]},
    "gato_mato":{"name":"Gato-do-mato","temperament":"predator","diet":"carnivore","size":0.62,"speed":184.0,"hp":28.0,"damage":10.0,"xp":7,"friend":16.0,"mechanic":"rush_flee","biomes":[0,3],"evolutions":[]},
    "lobo_guara":{"name":"Lobo-guara","temperament":"predator","diet":"omnivore","size":0.86,"speed":190.0,"hp":42.0,"damage":13.0,"xp":10,"friend":17.0,"mechanic":"rush_flee","biomes":[1,2,3],"evolutions":[]},
    "jaguatirica_corrompida":{"name":"Jaguatirica Corrompida","temperament":"predator","diet":"carnivore","size":0.72,"speed":196.0,"hp":44.0,"damage":15.0,"xp":11,"friend":23.0,"mechanic":"rush_combo","biomes":[0,2],"evolutions":[]},
    "bugio":{"name":"Bugio","temperament":"territorial","diet":"herbivore","size":0.78,"speed":122.0,"hp":46.0,"damage":10.0,"xp":8,"friend":10.0,"mechanic":"stone_throw","biomes":[0],"evolutions":[]}
}

const BOSS_ADDS := {
    "curumim_corrompido":{"name":"Curumim Corrompido","hp":10.0,"damage":6.0,"speed":165.0},
    "raiz_yawara":{"name":"Raiz de Yawara","hp":28.0,"damage":12.0,"speed":0.0}
}

const POIS := {
    "algae_reef":{"name":"Recife de Vitoria-Regia","effect":"+7 PV Max ou +1 Ability"},
    "carved_tree":{"name":"Tronco Entalhado","effect":"Progress completo ou +1 Physical"},
    "chaos_tree":{"name":"Arvore dos Encantados","effect":"Atributo alto aleatorio ou +5 Mutagen"},
    "frozen_specimen":{"name":"Encantado Congelado","effect":"Aliado ou Evolution por Mutagen"},
    "giant_mushroom":{"name":"Cogumelo Gigante","effect":"Melhora alimentos raros"},
    "growing_tree":{"name":"Jequitiba Crescente","effect":"Dano ou atributos"},
    "healing_pond":{"name":"Poco de Cura","effect":"Cura 50% ou +1 regeneracao"},
    "lotus_plant":{"name":"Vitoria-Regia Lunar","effect":"Progress ou cooldown"},
    "mud_pond":{"name":"Barreiro da Capivara","effect":"Adaptacao ou Social"},
    "oasis":{"name":"Oasis do Sertao","effect":"Cura total ou regeneracao"},
    "sun_dial":{"name":"Relogio do Saci","effect":"Altera dia e noite"},
    "unattended_nest":{"name":"Ninho Abandonado","effect":"Comida, Social ou defesa"},
    "bramble":{"name":"Espinheiro do Curupira","effect":"Perigo ambiental"},
    "boss_area":{"name":"Clareira do Guardiao","effect":"Arena de chefe"}
}

const ENCOUNTER_NAMES := {
    "community":["Roda de Fogueira","Vila de Passagem","Casa de Farinha"],
    "shrine":["Santuario Ancestral","Marco de Pedra","Altar de Raizes"],
    "natural":["Ninho Protegido","Refugio de Animais","Clareira Silenciosa"]
}

func get_biome(index: int) -> Dictionary:
    return BIOMES[clampi(index, 0, BIOMES.size() - 1)]

func get_creature_pool(index: int) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    var safe_index := clampi(index, 0, BIOMES.size() - 1)
    for id_value in FAMILIES:
        var family: Dictionary = FAMILIES[id_value].duplicate(true)
        if safe_index in family["biomes"]:
            family["id"] = String(id_value)
            result.append(family)
    return result

func random_creature(index: int, rng: RandomNumberGenerator) -> Dictionary:
    var pool := get_creature_pool(index)
    if pool.is_empty(): return {}
    var weighted: Array[Dictionary] = []
    for family in pool:
        var temperament := String(family["temperament"])
        var repeats := 5 if temperament in ["prey", "passive"] else (3 if temperament in ["neutral", "territorial"] else 2)
        for _i in range(repeats): weighted.append(family)
    return weighted[rng.randi_range(0, weighted.size() - 1)].duplicate(true)

func get_miniboss(boss_id: String) -> Dictionary:
    return MINIBOSSES.get(boss_id, MINIBOSSES["mapinguari"])

func choose_miniboss_for_biome(index: int, excluded: Dictionary = {}) -> String:
    var pool: Array = get_biome(index)["miniboss_pool"]
    var available: Array[String] = []
    for id_value in pool:
        var id := String(id_value)
        if not excluded.has(id): available.append(id)
    if available.is_empty():
        for id_value in MINIBOSSES:
            if int(MINIBOSSES[id_value]["biome"]) == index: available.append(String(id_value))
    if available.is_empty(): return String(pool[0])
    available.shuffle()
    return available[0]
