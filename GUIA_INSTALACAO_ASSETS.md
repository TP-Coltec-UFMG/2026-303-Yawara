# Guia final para instalar os assets

O projeto procura automaticamente os assets principais pelo nome. Você não precisa abrir cenas nem arrastar personagem, pisos, comida, props, criaturas, Guardiões, Yawara, armas, efeitos básicos ou ícones de Evolution para nós: coloque cada arquivo na pasta indicada, volte ao Godot, aguarde a importação e execute o jogo. Alguns itens de polimento listados em `SPRITES_TODO.md` estão marcados como reservados e só serão necessários caso essas telas/animações sejam ampliadas.

## 1. Regra geral

1. Use PNG com fundo transparente, exceto músicas e efeitos sonoros.
2. Não altere letras, sublinhados ou extensões dos nomes indicados.
3. O projeto já usa `Nearest` como filtro 2D global para preservar o pixel art. Se quiser conferir: Project Settings → Rendering → Textures → Canvas Textures → Default Texture Filter.
4. Aguarde o Godot importar novamente depois de substituir uma imagem.
5. Mantenha o personagem no centro da tela do PNG e os pés próximos à parte inferior.
6. Não coloque margem transparente exagerada: o código calcula a escala usando a dimensão total do arquivo.

O inventário completo de nomes está em `SPRITES_TODO.md`. As seções abaixo explicam exatamente como os grupos mais importantes entram no jogo.

## 2. Personagem jogável

Pasta:

```text
assets/sprites/player/
```

Arquivo principal:

```text
player.png
```

Configuração recomendada: PNG transparente, 128×128, vista superior ou três-quartos, personagem centralizado. O código reduz a maior dimensão para aproximadamente 48 pixels no mundo. `base.png` só é usado se `player.png` não existir.

Passo a passo:

1. Exporte sua arte como `player.png`.
2. Copie para `assets/sprites/player/player.png`.
3. Apague ou renomeie `base.png` se quiser garantir que não haja dúvida, embora `player.png` já tenha prioridade.
4. Abra o projeto; o personagem será carregado por `scripts/player/player.gd`.

As partes de evolução são imagens transparentes separadas em:

```text
assets/sprites/player/parts/
```

Use exatamente os 15 nomes da seção “Partes visuais das Evolutions” de `SPRITES_TODO.md`. Elas são sobrepostas ao centro do personagem; prefira canvas 128×128 com o mesmo pivô de `player.png`.

## 3. Chão e mapa infinito

Os quatro pisos são repetidos automaticamente em cada chunk procedural de 960×960:

```text
assets/sprites/regions/grande_floresta_ground.png
assets/sprites/regions/sertao_ground.png
assets/sprites/regions/pantanal_ground.png
assets/sprites/regions/campos_geada_ground.png
```

Faça cada piso quadrado, preferencialmente 256×256 ou 512×512, sem bordas visíveis e perfeitamente repetível nos quatro lados. Eles não são mapas completos: são texturas de terreno que o gerador combina com lagos, vegetação, pedras, inimigos e POIs.

Objetos sólidos do mapa ficam em:

```text
assets/sprites/world/amazon_tree.png
assets/sprites/world/caatinga_tree.png
assets/sprites/world/cerrado_tree.png
assets/sprites/world/araucaria.png
assets/sprites/world/rock.png
```

Árvores funcionam melhor em 128×128 e pedras em 64×64. O pivô é central. Árvores e pedras têm colisão, mas são indestrutíveis. As árvores produzem frutas sozinhas com o tempo.

As imagens `water.png`, `mud.png`, `sand.png` e `snow.png` continuam reservadas para transições e polimento. Os lagos atuais são desenhados proceduralmente.

## 4. Frutas, carne e mordidas

Pasta:

```text
assets/sprites/food/
```

Alimentos carregados diretamente pelos quatro biomas e pelos abates:

```text
acai.png
umbu.png
pequi.png
pinhao.png
meat.png
ancestral_fruit.png
```

Para mostrar a aparência mudando, crie três estados adicionais para cada alimento normal:

```text
acai_bite_1.png
acai_bite_2.png
acai_bite_3.png
meat_bite_1.png
meat_bite_2.png
meat_bite_3.png
```

Repita o padrão para `umbu`, `pequi` e `pinhao`. Todos os quatro estados de um alimento precisam ter o mesmo tamanho de canvas e a mesma posição central.

- arquivo sem `_bite`: inteiro;
- `_bite_1`: uma mordida;
- `_bite_2`: metade consumida;
- `_bite_3`: último pedaço;
- quarta mordida: o objeto desaparece.

Se esses estados não existirem, o jogo reduz e escurece o sprite progressivamente. A alimentação começa automaticamente quando o jogador passa sobre o alimento; apenas a comida mais próxima é usada e o intervalo continua dependendo de Feeding Speed.

## 5. Guardiões já incluídos

As cinco imagens enviadas estão em:

```text
assets/sprites/miniboss/source_guardians/
```

Associação aplicada:

| Imagem enviada | Guardião no jogo | Arquivo-fonte |
| --- | --- | --- |
| criatura verde com boca no ventre | Mapinguari Ancestral | `mapinguari_sheet.jpeg` |
| criatura rochosa enrolada | Minhocão do Pantanal | `minhocao_sheet.jpeg` |
| xamã com olho roxo | Teiniaguá Corrompida, uso provisório | `teiniagua_sheet.jpeg` |
| viajante com máscara de cabra | Cabra Cabriola | `cabra_cabriola_sheet.jpeg` |
| esqueleto com cajado azul | Corpo-Seco da Serra | `corpo_seco_sheet.jpeg` |

O código recorta e anima os quadros de caminhada da primeira linha, inverte a direção horizontal durante o movimento e remove visualmente o fundo. Como os originais são JPEGs montados, podem aparecer pequenos contornos. Para trocar por versões definitivas, exporte PNG transparente e coloque em:

```text
assets/sprites/miniboss/mapinguari.png
assets/sprites/miniboss/minhocao.png
assets/sprites/miniboss/teiniagua.png
assets/sprites/miniboss/cabra_cabriola.png
assets/sprites/miniboss/corpo_seco.png
```

Esses PNGs têm prioridade automática sobre as folhas JPEG. Recomenda-se 256×256, um Guardião inteiro centralizado, sem texto, cursor, grade ou fundo.

## 6. Yawara

Coloque a arte principal em:

```text
assets/sprites/boss/yawara.png
```

Use PNG transparente de 256×256 ou 512×512. O código reduz a maior dimensão para aproximadamente 126 pixels. Os arquivos `yawara_phase_2.png` e `yawara_phase_3.png` estão reservados para animação visual futura; a lógica das três fases já funciona mesmo apenas com `yawara.png`.

## 7. Criaturas regulares

Pasta:

```text
assets/sprites/creatures/
```

Coloque os 12 PNGs base usando os IDs exatos listados em `SPRITES_TODO.md`, por exemplo `marimbondo_onca.png` e `onca_sombra.png`. Recomenda-se 128×128 transparente. O código atualmente carrega o arquivo base também nas evoluções; portanto as variações `_plus` e `_plusplus` podem ser produzidas depois sem impedir o jogo de funcionar.

## 8. Armas, efeitos e interface

- Armas: `assets/sprites/weapons/`, PNG transparente de 64×64 ou 128×128.
- Projéteis e golpes: `assets/sprites/effects/`, PNG transparente de 64×64 a 256×256.
- Ícones de Evolutions: `assets/sprites/ui/evolutions/`, PNG 64×64 com o ID exato de `scripts/core/upgrade_database.gd`.
- Molduras e ícones gerais: `assets/sprites/ui/`.
- POIs: `assets/sprites/world/pois/`, preferencialmente PNG 128×128.
- Áudio: `assets/audio/`; músicas em OGG e efeitos em WAV.

Os cinco nomes de armas, os 16 ataques, 8 Ultimates, 9 movimentos, 14 POIs, efeitos, UI e áudio estão enumerados integralmente em `SPRITES_TODO.md`.

## 9. Como conferir se um asset foi reconhecido

1. Feche o jogo em execução.
2. Copie o arquivo para a pasta correta.
3. Volte ao Godot e espere o ícone de importação desaparecer.
4. Confirme que o nome apareceu no painel FileSystem exatamente igual ao guia.
5. Execute com F6/F5.
6. Se continuar aparecendo o desenho geométrico, normalmente há erro no nome, extensão duplicada como `.png.png`, pasta incorreta ou transparência exportada como JPEG.

Não é necessário editar arquivos `.tscn` para os assets listados neste guia.
