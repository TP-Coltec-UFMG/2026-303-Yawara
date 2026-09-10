# UPDATE NOTES V5

- Integrados novos assets dos pacotes enviados (Ninja Adventure + EPIC Grass Land + folha de bases secretas).
- Adicionado protagonista animado (Ninja Green) com idle, walk, attack e death.
- Adicionado suporte a inimigos animados por spritesheets e também a fauna brasileira recortada em frames.
- Gerados novos pisos/biomas em `assets/sprites/regions/`.
- Extraídos props de cenário em `assets/sprites/world/`.
- Mantidas as artes brasileiras anteriores e incluídos frames automáticos em `assets/sprites/creatures/frames/`.

- Integrados sprites personalizados do usuário em `assets/sprites/creatures/source_sheets/user_custom/`.
- Aplicadas sequências personalizadas de animação para: arara, capivara, carcará, ema, graxaim e paca.
- Extras aproveitados do pack enviado: veado-campeiro, onça corrompida, jaguatirica corrompida e gato-do-mato.
- Ajustado o carregamento de animações locais para suportar sequências maiores (ex.: paca com 7 frames).

- Sprites do player e dos inimigos ajustados para usar apenas esquerda/direita (sem cima/baixo), evitando o efeito de rodar.
- Removido o quadriculado/contorno dos chunks do mapa.
- Biomas ficaram menores (`BIOME_SITE_SPACING = 3.0`) para aparecerem com mais frequência perto do jogador.
- O piso dos biomas agora recebe uma tonalização mais forte para diferenciar melhor floresta, pantanal, sertão e geada.
