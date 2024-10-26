extends Node2D

# Dicionários e variáveis principais
var posicoes_toques = {}
var distancia_inicial = 0
var pincou = false
var fator_zoom_in = 1.01
var fator_zoom_out = 0.99

# Definição das tolerâncias
var distancia_3_estrelas = 0.10  
var distancia_2_estrelas = 0.20  
var distancia_1_estrela = 0.40  

# Limites de zoom
var tamanho_maximo_zoom = Vector2(1.65, 1.65)
var tamanho_minimo_zoom = Vector2(0.5, 0.5)

# Vetores para imagens e traçados
var imagens = []
var tracados = []

# Variáveis para a imagem e traçado atualmente ativos
var imagem_atual = Sprite2D
var tracado_atual = Sprite2D

@onready var pegou = $pegou
@onready var soltou = $soltou


func _ready():
	imagens = [$estrela_teste, $bola_teste, $maca_teste, $quadrado_teste]  # Substitua pelas referências corretas
	tracados = [$estrela_tracado, $bola_tracado, $maca_tracado, $quadrado_tracado]  # Substitua pelas referências corretas
	
	selecionar_imagem_aleatoria()

# Função para selecionar uma imagem e seu traçado aleatoriamente
func selecionar_imagem_aleatoria() -> void:
	var indice = randi() % imagens.size()
	imagem_atual = imagens[indice]
	tracado_atual = tracados[indice]
	
	# Exibe a imagem selecionada e esconde as outras
	for imagem in imagens:
		imagem.visible = false
	imagem_atual.visible = true
	
	for imagem2 in tracados:
		imagem2.visible = false
	tracado_atual.visible = true

# Função de zoom in
# Função para o evento de entrada na área de zoom in
func _on_area_direita_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			posicoes_toques[event.index] = event.position
		else:
			posicoes_toques.erase(event.index)
			
	elif event is InputEventScreenDrag:
		if event.index in posicoes_toques:
			posicoes_toques[event.index] = event.position
	
	if posicoes_toques.size() == 2:
		var toque_1_pos = posicoes_toques.values()[0]
		var toque_2_pos = posicoes_toques.values()[1]
		
		# Início do movimento de pinça
		if not pincou:
			distancia_inicial = toque_1_pos.distance_to(toque_2_pos)
			pincou = true
			
		else:
			var distancia_atual = toque_1_pos.distance_to(toque_2_pos)
			var fator_zoom = distancia_atual / distancia_inicial
			
			if fator_zoom > 1.03:
				# Calcula a nova escala
				var nova_escala = imagem_atual.scale * fator_zoom_in
				# Verifica se a nova escala não excede o tamanho máximo
				if nova_escala.x <= tamanho_maximo_zoom.x and nova_escala.y <= tamanho_maximo_zoom.y:
					imagem_atual.scale = nova_escala  # Aplica a nova escala
					#soltou.stop()
					soltou.play()
			
			
			distancia_inicial = distancia_atual

# Função para o evento de entrada na área de zoom out
func _on_area_esquerda_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			posicoes_toques[event.index] = event.position
		else:
			posicoes_toques.erase(event.index)
			
	elif event is InputEventScreenDrag:
		if event.index in posicoes_toques:
			posicoes_toques[event.index] = event.position
	
	if posicoes_toques.size() == 2:
		var toque_1_pos = posicoes_toques.values()[0]
		var toque_2_pos = posicoes_toques.values()[1]
		
		# Início do movimento de pinça
		if not pincou:
			distancia_inicial = toque_1_pos.distance_to(toque_2_pos)
			pincou = true
			
		else:
			var distancia_atual = toque_1_pos.distance_to(toque_2_pos)
			var fator_zoom = distancia_atual / distancia_inicial
			
			if fator_zoom < 0.97:  # Zoom out
				# Calcula a nova escala
				var nova_escala = imagem_atual.scale * fator_zoom_out
				# Verifica se a nova escala não é menor que o tamanho mínimo
				if nova_escala.x >= tamanho_minimo_zoom.x and nova_escala.y >= tamanho_minimo_zoom.y:
					imagem_atual.scale = nova_escala  # Aplica a nova escala
					#soltou.stop()
					soltou.play()
			
			
			distancia_inicial = distancia_atual
			
			

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and not event.pressed:
		if posicoes_toques.size() == 0:
			pincou = false

# Função para verificar a proximidade entre as escalas
func verificar_proximidade_escalas() -> int:
	var diferenca_escala_x = abs(imagem_atual.scale.x - tracado_atual.scale.x)
	var diferenca_escala_y = abs(imagem_atual.scale.y - tracado_atual.scale.y)
	
	var diferenca_media = (diferenca_escala_x + diferenca_escala_y) / 2.0
	
	if diferenca_media <= distancia_3_estrelas:
		return 3
	elif diferenca_media <= distancia_2_estrelas:
		return 2
	elif diferenca_media <= distancia_1_estrela:
		return 1
	else:
		return 0

# Função chamada ao apertar o botão para verificar a pontuação
func _on_button_button_down() -> void:
	pegou.play()
	var pontuacao = verificar_proximidade_escalas()
	match pontuacao:
		3:
			Global.estrelas = 3
			await get_tree().create_timer(0.2).timeout
			get_tree().change_scene_to_file("res://game_over.tscn")
		2:
			Global.estrelas = 2
			await get_tree().create_timer(0.2).timeout
			get_tree().change_scene_to_file("res://game_over.tscn")
		1:
			Global.estrelas = 1
			await get_tree().create_timer(0.2).timeout
			get_tree().change_scene_to_file("res://game_over.tscn")
		0:
			Global.estrelas = 0
			await get_tree().create_timer(0.2).timeout
			get_tree().change_scene_to_file("res://game_over.tscn")
