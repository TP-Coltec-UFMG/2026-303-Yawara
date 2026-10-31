
# Ecos do Brasil: Yawara

![Yawara - A Lenda dos 5 Territórios](<YAWARA_ A Lenda dos 5 Territórios.png>)

**Yawara** é um roguelite de ação *top-down* ambientado em um ecossistema inspirado na fauna, na flora e nos biomas brasileiros. O jogo combina combate, alimentação, evolução genética e adaptação ambiental em uma experiência de sobrevivência e progressão.

Inspirado em mecânicas de evolução corporal e ecossistema presentes em *Everything is Crab*, o projeto desenvolve uma identidade própria, com criaturas, ambientes, sistemas de evolução e referências à biodiversidade brasileira.

> **Status:** Protótipo jogável em desenvolvimento.

## 🎮 Sobre o projeto

O jogo apresenta um mundo procedural composto por quatro biomas brasileiros, nos quais o jogador precisa explorar, se alimentar, enfrentar criaturas e desenvolver sua própria estratégia de evolução.

Cada partida oferece diferentes possibilidades de build, combinações de atributos, habilidades e interações com o ecossistema.

## 🛠️ Tecnologias

- **Engine:** Godot Engine 4.5 ou posterior.
- **Linguagem:** GDScript.
- **Arte:** Pixel Art.
- **Áudio:** Trilhas instrumentais e efeitos sonoros originais.

## 🎮 Como executar

1. Clone ou baixe o repositório.
2. Instale a Godot 4.5 ou posterior (preferencialmente 4.5).
3. Abra a Godot e importe o arquivo `project.godot`.
4. Aguarde a importação dos recursos.
5. Execute o projeto com `F5`.

A cena principal do projeto é o menu inicial.

## 🕹️ Controles

| Tecla / Entrada | Ação |
|---|---|
| `WASD` / Setas | Movimentação |
| Mouse esquerdo/direito ou `J` | Atacar |
| `Espaço` | Executar dash |
| `F` | Usar Ultimate |
| `T` | Alternar Ultimate desbloqueada |
| `G` | Alternar tipo de dash desbloqueado |
| `C` / `Tab` | Abrir tela completa da build |
| `E` | Interagir com POIs e amizades |
| `Q` / `R` | Alternar armas |
| `1–5` | Selecionar arma desbloqueada |
| `X` | Refazer opções de Evolution (custa 1 Mutagen) |
| `U` | Elevar raridade das opções (custa 10 Mutagen) |

**Alimentação:** frutas e carnes são consumidas automaticamente ao passar por cima delas. Cada alimento possui quatro mordidas, realizadas no ritmo definido pelo atributo Feeding Speed.

## 🌎 Estrutura da partida

Cada partida acontece em um mundo procedural composto por quatro biomas brasileiros, distribuídos em manchas irregulares geradas por Voronoi.

A progressão acontece por meio de exploração, alimentação, combate e evolução:

- **03:00:** surge o primeiro miniboss, determinado pelo bioma ocupado.
- **06:00:** surge o segundo miniboss, também relacionado ao bioma atual.
- **08:00:** Yawara aparece como o sexto e último chefe da dificuldade Normal.
- **Confronto final:** pode durar até dois minutos.

O mundo também apresenta fauna com diferentes comportamentos, frutas, árvores, pedras, lagos, pontos de interesse (POIs), encontros sociais e eventos ambientais.

### Modos de jogo

- **Normal:** experiência principal, com progressão e confronto final.
- **Pressure (0–20):** dificuldade escalável com modificadores e desbloqueios.
- **Endless:** modo de sobrevivência com progressão por níveis repetíveis.

## 🧬 Sistemas de gameplay

O jogo possui diferentes sistemas interligados, permitindo que cada partida desenvolva uma configuração própria.

### Atributos e evolução

- 51 atributos internos, organizados em categorias como Physical, Ability, Social, Size, Plating, Terrain, Heat, Cold e Soak.
- Alimentação automática com quatro mordidas por alimento.
- Carne obtida de abates no lugar de XP diretamente.
- Sistemas de Progress e Mutagen.
- Quatro níveis de raridade para Evolutions.
- 23 Genetics, com possibilidade de Splicing.
- 130 entradas no catálogo de Evolutions, ataques, Ultimates e movimentos.

### Combate e habilidades

- 16 ataques corporais.
- 8 Ultimates.
- 9 movimentos e tipos de dash.
- Sistema de armas e Specialisations.
- Evoluções mecânicas das criaturas e dos equipamentos.

### Ecossistema e criaturas

- 12 famílias regulares de criaturas.
- Evoluções mecânicas, variantes Alpha e dois tipos de auxiliares de chefe.
- Cinco minibosses associados aos biomas.
- Yawara como chefe final.
- Comportamentos de predação, fuga, territorialidade e passividade.

### Mundo e eventos

- 14 pontos de interesse (POIs).
- Ciclo de dia e noite.
- Quatro eventos climáticos.
- Ecossistema com interações entre espécies.
- Sistema de amizades e encontros espontâneos.

## ⚔️ Possibilidades de builds

Não existe uma única configuração ideal para vencer. Os atributos e as evoluções permitem diferentes estratégias:

| Estilo | Características |
|---|---|
| Ágil | Pequeno porte, velocidade e esquiva |
| Brutal | Grande porte, dano, área e resistência |
| Social | Companheiros, Maracá, encontros e suporte contra Yawara |
| Forrageador | Alimentação e exploração, incluindo estratégias pacifistas e veganas |
| Ranged | Combate à distância com Zarabatana e Boleadeira |
| Corpo a corpo | Combate direto com Garras e Lança |
| Adaptativo | Resistência e adaptação a terreno, calor e frio |
| Híbrido | Combinação de diferentes atributos e especializações |

## 🎨 Arte, animação e áudio

O projeto utiliza pixel art com identidade visual própria, priorizando consistência entre personagens, criaturas e ambientes.

- Sprites animados de Aruan, animais e minibosses integrados aos recursos `assets/animations/*.tres`.
- Renderização em pixel art sem suavização e com escala padronizada.
- Cenários com densidade visual moderada.
- Músicas instrumentais originais em loop:
  - `music_menu.ogg`
  - `music_regions.ogg`
  - `music_boss.ogg`
- Efeitos sonoros originais para movimentação, ataques, coleta, dash e eventos importantes.
- Controles independentes de volume para Master, Music e SFX.

Alguns sprites antigos que não possuem equivalentes nos novos pacotes foram retirados da seleção de criaturas comuns, mas seus arquivos permanecem preservados para compatibilidade.

## 📚 Documentação

| Arquivo | Conteúdo |
|---|---|
| `GAMEPLAY_SYSTEMS.md` | Documentação detalhada dos sistemas de gameplay |
| `GUIA_INSTALACAO_ASSETS.md` | Orientações para instalação dos recursos gráficos |
| `SPRITES_TODO.md` | Inventário de sprites e pendências |
| `ATUALIZACAO_SPRITES_SOM_2026.md` | Atualizações de arte, animações e áudio |
| `FOLCLORE_DESIGN.md` | Referências e conceitos de identidade cultural |
| `SETTINGS_AND_LANGUAGES.md` | Configurações e idiomas |

## 🧪 Atalhos de teste

O projeto possui atalhos de desenvolvimento para facilitar a validação de mecânicas e acelerar testes:

| Tecla | Função |
|---|---|
| `F2` | Avançar quase imediatamente para o confronto com Yawara |
| `F3` | Adicionar XP |
| `F4` | Causar dano em Yawara |
| `F5` | Forçar o surgimento do miniboss do bioma atual |

> Esses atalhos são destinados a testes e não representam necessariamente a experiência normal de jogo.

## 👥 Equipe de desenvolvimento

Projeto desenvolvido por:

- Izabela Cassiano
- Davi Kauã
- Júlia Franco
- Nicolas Queiroga
- João Pedro Araújo
- Kauan Gustavo Braga

## 🚧 Desenvolvimento

Yawara é um projeto em desenvolvimento. Apesar da implementação de diversos sistemas e da existência de um protótipo jogável, podem ocorrer falhas de execução, inconsistências visuais ou problemas de balanceamento.

Os testes estáticos e as verificações de código não substituem a validação diretamente no motor Godot e durante as partidas.

Novas implementações, ajustes e correções continuam sendo realizados.
