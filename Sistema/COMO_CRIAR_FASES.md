# Como criar uma fase nova

O jogo usa um sistema central de fases (o autoload **`GameManager`**, em
`Sistema/game_manager.gd`). Adicionar uma fase nova são **3 passos**.

---

## Passo 1 — Crie a cena da fase

Crie/duplique uma cena de fase em `World/` (por exemplo `World/world_fase2.tscn`).
A forma mais fácil é **duplicar uma fase existente** e editar o mapa:

- No painel **FileSystem**, clique com o botão direito em `World/world_fase1.tscn`
  → **Duplicate...** → dê o nome novo (ex: `world_fase2.tscn`).
- Abra a cópia e monte o nível (tiles, props, inimigos, etc.).

## Passo 2 — Garanta os 2 nós obrigatórios

Toda fase precisa ter:

1. **O Player** (`Player/player.tscn`) — posicionado no início da fase.
2. **A linha de chegada** — um nó `Area2D` chamado `LinhaDeChegada` que avisa
   o jogo quando a fase termina. Se você duplicou uma fase existente, ela **já
   vem pronta**. Se estiver criando do zero, confira que:
   - O `Area2D` usa o script `World/fim.gd`.
   - Tem um `CollisionShape2D` filho (em `position = (0, 0)`) cobrindo o fim do nível.
   - O sinal `body_entered` está conectado ao método `_on_body_entered`.

> ⚠️ Dica do bug clássico: **a posição da chegada vai no nó `Area2D`**, não no
> `CollisionShape2D`. Deixe o CollisionShape em `(0,0)` e mova o Area2D.

## Passo 3 — Registre a fase no GameManager

Abra `Sistema/game_manager.gd` e adicione **uma linha** no array `FASES`,
na ordem em que a fase deve aparecer/desbloquear:

```gdscript
const FASES := [
    { "nome": "Tutorial", "cena": "res://World/world.tscn" },
    { "nome": "Fase 1",   "cena": "res://World/world_fase1.tscn" },
    { "nome": "Fase 2",   "cena": "res://World/world_fase2.tscn" },  # <- nova
]
```

- `nome` → texto que aparece no botão da tela de seleção.
- `cena` → caminho da cena (`res://World/...`).

**Pronto.** A tela de seleção cria o botão sozinha, e a fase desbloqueia quando
o jogador termina a fase anterior.

---

## Como funciona o desbloqueio

- A **primeira fase** da lista já começa liberada.
- Ao tocar a linha de chegada, o jogo **libera a próxima** e volta ao menu.
- O progresso é salvo em disco (`user://progresso.save`), então sobrevive a
  reinícios do jogo.

### Durante o playtesting

Para liberar todas as fases de uma vez (sem precisar zerar uma por uma), abra
`Sistema/game_manager.gd` e troque no topo:

```gdscript
const DESBLOQUEAR_TUDO := true   # false = progressão normal
```

> Lembre de voltar para `false` antes de entregar a versão final.

### Resetar o progresso salvo

Se quiser testar a progressão do zero, apague o arquivo de save. No Windows ele
fica em:

```
%APPDATA%\Godot\app_userdata\Avalanche\progresso.save
```

---

## Resumo (cola rápida)

1. Duplicar `world_fase1.tscn` → montar o nível.
2. Conferir **Player** + **LinhaDeChegada** (Area2D com `fim.gd`).
3. Adicionar `{ "nome": "...", "cena": "res://World/..." }` no `FASES` do `game_manager.gd`.
