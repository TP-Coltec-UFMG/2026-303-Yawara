# Ecos do Brasil: Yawara — Pixel Art + Áudio (Godot 4.5+)

Protótipo completo de roguelite top-down inspirado na estrutura de evolução corporal/ecossistema de Everything is Crab, com identidade brasileira própria.

## Como abrir

1. Extraia a pasta.
2. Abra a Godot 4.5 ou posterior (preferencialmente 4.5).
3. Importe/abra `project.godot`.
4. Execute com `F6/F5` normalmente; a cena principal é o menu.

## Controles

- `WASD` / setas: mover.
- Mouse esquerdo/direito ou `J`: atacar.
- Espaço: dash.
- `F`: usar Ultimate.
- `T`: alternar Ultimate desbloqueada.
- `G`: alternar tipo de dash desbloqueado.
- `C` ou `Tab`: tela completa da build.
- Frutas e carnes: basta passar por cima; as quatro mordidas acontecem automaticamente no ritmo de Feeding Speed.
- `E`: interage apenas com POIs e amizades.
- `Q` / `R`: próxima/arma anterior.
- `1–5`: selecionar diretamente uma arma já desbloqueada.
- Na escolha de Evolution: `X` gasta 1 Mutagen para reroll; `U` gasta 10 para elevar a raridade.

## Estrutura da run

- Cronometro crescente durante toda a partida.
- Aos `03:00` e `06:00`, surge um miniboss relacionado ao bioma ocupado naquele instante.
- Aos `08:00`, Yawara surge como sexto e ultimo chefe da run Normal.
- Quatro biomas brasileiros sao gerados em manchas procedurais irregulares (Voronoi).
- Fauna possui relações predador/presa, fuga, territorialidade e passividade.
- Frutas, árvores, pedras, lagos, pontos sociais e mini-chefes aparecem no mundo.
- O confronto final dura até 2 minutos.
- Modos Normal, Pressure 0–20 e Endless sao escolhidos no menu.

## Sistemas principais

- 51 stats internos, Physical, Ability, Social, Size, Plating, Terrain, Heat, Cold e Soak.
- alimentação automática por proximidade em quatro mordidas, carne no lugar de XP de abates, Progress, Mutagen e quatro raridades;
- 23 Genetics com Splicing opcional;
- 130 entradas no catalogo de Evolutions, ataques, Ultimates e movimentos;
- 16 ataques corporais, 8 Ultimates, 9 movimentos/dashes e Specialisations;
- 12 familias regulares com evolucoes mecanicas, Alphas e dois adds de chefe;
- cinco minibosses de bioma + Yawara, com meteoros, baforada venenosa, adds e fases;
- 14 POIs, ciclo dia/noite, quatro eventos climaticos, ecossistema e amizade espontanea;
- Pressure com escalas e desbloqueios; Endless com niveis repetiveis.

## Builds suportadas

O jogo não exige uma build de dano única. Atributos foram conectados a mecânicas:

- pequeno + rápido + esquiva;
- gigante + dano + área + resistência;
- Social + companheiros + Maracá + encontros + apoio contra Yawara;
- forrageamento/pacifista/vegano;
- ranged com Zarabatana/Boleadeira;
- corpo a corpo com Garras/Lança;
- adaptação a terreno/calor/frio;
- combinações híbridas.

Veja `GAMEPLAY_SYSTEMS.md` para a descrição detalhada, `GUIA_INSTALACAO_ASSETS.md` para instalar cada arte e `SPRITES_TODO.md` para o inventário completo.

## Sprites, arte e áudio atualizados

- Os sprites animados do Aruan, dos animais e dos minibosses estão integrados aos recursos `assets/animations/*.tres`.
- A estética usa pixel art sem suavização, escala padronizada e cenário com densidade moderada.
- Fauna antiga sem equivalente no pacote recebido foi retirada da seleção de criaturas comuns, mas seus arquivos continuam preservados para compatibilidade.
- Três músicas instrumentais **originais** em loop (`music_menu.ogg`, `music_regions.ogg` e `music_boss.ogg`).
- Efeitos originais para movimento, ataques, coleta, dash e eventos importantes.
- Volumes independentes em Configurações → Áudio (Master, Music, SFX).
- Veja `ATUALIZACAO_SPRITES_SOM_2026.md` para detalhes e roteiro de testes.

**Observação:** os testes estáticos não substituem jogar no motor Godot. O projeto segue em desenvolvimento e pode ter defeitos não identificados.

## Atalhos para teste

- `F2`: ir quase imediatamente para Yawara.
- `F3`: adicionar XP.
- `F4`: causar dano na Yawara.
- `F5`: forçar o mini-chefe do bioma atual.
