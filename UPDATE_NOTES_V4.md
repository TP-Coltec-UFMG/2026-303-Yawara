# Atualização V4 — menu, HUD e fauna

## Menu inicial
- Janela padrão agora abre em 1152×648, mantendo canvas lógico 1280×720.
- Modo janela calcula um tamanho 16:9 seguro com margem para barra de tarefas/bordas.
- Menu inicial recebeu margens menores, painéis mais compactos e clipping para impedir elementos fora da tela.
- Mantido suporte a tela cheia via configurações/F11/Alt+Enter.

## HUD durante a partida
- O sistema de `show_banner()` foi desativado visualmente.
- Frases grandes no centro da tela não aparecem mais durante o gameplay.
- Informações permanentes do HUD, barras, objetivos e telas de evolução/build continuam funcionando.

## Sprites enviados
- As 4 imagens fornecidas foram preservadas em `assets/sprites/creatures/source_sheets/` e convertidas para PNG.
- Foram recortados 19 sprites PNG utilizáveis para criaturas comuns.
- Foram adicionadas 19 espécies à base do ecossistema: capivara-amazônica, ema, mico-leão-dourado, quero-quero, arara, tatu-peba, capivara do Pantanal, paca, graxaim, queixada, carcará, tamanduá-bandeira, quati, veado-campeiro, onça-pintada corrompida, gato-do-mato, lobo-guará, jaguatirica corrompida e bugio.
- O tamanho visual dos sprites comuns foi aumentado levemente para melhor leitura em jogo.

## Observação sobre JPEG
Godot importa JPEG normalmente, mas JPEG não é ideal para sprites porque não oferece transparência real e cria artefatos de compressão. Por isso as folhas JPEG recebidas foram convertidas para PNG antes de entrarem como fonte do projeto.
