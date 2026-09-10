extends Node

# Evoluções corporais e espirituais. A ideia é que tamanho, estilo de ataque,
# mobilidade e social possam puxar a criatura para builds bem diferentes.
const UPGRADES := [
    {"id":"damage", "name":"Marca de Yawara: Garras", "desc":"+20% de dano corpo a corpo e garras maiores.", "max":5},
    {"id":"attack_speed", "name":"Marca de Yawara: Redemoinho", "desc":"-12% de intervalo entre ataques e aura de vento.", "max":5},
    {"id":"vitality", "name":"Marca de Yawara: Vigor", "desc":"+30 PV, regeneracao e um pouco mais de Size.", "max":4},
    {"id":"speed", "name":"Marca de Yawara: Passos Invertidos", "desc":"+10% velocidade e adaptacao a terreno; corpo fica um pouco menor.", "max":4},
    {"id":"range", "name":"Marca de Yawara: Cauda Longa", "desc":"+18% alcance base e +Size; melhora distancia de consumo.", "max":4},
    {"id":"dash", "name":"Marca de Yawara: Asas Rubras", "desc":"Dash recarrega mais rapido, aumenta esquiva e reduz Size.", "max":4},
    {"id":"ancestral_shot", "name":"Marca de Yawara: Fogo-Fatuo", "desc":"Ataques fisicos soltam energia ancestral; melhora calor.", "max":3},
    {"id":"critical", "name":"Marca de Yawara: Instinto", "desc":"+8% critico, +Sentidos e leve aumento de dano.", "max":4},
    {"id":"heal_kill", "name":"Marca de Yawara: Canto das Aguas", "desc":"Cura ao derrotar inimigos; aumenta Social e consumo.", "max":3},
    {"id":"resistance", "name":"Marca de Yawara: Couro Petreo", "desc":"Resistencia alta, mais Size e menos esquiva.", "max":4},
    {"id":"social_charm", "name":"Marca de Yawara: Encanto", "desc":"+4 Social. Encontros e amizades ficam mais faceis.", "max":5},
    {"id":"tiny", "name":"Marca de Yawara: Corpo Miudo", "desc":"-10% Size, +esquiva, +velocidade e +recarga.", "max":4},
    {"id":"giant", "name":"Marca de Yawara: Corpo Colossal", "desc":"+12% Size, +dano, +PV e area.", "max":4},
    {"id":"forager", "name":"Marca de Yawara: Faro", "desc":"+Sentidos, alcance de consumo e Progress de alimentos/POIs.", "max":4},
    {"id":"adaptation", "name":"Marca de Yawara: Pele dos Biomas", "desc":"Melhora terreno, calor, frio e Soak.", "max":4}
]

# Catalogo ampliado de Evolutions. Todas usam nomes do universo de Yawara e
# alimentam os mesmos sistemas de Size, alimentacao, Social, clima e combate.
const EXTRA_UPGRADES := [
    {"id":"tail","name":"Cauda do Encantado","desc":"Branching: mobilidade e Social.","max":1,"effect":"social"},
    {"id":"legs","name":"Pernas do Curupira","desc":"Branching: libera saltos e passadas.","max":1,"effect":"speed"},
    {"id":"wings","name":"Asas da Arara Rubra","desc":"Branching: mobilidade e adaptacao.","max":1,"effect":"terrain"},
    {"id":"slithery","name":"Corpo de Sucuri","desc":"Branching: velocidade e terreno.","max":1,"effect":"terrain"},
    {"id":"tentacles","name":"Bracos da Iara","desc":"Branching: Ability e membros.","max":1,"effect":"ability"},
    {"id":"arms","name":"Bracos do Mapinguari","desc":"Branching: ataques de membros.","max":1,"effect":"physical"},
    {"id":"alpha","name":"Presenca Alpha","desc":"Branching: Size e Social.","max":1,"effect":"size"},
    {"id":"pollinator","name":"Polinizador da Mata","desc":"Branching: exploracao e mais POIs.","max":1,"effect":"poi"},
    {"id":"ruminant","name":"Ruminante do Cerrado","desc":"Branching: Progress passivo pela alimentacao.","max":1,"effect":"food"},
    {"id":"exoskeleton","name":"Couraca Ancestral","desc":"Branching defensivo de Plating e resistencia.","max":1,"effect":"plating"},
    {"id":"more_legs","name":"Muitas Pernas","desc":"Mais velocidade e recarga de dash.","max":5,"effect":"speed"},
    {"id":"hollow_bones","name":"Ossos da Arara","desc":"Menos Size e mais mobilidade.","max":5,"effect":"dodge"},
    {"id":"fin","name":"Nadadeira do Boto","desc":"Move-se melhor na agua e reduz Soak.","max":5,"effect":"terrain"},
    {"id":"slow_metabolism","name":"Metabolismo do Jabuti","desc":"Alimentos duram mais e rendem mais Progress.","max":5,"effect":"food"},
    {"id":"prehensile_tail","name":"Cauda Preensil","desc":"Alcance de alimentacao e interacao.","max":5,"effect":"feeding"},
    {"id":"stomach","name":"Estomago de Capivara","desc":"Mais Progress por alimento.","max":5,"effect":"food"},
    {"id":"saliva","name":"Saliva da Mata","desc":"Aumenta velocidade de alimentacao.","max":5,"effect":"feeding"},
    {"id":"herbivore","name":"Herbivoro dos Campos","desc":"Frutas e plantas rendem mais.","max":3,"effect":"food"},
    {"id":"carnivore","name":"Carnivoro da Onca","desc":"Dano Physical e comida animal.","max":3,"effect":"physical"},
    {"id":"piscivore","name":"Pescador do Pantanal","desc":"Ability e alimento aquatico.","max":3,"effect":"ability"},
    {"id":"omnivore","name":"Onivoro Brasileiro","desc":"Bonus equilibrado de alimentacao.","max":3,"effect":"food"},
    {"id":"vegan","name":"Pacto das Frutas","desc":"Estilo vegano: plantas rendem Social e Progress.","max":1,"effect":"vegan"},
    {"id":"scavenger","name":"Catador do Cerrado","desc":"Restos de cacadas rendem mais.","max":5,"effect":"food"},
    {"id":"chonky","name":"Corpo Robusto","desc":"Muito Max HP e Size.","max":5,"effect":"hp"},
    {"id":"reach","name":"Alcance do Tamandua","desc":"Mais area e distancia de ataque.","max":5,"effect":"area"},
    {"id":"muscular_tissue","name":"Musculos do Queixada","desc":"Mais Physical.","max":5,"effect":"physical"},
    {"id":"more_mass","name":"Massa do Minhocao","desc":"Size e impacto.","max":5,"effect":"size"},
    {"id":"elusive","name":"Vulto da Mata","desc":"Dodge e velocidade.","max":5,"effect":"dodge"},
    {"id":"smol","name":"Pequeno Encantado","desc":"Reduz Size e melhora recargas.","max":5,"effect":"small"},
    {"id":"ambush","name":"Emboscada da Onca","desc":"Primeiro golpe causa mais dano.","max":5,"effect":"critical"},
    {"id":"poisonous_saliva","name":"Saliva Venenosa","desc":"Ataques aplicam veneno.","max":5,"effect":"poison"},
    {"id":"revenge","name":"Vinganca do Corpo-Seco","desc":"Receber dano fortalece o proximo ataque.","max":5,"effect":"physical"},
    {"id":"poisonous_spores","name":"Esporos do Pantanal","desc":"Deixa veneno ao redor.","max":5,"effect":"poison"},
    {"id":"virulent","name":"Veneno Virulento","desc":"Mais ticks e dano de Poison.","max":5,"effect":"poison"},
    {"id":"aggressive","name":"Furia da Cabriola","desc":"Physical e velocidade de ataque.","max":5,"effect":"physical"},
    {"id":"cunning","name":"Astucia do Quati","desc":"Ability, critico e Mutagen.","max":5,"effect":"ability"},
    {"id":"plated","name":"Placas do Tatu","desc":"Adiciona Plating.","max":5,"effect":"plating"},
    {"id":"scales","name":"Escamas da Sucuri","desc":"Reducao de dano e Poison.","max":5,"effect":"resist"},
    {"id":"carapace","name":"Casco do Jabuti","desc":"Plating e resistencia.","max":5,"effect":"plating"},
    {"id":"fur","name":"Pelo do Guara","desc":"Protecao contra frio.","max":5,"effect":"cold"},
    {"id":"shell","name":"Concha da Iara","desc":"Defesa e adaptacao aquatica.","max":5,"effect":"resist"},
    {"id":"spines","name":"Espinhos da Caatinga","desc":"Contato devolve dano.","max":5,"effect":"physical"},
    {"id":"overwhelm","name":"Esmagamento Ancestral","desc":"Converte Plating em ofensiva.","max":5,"effect":"plating_attack"},
    {"id":"agile","name":"Agilidade do Mico","desc":"Speed e Dodge.","max":5,"effect":"dodge"},
    {"id":"dexterous","name":"Destreza do Saci","desc":"Recarga de ataques e dash.","max":5,"effect":"cooldown"},
    {"id":"more_eyes","name":"Olhos da Noite","desc":"Senses e critico.","max":5,"effect":"senses"},
    {"id":"shifty","name":"Passo Enganador","desc":"Dodge apos atacar.","max":5,"effect":"dodge"},
    {"id":"subcutaneous_fat","name":"Gordura da Capivara","desc":"Max HP e resistencia ao clima.","max":5,"effect":"hp"},
    {"id":"resistant","name":"Resistente do Sertao","desc":"Reducao geral de dano.","max":5,"effect":"resist"},
    {"id":"immune_system","name":"Imunidade da Floresta","desc":"Resiste Poison e ambiente.","max":5,"effect":"resist"},
    {"id":"impervious","name":"Pele Impermeavel","desc":"Resiste Soak e terreno aquatico.","max":5,"effect":"terrain"},
    {"id":"regenerative_tissue","name":"Tecido do Mapinguari","desc":"Regeneracao continua.","max":5,"effect":"regen"},
    {"id":"hump","name":"Corcova do Sertao","desc":"Reserva de alimento e PV.","max":5,"effect":"hp"},
    {"id":"robust","name":"Robusto como Pedra","desc":"Max HP e stun resistance.","max":5,"effect":"hp"},
    {"id":"pack","name":"Matilha do Guara","desc":"Aliados mais fortes.","max":5,"effect":"social"},
    {"id":"hyperkeratosis","name":"Couro Grosso","desc":"Defesa e Plating.","max":5,"effect":"plating"},
    {"id":"sturdy","name":"Firmeza do Jequitiba","desc":"Stun resistance e dano reduzido.","max":5,"effect":"resist"},
    {"id":"antennae","name":"Antenas do Marimbondo","desc":"Senses e alcance de coleta.","max":5,"effect":"senses"},
    {"id":"detachable_tail","name":"Cauda Descartavel","desc":"Evita um golpe grave periodicamente.","max":3,"effect":"dodge"},
    {"id":"tail_wag","name":"Abanar Amigavel","desc":"Social e Charm.","max":5,"effect":"social"},
    {"id":"whining","name":"Chamado da Matilha","desc":"Aliados se aproximam e protegem.","max":5,"effect":"social"},
    {"id":"commanding","name":"Voz de Comando","desc":"Aumenta limite e dano de aliados.","max":5,"effect":"social"},
    {"id":"cortex","name":"Cortex Desperto","desc":"Ability e cooldown.","max":5,"effect":"ability"},
    {"id":"synapse","name":"Sinapses do Encantado","desc":"Ability e projeteis mais rapidos.","max":5,"effect":"ability"},
    {"id":"snout","name":"Focinho Farejador","desc":"Feeding Distance e Senses.","max":5,"effect":"feeding"},
    {"id":"fungoid","name":"Corpo Fungico","desc":"Esporos e regeneracao.","max":5,"effect":"poison"},
    {"id":"outlier","name":"Fora do Ciclo","desc":"Melhora atributos menos desenvolvidos.","max":5,"effect":"balanced"},
    {"id":"convergent","name":"Evolucao Convergente","desc":"Afinidades ajudam outras arvores.","max":5,"effect":"balanced"},
    {"id":"resourceful","name":"Improviso Brasileiro","desc":"Mais Mutagen e recursos.","max":5,"effect":"mutagen"},
    {"id":"nomadic","name":"Nomade dos Biomas","desc":"Bonus ao trocar de bioma.","max":5,"effect":"terrain"},
    {"id":"diurnal","name":"Filho do Sol","desc":"Mais dano de dia.","max":5,"effect":"day"},
    {"id":"nocturnal","name":"Filho da Lua","desc":"Mais dano e Senses a noite.","max":5,"effect":"night"},
    {"id":"hibernation","name":"Sono do Inverno","desc":"Regenera parado no frio.","max":5,"effect":"regen"},
    {"id":"extremophile","name":"Extremofilo do Sertao","desc":"Grande resistencia ambiental.","max":5,"effect":"terrain"},
    {"id":"strength_numbers","name":"Forca da Roda","desc":"Cada aliado melhora dano e defesa.","max":5,"effect":"social"},
    {"id":"tracker","name":"Rastreador da Onca","desc":"Marca alvos e melhora perseguicao.","max":5,"effect":"senses"},
    {"id":"pedal_glands","name":"Trilha da Sucuri","desc":"Deixa rastro que desacelera perseguidores.","max":5,"effect":"terrain"},
    {"id":"fibroblasts","name":"Fibroblastos Ancestrais","desc":"Recupera ferimentos e Plating.","max":5,"effect":"regen"}
]

const ATTACK_UPGRADES := [
    {"id":"attack_beak","name":"Bico do Carcara","desc":"Ataque Physical rapido.","max":5,"effect":"unlock_attack"},
    {"id":"attack_claws","name":"Garras da Onca","desc":"Ataque Physical amplo.","max":5,"effect":"unlock_attack"},
    {"id":"attack_pincers","name":"Pincas do Uca","desc":"Ataque de membros forte.","max":5,"effect":"unlock_attack"},
    {"id":"attack_toe_beans","name":"Patas de Jaguatirica","desc":"Sequencia rapida de contato.","max":5,"effect":"unlock_attack"},
    {"id":"attack_jaws","name":"Mandibula do Queixada","desc":"Mordida Physical pesada.","max":5,"effect":"unlock_attack"},
    {"id":"attack_antlers","name":"Galhada do Campeiro","desc":"Investida que empurra.","max":5,"effect":"unlock_attack"},
    {"id":"attack_horns","name":"Chifres da Cabriola","desc":"Investida que ignora Plating.","max":5,"effect":"unlock_attack"},
    {"id":"attack_trunk","name":"Tromba do Guardiao","desc":"Golpe grande que usa o menor atributo ofensivo.","max":5,"effect":"unlock_attack"},
    {"id":"attack_leech","name":"Sanguessuga do Pantanal","desc":"Ability de curta distancia que cura 10% do dano.","max":5,"effect":"unlock_attack"},
    {"id":"attack_stinger","name":"Ferrao do Marimbondo","desc":"Physical com Poison por cinco segundos.","max":5,"effect":"unlock_attack"},
    {"id":"attack_spit","name":"Sopro do Boto","desc":"Projetil de Ability.","max":5,"effect":"unlock_attack"},
    {"id":"attack_spur","name":"Espora do Saci","desc":"Dispara junto do outro ataque basico.","max":5,"effect":"unlock_attack"},
    {"id":"attack_body_slam","name":"Impacto da Capivara","desc":"Dano Physical mais parte do Max HP.","max":5,"effect":"unlock_attack"},
    {"id":"attack_stoner","name":"Pedra do Curupira","desc":"Arremesso hibrido de pedras.","max":5,"effect":"unlock_attack"},
    {"id":"attack_tongue","name":"Lingua do Sapo-Aranha","desc":"Projetil que causa dano e stun.","max":5,"effect":"unlock_attack"},
    {"id":"attack_tail_whip","name":"Cauda da Sucuri","desc":"Golpe largo de cauda.","max":5,"effect":"unlock_attack"}
]

const ULTIMATE_UPGRADES := [
    {"id":"ultimate_courting","name":"Canto do Boto","desc":"Ultimate de Charm.","max":3,"effect":"unlock_ultimate"},
    {"id":"ultimate_sharpen","name":"Instinto da Onca","desc":"Buff ofensivo por dez segundos.","max":3,"effect":"unlock_ultimate"},
    {"id":"ultimate_pistol_pincer","name":"Bote do Minhocao","desc":"Grande burst de alvo unico.","max":3,"effect":"unlock_ultimate"},
    {"id":"ultimate_constriction","name":"Abraco da Sucuri","desc":"Stun e dano continuo em area.","max":3,"effect":"unlock_ultimate"},
    {"id":"ultimate_spirit_shedding","name":"Troca de Pele Ancestral","desc":"Buff baseado na quantidade de Evolutions da build.","max":3,"effect":"unlock_ultimate"},
    {"id":"ultimate_burrower","name":"Toca do Tatu","desc":"Cria uma janela de protecao.","max":3,"effect":"unlock_ultimate"},
    {"id":"ultimate_lick_wounds","name":"Lamber Feridas","desc":"Cura sob demanda.","max":3,"effect":"unlock_ultimate"},
    {"id":"ultimate_spinnerets","name":"Teia da Aranha-Cangaceira","desc":"Teia reduz movimento em 66%.","max":3,"effect":"unlock_ultimate"}
]

const MOVEMENT_UPGRADES := [
    {"id":"movement_dash","name":"Arranco da Onca","desc":"Dash melhorado.","max":3,"effect":"unlock_movement"},
    {"id":"movement_slide","name":"Deslize da Sucuri","desc":"Deslocamento longo.","max":3,"effect":"unlock_movement"},
    {"id":"movement_sprint","name":"Corrida do Guara","desc":"Aceleracao temporaria.","max":3,"effect":"unlock_movement"},
    {"id":"movement_hide","name":"Sumico do Curupira","desc":"Evasao e invisibilidade breve.","max":3,"effect":"unlock_movement"},
    {"id":"movement_leap","name":"Salto do Sapo","desc":"Salta por inimigos e obstaculos.","max":3,"effect":"unlock_movement"},
    {"id":"movement_scuttle","name":"Passo do Uca","desc":"Dash curto e rapido.","max":3,"effect":"unlock_movement"},
    {"id":"movement_turtle_down","name":"Casco do Jabuti","desc":"Defesa durante movimento.","max":3,"effect":"unlock_movement"},
    {"id":"movement_jet","name":"Jato da Iara","desc":"Dash ativa secrecoes e trilhas.","max":3,"effect":"unlock_movement"}
]

const ENDLESS_UPGRADES := [
    {"id":"endless_physical","name":"Physical sem Fim","desc":"Nivel repetivel exclusivo de Endless.","max":999,"effect":"physical"},
    {"id":"endless_ability","name":"Ability sem Fim","desc":"Nivel repetivel exclusivo de Endless.","max":999,"effect":"ability"},
    {"id":"endless_vitality","name":"Vitalidade sem Fim","desc":"Nivel repetivel exclusivo de Endless.","max":999,"effect":"hp"},
    {"id":"endless_social","name":"Matilha sem Fim","desc":"Nivel repetivel exclusivo de Endless.","max":999,"effect":"social"},
    {"id":"endless_adaptation","name":"Adaptacao sem Fim","desc":"Nivel repetivel exclusivo de Endless.","max":999,"effect":"terrain"}
]

const PRESSURE_UNLOCKS := {
    "hibernation":2, "ultimate_burrower":2, "ultimate_lick_wounds":3,
    "attack_tongue":3, "overwhelm":4, "pedal_glands":5, "tracker":6,
    "fin":7, "fibroblasts":8, "ambush":9, "ultimate_spinnerets":10,
    "ultimate_constriction":11, "movement_jet":12
}

const ALL_UPGRADES := UPGRADES + EXTRA_UPGRADES + ATTACK_UPGRADES + ULTIMATE_UPGRADES + MOVEMENT_UPGRADES + ENDLESS_UPGRADES
const BRANCH_IDS: Array[String] = ["tail", "legs", "wings", "slithery", "tentacles", "arms", "alpha", "pollinator", "ruminant", "exoskeleton"]

func find_upgrade(upgrade_id: String) -> Dictionary:
    for upgrade in ALL_UPGRADES:
        if String(upgrade["id"]) == upgrade_id: return upgrade
    return {}

func get_options(levels: Dictionary, count: int = 3, rarity_luck: float = 0.0, forced_minimum: String = "") -> Array[Dictionary]:
    var available: Array[Dictionary] = []
    for upgrade in ALL_UPGRADES:
        var id := String(upgrade["id"])
        if id.begins_with("endless_") and not GameSession.is_endless():
            continue
        if PRESSURE_UNLOCKS.has(id) and GameSession.run_mode == GameSession.RunMode.PRESSURE and GameSession.pressure_level < int(PRESSURE_UNLOCKS[id]):
            continue
        if int(levels.get(upgrade["id"], 0)) < int(upgrade["max"]):
            available.append(upgrade)
    available.shuffle()
    var result: Array[Dictionary] = []
    for i in range(mini(count, available.size())):
        var option: Dictionary = available[i].duplicate(true)
        option["rarity"] = CombatDB.roll_rarity(rarity_luck, forced_minimum)
        result.append(option)
    return result

func get_branching_options(levels: Dictionary, count: int = 3) -> Array[Dictionary]:
    var available: Array[Dictionary] = []
    for branch_id in BRANCH_IDS:
        if int(levels.get(branch_id, 0)) > 0:
            continue
        var branch: Dictionary = find_upgrade(branch_id)
        if not branch.is_empty():
            available.append(branch)
    if available.is_empty():
        for branch_id in BRANCH_IDS:
            var fallback: Dictionary = find_upgrade(branch_id)
            if not fallback.is_empty():
                available.append(fallback)
    available.shuffle()
    var result: Array[Dictionary] = []
    for index in range(mini(count, available.size())):
        var option: Dictionary = available[index].duplicate(true)
        option["rarity"] = "legendary"
        result.append(option)
    return result
