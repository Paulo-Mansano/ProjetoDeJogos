extends Node

# ==========================================================================
#  GameManager (Autoload)
#  Centraliza a lista de fases, o progresso de desbloqueio e a navegacao
#  entre cenas. Adicionar uma fase nova = uma linha em FASES.
# ==========================================================================

# --- DEV ---
# Em true, todas as fases ficam destravadas (util para playtesting).
# Em false, o jogador precisa concluir uma fase para liberar a proxima.
const DESBLOQUEAR_TUDO := false

# --- LISTA DE FASES (ordem = ordem de progressao) ---
# nome  -> texto que aparece no botao da tela de selecao
# cena  -> caminho da cena da fase
const FASES := [
	{ "nome": "Tutorial", "cena": "res://World/world.tscn" },
	{ "nome": "Fase 1", "cena": "res://World/world_fase1.tscn" },
	{ "nome": "Fase 2", "cena": "res://World/world_fase2.tscn" },
]

const ARQUIVO_PROGRESSO := "user://progresso.save"
const CENA_SELECAO := "res://telainicial/tela_selecao.tscn"

# Quantas fases estao liberadas. A primeira sempre esta.
var fases_desbloqueadas := 1
# Indice da fase em jogo no momento (para saber qual e a "proxima").
var fase_atual := -1


func _ready() -> void:
	_carregar_progresso()


# --- TELA CHEIA ---
# F11 alterna entre janela e tela cheia em qualquer cena do jogo.
# O pixel art continua nitido porque o projeto usa escala inteira
# (window/stretch/scale_mode = "integer").
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			alternar_tela_cheia()


func alternar_tela_cheia() -> void:
	var modo := DisplayServer.window_get_mode()
	if modo == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


# --- NAVEGACAO ---

func iniciar_fase(indice: int) -> void:
	if indice < 0 or indice >= FASES.size():
		push_error("GameManager: indice de fase invalido: %d" % indice)
		return
	if not esta_desbloqueada(indice):
		return
	fase_atual = indice
	get_tree().change_scene_to_file(FASES[indice]["cena"])


# Chamada pela linha de chegada (fim.gd) ao concluir a fase.
func completar_fase() -> void:
	var proxima := fase_atual + 1
	# Libera a proxima fase, se existir e ainda estiver travada.
	if proxima < FASES.size() and proxima >= fases_desbloqueadas:
		fases_desbloqueadas = proxima + 1
		_salvar_progresso()
	# Por enquanto sempre volta para a tela de selecao (a tela de vitoria
	# esta bugada). Quando ela for consertada, da para rotear aqui.
	voltar_ao_menu()


func voltar_ao_menu() -> void:
	get_tree().change_scene_to_file(CENA_SELECAO)


# --- CONSULTAS ---

func esta_desbloqueada(indice: int) -> bool:
	if DESBLOQUEAR_TUDO:
		return true
	return indice < fases_desbloqueadas


# --- PERSISTENCIA ---

func _salvar_progresso() -> void:
	var f := FileAccess.open(ARQUIVO_PROGRESSO, FileAccess.WRITE)
	if f:
		f.store_32(fases_desbloqueadas)
		f.close()


func _carregar_progresso() -> void:
	if not FileAccess.file_exists(ARQUIVO_PROGRESSO):
		return
	var f := FileAccess.open(ARQUIVO_PROGRESSO, FileAccess.READ)
	if f:
		fases_desbloqueadas = max(1, f.get_32())
		f.close()
