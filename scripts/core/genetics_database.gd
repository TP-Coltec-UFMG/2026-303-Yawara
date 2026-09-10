extends Node

# Genetics sao regras de inicio de run. Os nomes foram recontextualizados para
# Yawara; os papeis mecanicos correspondem ao sistema que inspirou o projeto.
const GENETICS := {
    "standard":{"name":"Sangue Comum","desc":"+15 PV."},
    "chaos_spawn":{"name":"Filho do Redemoinho","desc":"Atributos iniciais aleatorios."},
    "simple":{"name":"Caminho Simples","desc":"-2 escolhas e +200 Mutagen."},
    "stubborn":{"name":"Teimosia do Sertao","desc":"Algumas recusas entregam Mutagen."},
    "bullseye":{"name":"Olho da Onca","desc":"Ataques usam o maior entre Physical e Ability."},
    "challenger":{"name":"Cacador de Alphas","desc":"+30% dano e +30% aparicao de Alphas."},
    "chosen":{"name":"Escolhido da Mata","desc":"O terceiro nivel oferece tres Lendarias novas."},
    "chaos_envoy":{"name":"Emissario dos Encantados","desc":"Afinidades iniciais aleatorias."},
    "expert":{"name":"Mestre das Trilhas","desc":"Specialisations surgem um nivel antes."},
    "grandiose":{"name":"Corpo de Gigante","desc":"Size maior melhora a raridade."},
    "highborn":{"name":"Sangue de Guardiao","desc":"Poder proprio menor; proximidade aumenta dano de todos."},
    "independent":{"name":"Andarilho Solitario","desc":"Branching a cada 12 niveis; chefes nao dao Fruto Ancestral."},
    "minimalist":{"name":"Pouco e Preciso","desc":"+15% dano e Progress por slot ativo vazio."},
    "opportunistic":{"name":"Olhar do Quati","desc":"Bonus de aliados e POIs dobrados."},
    "pacifist":{"name":"Pacto da Capivara","desc":"-50% dano; requer 33% menos Progress."},
    "patient":{"name":"Espera da Sucuri","desc":"Pode recusar nivel para melhorar a proxima raridade."},
    "picky":{"name":"Paladar do Boto","desc":"Reroll custa 1 Mutagen a menos."},
    "pioneer":{"name":"Desbravador","desc":"+50% POIs."},
    "precocious":{"name":"Despertar Precoce","desc":"Primeiro nivel e Branching; primeiro chefe sem fruto."},
    "underdog":{"name":"Eco Enfraquecido","desc":"Comeca fraco e recebe grande bonus depois do segundo chefe."},
    "vegan":{"name":"Guardiao das Frutas","desc":"Comeca com dieta vegana."},
    "contrarian":{"name":"Caminho Contrario","desc":"Evolucoes pouco escolhidas aparecem mais e melhores."},
    "elitist":{"name":"Selo Lendario","desc":"Lendaria nova da outro nivel; Common nova reduz 10% dos PV."}
}

func apply_to_player(player, genetic_id: String) -> void:
    match genetic_id:
        "standard": player.health.increase_max(15.0, 15.0)
        "simple": player.mutagen += 200; player.evolution_choice_count = 1
        "stubborn": player.mutagen += 25
        "pacifist": player.attack_damage *= 0.50; player.progress_requirement_multiplier = 0.67
        "vegan": player.diet_style = "vegan"
        "challenger": player.alpha_damage_multiplier = 1.30
        "pioneer": player.poi_multiplier = 1.50
        "picky": player.reroll_discount = 1
        "expert": player.specialisation_level_offset = 1
        "grandiose": player.size_rarity_bonus = 0.35
        "bullseye": player.use_highest_attack_stat = true
        "opportunistic": player.poi_reward_multiplier = 2.0; player.ally_reward_multiplier = 2.0
        "minimalist": player.empty_slot_bonus = 0.15
        "chaos_envoy":
            for i in range(player.spirit_affinities.size()): player.spirit_affinities[i] = randi_range(0, 8)
        "chaos_spawn":
            player.attack_damage *= randf_range(0.70, 1.45)
            player.move_speed *= randf_range(0.78, 1.35)
            player.change_size(randf_range(-0.16, 0.22))
        "highborn": player.attack_damage *= 0.50; player.ability_power *= 0.50; player.highborn_rule = true
        "patient": player.rarity_luck += 0.15
        "precocious": player.rarity_luck += 0.10; player.mutagen += 10
        "underdog": player.attack_damage *= 0.72; player.underdog_rule = true
        "contrarian": player.rarity_luck += 0.35
        "independent": player.independent_rule = true
        "elitist": player.rarity_luck += 0.08
