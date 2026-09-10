# Sistemas implementados na V3

## Cronograma

- 03:00: primeiro guardiao do bioma atual.
- 06:00: segundo guardiao do bioma atual.
- 08:00: Yawara.
- Normal/Pressure: ate 02:00 para purificar Yawara.
- Endless: a run continua e escala depois da primeira purificacao.

## Conteudo de dados

- 51 stats internos validados em `StatDB`.
- 23 Genetics e Splicing de duas regras.
- 130 registros de Evolution/equipamento no catalogo.
- 16 ataques, 8 Ultimates, 9 movimentos.
- 4 raridades, reroll e upgrade de raridade por Mutagen.
- Alimentacao automatica ao passar sobre comida, em quatro mordidas com cooldown; Progress 10/30/90/300 por raridade e mordida final dobrada.
- Abates comuns, mini-chefes e Yawara deixam carne, nunca XP direto.
- Fruto Ancestral e dez ramos corporais; custos progressivos de Mutagen.
- 12 familias, cinco minibosses, dois adds e Yawara.
- 4 biomas, 14 POIs, quatro climas e ciclo dia/noite.

## Tela de build

- `C` ou `Tab` abre uma ficha em três colunas inspirada na referência.
- Evolutions adquiridas e níveis ficam à esquerda, com borda de raridade.
- Physical, Ability, Max HP, Social, Speed e retrato ficam no centro.
- Radar de Predator, Prey, Trickster, Imposing e Social mais barra de Mutagen.
- Atributos secundários ficam agrupados em Ofensiva, Sobrevivência, Consumo e Outros.

## Observacao de design

As cinco regioes foram condensadas em quatro biomas jogaveis: Grande Floresta (Amazonia + Mata Atlantica), Sertao de Pedra, Aguas do Pantanal e Campos de Geada. Os cinco guardioes continuam no pool; Grande Floresta possui Mapinguari e Corpo-Seco. Isso preserva os seis chefes totais contando Yawara.
