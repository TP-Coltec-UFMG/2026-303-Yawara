# LISTA DE ASSETS — ECOS DO BRASIL: YAWARA

Esta lista preserva a organizacao original do projeto. Todos os PNGs sao opcionais enquanto estiverem faltando: o jogo desenha placeholders, portanto continua executavel.

Padrao recomendado: PNG transparente, pixel art ou pintura 2D vista de cima, origem central. Personagem/criaturas em 128x128; chefes em 256x256; icones em 64x64; tiles/POIs em 128x128.

Fonte opcional para aproximar a interface da referencia: `assets/fonts/yawara_pixel.ttf`, legivel em portugues e licenciada para distribuicao com o jogo.

## 1. Personagem base

Pasta: `assets/sprites/player/`

- `player.png` — criatura inicial neutra, pequena, vista de cima.
- `base.png` — nome alternativo aceito pelo codigo.
- `player_hurt.png` — variacao de dano.
- `player_dash.png` — silhueta de movimento.
- `player_shadow.png` — sombra oval separada.

## 2. Partes visuais das Evolutions originais

Pasta: `assets/sprites/player/parts/`

- `garras_tamandua.png`
- `redemoinho_saci.png`
- `vigor_capivara.png`
- `pes_curupira.png`
- `cauda_sucuri.png`
- `asas_arara.png`
- `fogo_boitata.png`
- `orelhas_onca.png`
- `aura_iara.png`
- `carapaca_tatu.png`
- `encanto_boto.png`
- `leveza_mico.png`
- `corpo_queixada.png`
- `faro_mao_pelada.png`
- `casco_jabuti.png`

## 3. Doze familias regulares e evolucoes

Pasta: `assets/sprites/creatures/`

Cada familia deve ter sprite base e, quando listado, as variacoes `_plus` e `_plusplus`. O codigo usa o base caso as variacoes ainda nao existam.

- `marimbondo_onca.png`, `marimbondo_onca_plus.png` — voo/mergulho; + deixa nuvem venenosa.
- `minhocao_areia.png`, `minhocao_areia_plus.png` — enterrado e ataque marcado na areia.
- `capivara_couracada.png` — tank passivo que reage a violencia.
- `onca_sombra.png`, `onca_sombra_plus.png` — rush, combate e fuga; + ganha combo.
- `furao_ladrao.png`, `furao_ladrao_plus.png`, `furao_ladrao_plusplus.png` — roubo; pedras; arremesso.
- `sapo_aranha.png`, `sapo_aranha_plus.png` — lingua/stun; + golpe mais rapido.
- `fruta_espinho.png`, `fruta_espinho_plus.png`, `fruta_espinho_plusplus.png` — mimic cada vez mais agressivo.
- `peixe_cuspidor.png`, `peixe_cuspidor_plus.png` — ranged aquatico; + ganha pernas.
- `jabuti_ancestral.png`, `jabuti_ancestral_plus.png` — Plating e janela vulneravel.
- `peixe_boi_jovem.png`, `peixe_boi_jovem_plus.png` — presa inicial; + contato venenoso.
- `coruja_oco.png`, `coruja_oco_plus.png` — foge para toca; + cria chamariz.
- `lebre_pampas.png`, `lebre_pampas_plus.png` — presa muito rapida; + movimento em zigue-zague.

Marcador Alpha:

- `alpha_aura.png` — aro dourado reutilizavel em qualquer familia.
- `alpha_crown.png` — icone pequeno acima da barra de vida.

## 4. Adds de chefes

Pasta: `assets/sprites/enemies/`

- `curumim_corrompido.png` — add agressivo convocado por Yawara.
- `raiz_yawara.png` — raiz/tentaculo estacionario de area.
- `egg_sac.png` — casulo para Specialisation da teia.
- `darwee_encantado.png` — aliado especial gerado pelo casulo.

## 5. Cinco minibosses e Yawara

Pasta: `assets/sprites/miniboss/`

As cinco folhas JPEG enviadas ja estao ligadas como fallback em `source_guardians/`. Os PNGs abaixo, quando adicionados, substituem automaticamente os recortes provisórios.

- `mapinguari.png` — Grande Floresta, veneno e regeneracao.
- `corpo_seco.png` — Grande Floresta/Serra, raizes e defesa.
- `cabra_cabriola.png` — Caatinga, leques de fogo.
- `minhocao.png` — Pantanal, onda de impacto e terreno.
- `teiniagua.png` — Campos de Geada, projeteis espirituais.

Pasta: `assets/sprites/boss/`

- `yawara.png` — onca ancestral corrompida, sprite principal.
- `yawara_phase_2.png` — corrupcao expandida.
- `yawara_phase_3.png` — forma do eclipse/Cataclysm.
- `yawara_portrait.png` — retrato para HUD e tela final.

## 6. Armas existentes — apenas visual/nome recontextualizado

Pasta: `assets/sprites/weapons/`

- `claws.png` — Garras da Onca Ancestral.
- `spear.png` — Lanca dos Guardioes.
- `blowgun.png` — Sopro da Mata.
- `boleadeira.png` — Laco do Vento Sul.
- `maraca.png` — Maraca do Eclipse de Yawara.

Os IDs e os arquivos permanecem iguais aos originais para nao quebrar cenas ou saves.

## 7. Dezesseis ataques corporais

Pasta: `assets/sprites/ui/attacks/`

- `beak.png`, `claws.png`, `pincers.png`, `toe_beans.png`
- `jaws.png`, `antlers.png`, `horns.png`, `trunk.png`
- `leech.png`, `stinger.png`, `spit.png`, `spur.png`
- `body_slam.png`, `stoner.png`, `tongue.png`, `tail_whip.png`

Efeitos correspondentes em `assets/sprites/effects/`: `beak_slash.png`, `claw_slash.png`, `charge_line.png`, `poison_tick.png`, `tongue_line.png`, `stone_projectile.png`, `body_slam_ring.png`.

## 8. Oito Ultimates

Pasta: `assets/sprites/ui/ultimates/`

- `courting.png` — Canto do Boto.
- `sharpen.png` — Instinto da Onca.
- `pistol_pincer.png` — Bote do Minhocao.
- `constriction.png` — Abraco da Sucuri.
- `spirit_shedding.png` — Troca de Pele Ancestral.
- `burrower.png` — Toca do Tatu.
- `lick_wounds.png` — Lamber Feridas.
- `spinnerets.png` — Teia da Aranha-Cangaceira.

## 9. Nove movimentos/dashes

Pasta: `assets/sprites/ui/movement/`

- `basic_dash.png`, `dash.png`, `slide.png`, `sprint.png`, `hide.png`
- `leap.png`, `scuttle.png`, `turtle_down.png`, `jet.png`

## 10. Evolutions e Specialisations

Pasta: `assets/sprites/ui/evolutions/`

Crie um PNG de 64x64 com o mesmo ID presente em `scripts/core/upgrade_database.gd`. A tela de build ja procura automaticamente `%id%.png`. O catalogo inclui 120+ entradas combinando melhorias, ataques, Ultimates e movimentos.

Specialisations que merecem icone proprio:

- `stoner_training.png`, `stoner_signal.png`
- `leech_anaesthetic.png`, `leech_vasodilators.png`
- `spur_marking.png`, `spur_primal.png`
- `tongue_whiplash.png`, `tongue_sticky.png`
- `pedal_glands_thick.png`, `pedal_glands_nemertide.png`
- `spinnerets_trap.png`, `spinnerets_egg_sac.png`

## 11. Quatro biomas

Pasta: `assets/sprites/regions/`

- `grande_floresta_ground.png` — Amazonia/Mata Atlantica.
- `sertao_ground.png` — Caatinga/areia/pedra.
- `pantanal_ground.png` — Cerrado, lama e agua.
- `campos_geada_ground.png` — Pampas, araucarias e frio.
- `water.png`, `mud.png`, `sand.png`, `snow.png` — transicoes de terreno.

Pasta: `assets/sprites/world/`

- `amazon_tree.png`, `atlantic_tree.png`, `caatinga_tree.png`, `cerrado_tree.png`, `araucaria.png`
- `rock.png`, `cactus.png`, `dry_bush.png`, `pantanal_reed.png`, `ice_rock.png`
- `burrow.png`, `fishing_ripple.png`, `fruit_shadow.png`

## 12. Clima e ciclo de tempo

Pasta: `assets/sprites/effects/`

- `rain.png`, `heatwave.png`, `blizzard.png`, `soak_splash.png`
- `day_overlay.png`, `night_overlay.png`, `fog.png`
- `projectile_player.png`, `projectile_yawara.png`, `slash.png`, `essence.png`
- `meteor_marker.png`, `meteor_impact.png`, `poison_breath.png`, `root_marker.png`
- `web.png`, `slime_trail.png`, `charm_heart.png`, `plating_break.png`

## 13. Alimentos e raridades

Pasta: `assets/sprites/food/`

- `acai.png`, `jabuticaba.png`, `umbu.png`, `pequi.png`, `pinhao.png`
- `fish.png`, `mushroom.png`, `meat.png`, `carrion.png`, `heart.png`
- `ancestral_fruit.png` — Fruto Ancestral entregue por mini-chefes; abre uma Evolution corporal.
- Para cada alimento base, crie também `%nome%_bite_1.png`, `%nome%_bite_2.png` e `%nome%_bite_3.png`. Ex.: `acai_bite_1.png` e `meat_bite_3.png`. O arquivo sem sufixo é o estado inteiro; a quarta mordida remove o objeto.
- `food_common_glow.png`, `food_rare_glow.png`, `food_epic_glow.png`, `food_legendary_glow.png`

## 14. Quatorze POIs

Pasta: `assets/sprites/world/pois/`

- `algae_reef.png`, `carved_tree.png`, `chaos_tree.png`, `frozen_specimen.png`
- `giant_mushroom.png`, `growing_tree.png`, `healing_pond.png`, `lotus_plant.png`
- `mud_pond.png`, `oasis.png`, `sun_dial.png`, `unattended_nest.png`
- `bramble.png`, `boss_area.png`

## 15. Interface

Pasta: `assets/sprites/ui/`

- `health_frame.png`, `progress_frame.png`, `food_frame.png`, `plating_frame.png`
- `mutagen.png`, `timer.png`, `boss_marker.png`, `miniboss_marker.png`
- `build_panel_left.png`, `build_panel_center.png`, `build_panel_right.png`, `evolution_card_frame.png`, `affinity_radar.png`
- `rarity_common.png`, `rarity_rare.png`, `rarity_epic.png`, `rarity_legendary.png`
- `affinity_predator.png`, `affinity_prey.png`, `affinity_trickster.png`, `affinity_imposing.png`, `affinity_social.png`
- `day.png`, `night.png`, `heat.png`, `cold.png`, `soak.png`
- `genetics.png`, `pressure.png`, `endless.png`, `size.png`, `terrain.png`, `climate.png`
- `key_e.png`, `key_c.png`, `key_tab.png`, `key_f.png`, `key_q.png`, `key_r.png`, `key_t.png`, `key_g.png`, `key_x.png`, `key_u.png`

## 16. Audio

Pasta: `assets/audio/`

- `music_menu.ogg`, `music_regions.ogg`, `music_boss.ogg`, `music_endless.ogg`
- `attack.wav`, `dash.wav`, `hurt.wav`, `levelup.wav`, `boss_roar.wav`
- `miniboss_spawn.wav`, `alpha_spawn.wav`, `mutagen.wav`, `rarity_legendary.wav`
- `meteor_warning.wav`, `meteor_impact.wav`, `poison_breath.wav`, `charm.wav`, `plating_break.wav`

## Prioridade de producao

1. `player.png`, os 12 sprites base e `yawara.png`.
2. Cinco minibosses, cinco armas e quatro fundos de bioma.
3. Efeitos de ataque/telegraph, carne com quatro mordidas, alimentos e 14 POIs.
4. Variantes +/++, Alpha, Ultimates e dashes.
5. Icones individuais de Evolutions/Genetics e polimento de UI.
