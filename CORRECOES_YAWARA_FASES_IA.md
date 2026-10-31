# Correções de Yawara — sprites, IA e avisos de ataque

Nesta versão, feita a partir de `Yawara_HUD_Menu_Vida_Atualizado.zip`, o foco foi o confronto final.

## O que mudou

- A chefe agora **circula** Aruan mantendo uma distância de combate, aproxima de longe e recua quando está perto demais.
- A investida ganhou preparação de aproximadamente 0,46 s, direção definida antes de avançar e recuperação após a ação.
- Ataques de meteoros ficaram menos frequentes e com 2, 3 ou 4 áreas por onda, dependendo da fase (antes até 7 com intervalo curto).
- A nuvem de veneno usa 3 áreas menores e duração mais curta.
- As retículas vermelhas em formato de mira foram trocadas por marcadores discretos, com pequenos cantos coloridos e barra de preparação.
- Há limite de 8 áreas de perigo simultâneas, para impedir a tela de ficar coberta.
- Foram isolados **24 quadros validados** das animações das três fases, usando quadros limpos no lugar dos que tinham pedaços de outros quadros, principalmente na fase 2.
- Foram preservados HP, progressão de três fases, recompensas e áudio originais.

## Como testar na Godot

1. Abra `project.godot` na Godot 4.5 ou superior e pressione **F5**.
2. Inicie uma partida e use **F2** na janela de jogo para avançar até a batalha final (modo de depuração).
3. Observe se a chefe mantém espaço para lutar, se há tempo para desviar dos golpes e se os indicadores de ataque não cobrem a tela.
4. Use **F4** algumas vezes durante o combate para reduzir a vida de Yawara e testar as fases 2 e 3.
5. Observe as animações de cada fase e confirme se não há pedaços soltos.

**Validação realizada:** recursos, PNGs e nomes de animação foram conferidos por script. A execução dentro da Godot não pôde ser testada neste ambiente; qualquer erro de execução ainda deve ser relatado com a mensagem do depurador.
