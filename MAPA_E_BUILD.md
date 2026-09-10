# Mapa procedural e tela de Build

## Mapa

O mapa antigo de cinco áreas fixas foi substituído por `ProceduralWorld` + `ProceduralChunk`.

- Chunk: 960×960 pixels.
- São mantidos 5×5 chunks ao redor do jogador.
- Ao caminhar, chunks distantes são removidos e novos chunks são gerados.
- A posição do jogador nunca é limitada: o mundo pode continuar em qualquer direção.
- Os biomas usam células procedurais tipo Voronoi, formando manchas irregulares com vários chunks em vez de cinco áreas fixas.
- A escolha de bioma é determinística para a seed da run e continua funcionando em coordenadas positivas e negativas.

Cada chunk pode criar árvores, pedras, frutas, lago/brejo e ponto de encontro. A fauna é controlada separadamente pelo `game_world.gd`, portanto pode atravessar chunks e interagir com outras criaturas.

## Build (C ou Tab)

A tecla `C` ou `Tab` pausa e abre uma ficha em três colunas, no mesmo arranjo visual da referência:

- esquerda: apenas Evolutions adquiridas, com níveis e bordas de raridade;
- centro superior: atributos principais e retrato do personagem;
- centro inferior: radar de Predator, Prey, Trickster, Imposing e Social, além da barra de Mutagen;
- direita: atributos secundários agrupados por categoria;
- resumo compacto de nível, Progress, arma, Ultimate, dash, Genetic e 51 stats internos;
- Físico;
- Habilidade;
- PV máximo;
- Social;
- Velocidade;
- Dano;
- Recargas;
- Área de Ataque;
- Penalidade de Ataque;
- Tamanho;
- Regeneração;
- Loucura;
- Resistência a Dano;
- Resistência a Veneno;
- Esquiva;
- Adaptação a Calor;
- Adaptação a Frio;
- Progresso de Comida;
- Velocidade de Consumo;
- Distância de Consumo;
- Adaptação a Terreno;
- Sentidos;
- arma atual, Ultimate, dash, Genetic e Mutagen.

O preview central também usa o atributo Tamanho, então builds grandes e pequenas aparecem com proporções diferentes mesmo sem sprites.
