# Configurações e idiomas

Esta versão consolida o sistema de configurações no Autoload `SettingsManager`.

## Vídeo
- Tela cheia é aplicada imediatamente com `DisplayServer.window_set_mode`.
- Ao voltar para janela, o jogo retorna para 1280x720 e centraliza a janela.
- Atalhos: `F11` ou `Alt+Enter`.
- A preferência é salva em `user://ecos_settings.cfg`.

> Observação de teste no editor: dependendo da configuração do editor Godot, a execução embutida pode impedir uma janela de ocupar a tela inteira. Para validar tela cheia de forma fiel, execute o jogo em janela separada ou o executável exportado.

## Áudio
- Master -> bus `Master`
- Música -> bus `Music`
- Efeitos -> bus `SFX`
- O `AudioManager` cria players apontando para os buses corretos.

## Idiomas
Disponíveis no menu de configurações:
- Português (Brasil)
- English
- Español

A mudança é imediata nas principais telas: menu inicial, configurações, pausa, HUD, tela de evolução, tela de build e resultado final. A preferência é persistida.

## Acessibilidade
- Alto contraste / contorno de texto
- Escala global de textos
- Redução de flashes
- Redução de movimento da câmera
- Tremor de tela on/off
- Intensidade do tremor
- Assistência de mira: desligada, leve, forte

As telas principais registram seus controles no `SettingsManager`, incluindo elementos criados dinamicamente em Build/Encontros.
