# Checklist de teste — Godot 4.7.x

## 1. Abertura

- Abrir `project.godot`.
- Confirmar que a cena inicial abre sem dependências externas.
- Pressionar `F6/F5` e iniciar a jornada.

## 2. Controles

- WASD/setas movem.
- Ambos os botoes do mouse/J atacam.
- Espaço dá dash.
- F usa Ultimate; T alterna Ultimate; G alterna dash.
- C ou Tab abre/fecha a build e pausa a run.
- E interage com pontos de encontro.
- Q/R alternam armas desbloqueadas.
- 1–5 selecionam arma desbloqueada diretamente.

## 3. Mundo infinito

- Caminhar continuamente em uma direção por pelo menos 30 segundos.
- Confirmar que novos chunks aparecem e não existe borda invisível.
- Confirmar que aparecem manchas de biomas diferentes.
- Confirmar árvores/pedras, frutas e lagos.
- Entrar em lago e verificar redução de velocidade.

## 4. Ecossistema

Observar sem atacar por 1–2 minutos:

- presas devem fugir de predadores;
- predadores devem perseguir presas;
- passivos devem vagar sem perseguir o jogador;
- territoriais só reagem em curta distância;
- predadores podem matar outros animais sem gerar XP para o jogador.

Ataque um animal passivo e confirme que ele passa a reagir/fugir e que Social cai.

Com Social suficiente, aproxime-se de animal não predador e pressione E. Ele deve virar companheiro e seguir o jogador.

## 5. Builds de tamanho

Use F3 repetidamente para testar evoluções:

Pequena:
- Leveza do Mico;
- Asas da Arara;
- Passos do Curupira.

Confirmar: corpo menor, bem mais velocidade/esquiva, ataques mais rápidos e área menor.

Grande:
- Corpo do Queixada;
- Carapaça do Tatu;
- Vigor da Capivara.

Confirmar: corpo maior, dano/área muito maiores, hitbox maior e mobilidade/esquiva/recarga piores.

Abrir C e conferir `Tamanho`, `Dano`, `Área de Ataque` e `Esquiva`.

## 6. Armas

A run começa com Garras e Lança.

- Garras: golpe amplo perto do jogador.
- Lança: golpe longo e mais estreito.
- Zarabatana: projétil.
- Boleadeira: projétil azul que desacelera criatura.
- Maracá: pulso circular; com Social alto deve ficar mais forte e não deve ferir fauna pacífica que ainda não esteja hostil.

As três últimas podem ser obtidas em comunidade com Social 12 ou mais.

## 7. Frutas / pacifismo

- Esperar perto de árvores: elas devem derrubar frutas periodicamente.
- Encontrar frutas diretamente no chão.
- A comida não deve ser atraída. Ao passar por cima, deve iniciar a alimentação automaticamente.
- Confirmar quatro mordidas com intervalo de Feeding Speed e alteração visual a cada mordida.
- Colocar duas comidas próximas e confirmar que somente a mais próxima é consumida.
- Atacar árvores e pedras: elas devem permanecer inteiras e não gerar recompensas pelo golpe.
- Segurar E deve consumir em quatro mordidas; soltar E deve interromper e preservar o progresso da comida.
- Cada mordida deve curar e dar Progress; a última deve render o dobro.
- Matar uma criatura não deve criar orbe de XP e deve sempre deixar carne.
- Uma criatura morta por outro animal também deve deixar carne.

## 8. Pontos de encontro

Localizar ícone circular no mundo e usar E.

Testar:
- Comunidade: conversa, arma, descanso.
- Santuário: respeito, bênção, histórias.
- Natural: observar, companheiro, forragear.

Opções com Social insuficiente devem aparecer desabilitadas.

## 9. Calor, frio e dia/noite

- O HUD deve alternar Dia/Noite.
- Na Caatinga durante Dia, o HUD deve indicar CALOR e o jogador perde vida enquanto adaptação é insuficiente.
- No Sul durante Noite, o HUD deve indicar FRIO e o jogador perde vida enquanto adaptação é insuficiente.
- Evoluções de adaptação devem reduzir/remover essas penalidades.

## 10. Mini-chefes

F5 força o mini-chefe do bioma atual para teste.

- Em uma run normal, confirmar spawn automatico exatamente ao cruzar 03:00 e 06:00.
- Confirmar que cada Guardião alterna os quadros de caminhada e vira horizontalmente ao mudar de direção.
- Se o primeiro ainda estiver vivo em 06:00, o segundo deve ficar enfileirado e surgir apos liberar o slot.

Derrotar cada tipo e confirmar o banner/recompensa:
- Norte: os projéteis do Mapinguari devem sofrer redução de Resistência a Veneno; recompensa Coração do Mapinguari.
- Nordeste: Sol do Sertão.
- Centro-Oeste: Passo do Pantanal.
- Sudeste: Casca da Serra.
- Sul: Brasa da Teiniaguá.

Abrir C e confirmar que o poder aparece no resumo.

## 11. Yawara

- F2 avanca o cronometro para 07:58.
- Yawara deve aparecer perto do jogador mesmo estando muito longe da origem.
- F4 causa dano para testar fases rapidamente.
- Confirmar barra de boss, fases, projeteis, meteoros marcados no chao, baforada venenosa, adds, vitoria e derrota.
- Se houver Social/encontros pacíficos suficientes, confirmar o banner de apoio social e aliados ajudando contra Yawara.

## 12. Sistemas ampliados

- Menu: testar Normal, Pressure 20 e Endless.
- Selecionar Genetic e uma segunda Genetic via Splicing.
- Em level up, conferir cor/nome da raridade; X faz reroll e U eleva raridade quando houver Mutagen.
- C/Tab deve mostrar três colunas, apenas Evolutions adquiridas, retrato, cinco afinidades, Mutagen, Genetic, loadout e 51 stats internos ativos.
- Observar variantes +/++, Alphas dourados, Plating e mudancas de ataque das 12 familias.
- Interagir com varios dos 14 POIs e testar tanto absorver quanto preservar.
- Em Endless, derrotar Yawara e confirmar que a partida continua e libera niveis sem fim.
