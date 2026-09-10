extends Node

const RARITIES := {
    "common":{"name":"Comum","color":Color("#b9b8aa"),"power":0.86,"weight":62.0},
    "rare":{"name":"Rara","color":Color("#58a9df"),"power":1.00,"weight":26.0},
    "epic":{"name":"Epica","color":Color("#b56be0"),"power":1.16,"weight":9.0},
    "legendary":{"name":"Lendaria","color":Color("#f1b843"),"power":1.34,"weight":3.0}
}

# Ataques preservam papeis, recargas e escalas; somente a fantasia/nome mudou.
const ATTACKS := {
    "beak":{"name":"Bico do Carcara","stat":"physical","cooldown":0.8,"scale":[0.55,0.70,0.85,1.00,1.15],"kind":"melee"},
    "claws":{"name":"Garras da Onca","stat":"physical","cooldown":0.8,"scale":[0.75,0.90,1.05,1.20,1.35],"kind":"melee"},
    "pincers":{"name":"Pinças do Uca","stat":"physical","cooldown":1.0,"scale":[0.85,1.00,1.15,1.30,1.45],"kind":"melee"},
    "toe_beans":{"name":"Patas de Jaguatirica","stat":"physical","cooldown":0.65,"scale":[0.50,0.62,0.74,0.86,0.98],"kind":"melee"},
    "jaws":{"name":"Mandibula do Queixada","stat":"physical","cooldown":1.0,"scale":[0.90,1.08,1.26,1.44,1.62],"kind":"melee"},
    "antlers":{"name":"Galhada do Campeiro","stat":"physical","cooldown":1.0,"scale":[0.80,1.00,1.20,1.40,1.60],"kind":"charge"},
    "horns":{"name":"Chifres da Cabriola","stat":"physical","cooldown":1.0,"scale":[1.20,1.40,1.60,1.85,2.10],"kind":"charge","ignores_plating":true},
    "trunk":{"name":"Tromba do Guardiao","stat":"lowest","cooldown":1.5,"scale":[1.20,1.50,1.80,2.10,2.40],"kind":"wide"},
    "leech":{"name":"Sanguessuga do Pantanal","stat":"ability","cooldown":1.5,"scale":[1.05,1.18,1.31,1.44,1.57],"kind":"leech","heal":0.10},
    "stinger":{"name":"Ferrao do Marimbondo","stat":"hybrid","cooldown":3.0,"scale":[0.80,0.90,1.00,1.10,1.20],"kind":"poison","poison":0.175,"duration":5.0},
    "spit":{"name":"Sopro do Boto","stat":"ability","cooldown":1.5,"scale":[0.60,0.70,0.80,0.95,1.20],"kind":"projectile"},
    "spur":{"name":"Espora do Saci","stat":"physical","cooldown":2.0,"scale":[0.45,0.55,0.65,0.75,0.85],"kind":"follow_up"},
    "body_slam":{"name":"Impacto da Capivara","stat":"physical_hp","cooldown":1.25,"scale":[0.725,0.825,0.925,1.025,1.125],"hp_scale":[0.10,0.11,0.12,0.13,0.14],"kind":"slam"},
    "stoner":{"name":"Pedra do Curupira","stat":"hybrid","cooldown":1.15,"scale":[0.72,0.84,0.96,1.08,1.20],"kind":"stone"},
    "tongue":{"name":"Lingua do Sapo-Aranha","stat":"ability","cooldown":1.6,"scale":[0.75,0.90,1.05,1.20,1.35],"kind":"tongue","stun":true},
    "tail_whip":{"name":"Cauda da Sucuri","stat":"physical","cooldown":1.2,"scale":[0.72,0.86,1.00,1.14,1.28],"kind":"wide"}
}

const ULTIMATES := {
    "courting":{"name":"Canto do Boto","kind":"charm","cooldown":[25.0,15.0,5.0]},
    "sharpen":{"name":"Instinto da Onca","kind":"buff","cooldown":[24.0,20.0,16.0],"duration":10.0},
    "pistol_pincer":{"name":"Bote do Minhocao","kind":"burst","cooldown":[12.0,10.0,8.0],"scale":[2.4,2.8,3.25]},
    "constriction":{"name":"Abraco da Sucuri","kind":"stun_dot","cooldown":[36.0,29.0,22.0],"duration":5.0},
    "spirit_shedding":{"name":"Troca de Pele Ancestral","kind":"evolution_buff","cooldown":[90.0,80.0,70.0]},
    "burrower":{"name":"Toca do Tatu","kind":"burrow","cooldown":[80.0,60.0,40.0]},
    "lick_wounds":{"name":"Lamber Feridas","kind":"heal","cooldown":[42.0,32.0,24.0]},
    "spinnerets":{"name":"Teia da Aranha-Cangaceira","kind":"web","cooldown":[38.0,30.0,22.0],"slow":0.66}
}

const MOVEMENTS := {
    "basic_dash":{"name":"Esquiva Instintiva","distance":4.5,"cooldown":4.5},
    "dash":{"name":"Arranco da Onca","distance":5.2,"cooldown":4.0},
    "slide":{"name":"Deslize da Sucuri","distance":7.0,"cooldown":5.0},
    "sprint":{"name":"Corrida do Guara","distance":0.0,"cooldown":4.5},
    "hide":{"name":"Sumico do Curupira","distance":3.0,"cooldown":6.0},
    "leap":{"name":"Salto do Sapo","distance":6.5,"cooldown":5.5},
    "scuttle":{"name":"Passo do Uca","distance":3.5,"cooldown":4.0},
    "turtle_down":{"name":"Casco do Jabuti","distance":1.5,"cooldown":7.0},
    "jet":{"name":"Jato da Iara","distance":6.0,"cooldown":4.5}
}

const SPECIALISATIONS := {
    "stoner":["Treinamento do Curupira","Sinal da Matilha"],
    "leech":["Anestesia do Pantanal","Vasodilatadores"],
    "spur":["Marcacao do Saci","Impulso Primal"],
    "tongue":["Chicote Rapido","Lingua Pegajosa"],
    "pedal_glands":["Trilha Espessa","Veneno de Nemertino"],
    "spinnerets":["Armadilha","Casulo do Encantado"]
}

func roll_rarity(luck: float = 0.0, forced_minimum: String = "") -> String:
    var order := ["common", "rare", "epic", "legendary"]
    var weights := [62.0, 26.0 + luck * 8.0, 9.0 + luck * 5.0, 3.0 + luck * 2.5]
    var total := 0.0
    for weight in weights: total += weight
    var roll := randf() * total
    var selected := "common"
    for i in range(order.size()):
        roll -= weights[i]
        if roll <= 0.0:
            selected = order[i]
            break
    if not forced_minimum.is_empty() and order.find(selected) < order.find(forced_minimum):
        selected = forced_minimum
    return selected
