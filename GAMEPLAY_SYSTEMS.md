# Sistemas — Ecos do Brasil: Yawara

## Loop da run

A preparação dura 8 minutos. O mapa é procedural e infinito: o jogo mantém apenas os chunks próximos do jogador carregados. Aos 3 e 6 minutos surge um guardião ligado ao bioma atual. Aos 8 minutos Yawara surge perto da posição atual e começa a luta final de até 2 minutos.

## Biomas procedurais

Os chunks pertencem a manchas de bioma geradas por células procedurais do tipo Voronoi. As fronteiras ficam irregulares e o mundo pode continuar indefinidamente; as cinco regiões brasileiras são condensadas em quatro biomas jogáveis:

1. Grande Floresta — Amazônia + Mata Atlântica/Serra
2. Sertão de Pedra — Caatinga
3. Águas do Pantanal — Cerrado/Pantanal
4. Campos de Geada — Pampas/Araucárias

Cada chunk gera árvores, pedras, decoração, frutas no chão e, ocasionalmente, lagos e pontos de encontro.

## Ecossistema vivo

A fauna não usa uma única IA de perseguição. Existem temperamentos:

- `predator`: caça criaturas do grupo presa e também pode caçar o jogador.
- `prey`: foge de predadores e foge do jogador se for provocada.
- `passive`: vagueia e só reage ao jogador se for atacada.
- `territorial`: tolera distância, mas reage quando invadem seu espaço; Social alto reduz a agressividade.

Predadores podem matar outras criaturas; toda criatura derrotada deixa carne no chão e nenhuma morte concede XP direto. Presas e passivos procuram alimento, predadores caçam presas, grupos mantêm distância entre si, ladrões roubam comida do chão, emboscadores reagem ao movimento e criaturas feridas podem fugir. Animais passivos/presas atacados pelo jogador reduzem Social. Com Social suficiente, aproxime-se e pressione `E` para tentar fazer amizade. Companheiros seguem o jogador, atacam predadores, mini-chefes e também ajudam contra Yawara.

## Build pequena x grande

`Tamanho` é mecânico, não apenas visual.

Corpos pequenos:
- ganham bastante velocidade;
- atacam com menor intervalo;
- recebem um bônus forte de esquiva;
- têm hitbox e área de ataque menores;
- sacrificam dano bruto.

Corpos grandes:
- causam muito mais dano físico;
- aumentam fortemente a área de ataque;
- têm hitbox maior;
- atacam mais devagar;
- perdem velocidade e esquiva.

Evoluções como `Leveza do Mico` e `Asas da Arara` puxam para builds pequenas; `Corpo do Queixada`, `Carapaça do Tatu`, `Vigor da Capivara` e o poder da Serra puxam para builds grandes.

## Armas

Troque com `Q/R` ou use `1–5` quando estiverem desbloqueadas.

- Garras: corpo a corpo amplo, escala fortemente com tamanho.
- Lança de Madeira: alcance longo, lento e pesado.
- Zarabatana: projétil rápido; sofre pouca influência negativa de tamanho pequeno.
- Boleadeira: projétil de controle que aplica lentidão.
- Maracá Ancestral: pulso circular cujo dano cresce com Social e afinidades; ignora fauna pacífica e atinge predadores, criaturas já hostis e chefes.

A run começa com Garras + Lança. As outras técnicas podem ser aprendidas em encontros sociais.

## Mini-chefes de bioma

Os guardiões aparecem exatamente aos 03:00 e 06:00, escolhidos pelo bioma ocupado naquele instante. Cada guardião concede um poder permanente naquela run, carne rara e, quando a Genetic permitir, um Fruto Ancestral:

- Norte — Mapinguari Ancestral → **Coração do Mapinguari**: o guardião usa projéteis venenosos; a recompensa dá regeneração forte, imunidade a veneno e maior atração de frutas.
- Nordeste — Cabra Cabriola → **Sol do Sertão**: resistência total ao calor e leque de fogo em todo ataque.
- Centro-Oeste — Minhocão do Pantanal → **Passo do Pantanal**: ignora lama/água e dash gera impacto.
- Sudeste — Corpo-Seco da Serra → **Casca da Serra**: resistência, tamanho e dano físico.
- Sul — Teiniaguá Corrompida → **Brasa da Teiniaguá**: resistência total ao frio e projéteis radiais a cada terceiro ataque.

Cada recompensa só é obtida uma vez por run.

## Frutas e run pacifista/vegana

Árvores soltam frutas naturalmente ao longo do tempo e não podem ser quebradas, assim como as pedras. Também existem frutas e carne no chão. Ao passar sobre o alimento, a primeira mordida acontece imediatamente e as próximas respeitam Feeding Speed. Alimentos comuns usam quatro mordidas e a última concede Progress dobrado. Somente o alimento mais próximo é consumido, evitando consumir pilhas inteiras ao mesmo tempo.

- recupera PV;
- fornece Progress durante cada mordida;
- alimenta a barra de progresso alimentar;
- aumenta afinidade;
- não exige matar fauna.

As raridades rendem 10/30/90/300 Progress total. Ao completar 100 de progresso alimentar, o jogador recebe um pequeno ganho permanente de regeneração. `Faro do Mão-pelada` torna esse estilo mais forte.

A tela `C` ou `Tab` exibe somente Evolutions adquiridas, atributos principais e secundários, retrato, cinco afinidades e Mutagen.

## Social

Social afeta diretamente:

- distância de agressão de predadores;
- territorialidade;
- chance/requisito para amizade com animais;
- opções disponíveis em pontos de encontro;
- acesso a novas armas;
- força do Maracá Ancestral;
- progressão pacífica;
- apoio no confronto final: encontros pacíficos + Social alto concedem proteção/regeneração e podem chamar aliados.

Matar animais passivos/presas reduz Social. Conversar, observar, respeitar santuários e fazer amizades aumenta Social.

## Pontos de encontro

Chunks podem gerar três categorias:

- Comunidade: conversa, descanso e aprendizado de armas.
- Santuário: adaptação, histórias, afinidade ou bênção com Loucura.
- Natural: observação pacífica, forrageamento e companheiros.

Aproxime-se e pressione `E`.

## Clima, horário e terreno

O ciclo alterna Dia/Noite a cada 60 segundos (ciclo completo de 120 s).

- Caatinga durante o dia causa dano de calor até a Adaptação ao Calor chegar aproximadamente a 135%.
- Sul durante a noite causa dano de frio até a Adaptação ao Frio chegar aproximadamente a 135%.
- Lagos/brejos reduzem fortemente a velocidade.
- Centro-Oeste possui penalidade menor de terreno mesmo em terra firme.
- Adaptação a Terreno reduz essas penalidades.

O HUD indica Dia/Noite, Água/Lama e os perigos de calor/frio.

## Atalhos de desenvolvimento

- `F2`: reduz preparação para 2 s e testa Yawara.
- `F3`: adiciona XP.
- `F4`: causa dano em Yawara.
- `F5`: força o mini-chefe do bioma atual, quando nenhum já está ativo.
