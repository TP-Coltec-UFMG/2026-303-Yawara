# Ecos do Brasil: Yawara — atualização de sprites e áudio

## Alterações

- As 17 animações do Aruan foram trocadas pelas do ZIP fornecido.
- Atualizadas as animações de 25 espécies e criaturas, 5 minibosses e as 3 fases de Yawara (33 conjuntos).
- Padronizado o recorte dos sprites, preservando pixel art sem antialiasing, ponto de contato e dimensão de cada recurso.
- Integradas 23 decorações fornecidas, aproveitando os quatro biomas sem aumentar a densidade excessiva.
- Fauna que não recebeu arte no novo pacote foi retirada **apenas do sorteio aleatório** do mundo, sem excluir scripts e funções especiais.
- Música instrumental **original** de exploração, menu e chefe, em arquivos OGG de loop.
- Efeitos originais WAV: ataque, passos, dash, dano, item, evolução, rugido do chefe, vitória e derrota.
- Volume pode ser ajustado em Configurações > Áudio, pelos canais Music e SFX.

## Testes recomendados na Godot

1. Importe `project.godot` em uma pasta nova (Godot 4.5 ou mais recente) e espere a indexação terminar.
2. Inicie uma partida e confirme o deslocamento do Aruan, áudio de passos, ataques, dash e consumo de alimentos.
3. Abra opções e teste controles independentes de música e efeitos.
4. Explore os quatro biomas; veja se os animais exibem os quadros novos sem glitches e em tamanho confortável.
5. No modo normal, confirme as aparições dos minibosses e a transição para Yawara.
6. Teste pausa, fim de partida, troca de armas, configurações e resolução.

**Limitação da validação:** As imagens, arquivos de som, recursos de cena e referências foram verificados estaticamente, mas o executável da Godot não está disponível neste ambiente, portanto não houve teste completo de gameplay. Não seria responsável garantir ausência total de bugs.
