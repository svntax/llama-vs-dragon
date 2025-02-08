extends Node2D

const MessageScene = preload("res://Chat/Message.tscn")

@onready var loading_ui: CanvasLayer = $LoadingUI

@onready var nobody_who_chat: NobodyWhoChat = $NobodyWhoChat
@onready var nobody_who_embedding: NobodyWhoEmbedding = $NobodyWhoEmbedding

@onready var chat_box: TextEdit = %ChatBox
@onready var response_label: Label = %ResponseLabel
@onready var chat_history: ScrollContainer = %ChatHistory
@onready var chat_history_container: VBoxContainer = %ChatHistoryContainer

@onready var action_embeddings

@onready var chat_thinking: bool = false

func _ready() -> void:
	loading_ui.show()
	await get_tree().create_timer(0.5).timeout
	nobody_who_embedding.start_worker()
	nobody_who_chat.start_worker()
	await get_tree().create_timer(1).timeout
	action_embeddings = await generate_action_embeddings()
	
	nobody_who_chat.response_updated.connect(_on_response_updated)
	nobody_who_chat.response_finished.connect(_on_response_finished)
	
	loading_ui.hide()

func add_message_to_history(message: String) -> void:
	action_embeddings = await generate_action_embeddings()
	var message_label = MessageScene.instantiate()
	message_label.set_text(message)
	chat_history_container.add_child(message_label)

func _on_response_updated(new_token: String) -> void:
	if chat_thinking:
		chat_thinking = false
		response_label.set_text("")
	
	# Clean up special characters
	response_label.text += new_token.replace("–", "-").replace("—", "-").replace("…", "...")

func _on_response_finished(response: String) -> void:
	response_label.text = response_label.text.strip_edges()
	var response_clean = response_label.text.strip_edges().replace("\n", "")
	add_message_to_history("Ignis:\n" + response_clean)
	if not response_clean.is_empty():
		# Split into sentences
		var regex = RegEx.new()
		regex.compile("[^.!?]+[.!?]")
		var sentences = regex.search_all(response_clean)
		for sentence in sentences:
			var clean_sentence = sentence.get_string().strip_edges()
			if clean_sentence.is_empty(): continue
			var action = await match_sentence(clean_sentence)
			if action != null:
				print(action)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("send_message"):
		chat_thinking = true
		chat_box.set_text(chat_box.text.strip_edges())
		
		var player_message = chat_box.get_text()
		add_message_to_history("You:\n" + player_message)
		nobody_who_chat.say(player_message)
		
		chat_box.set_text("")

func generate_action_embeddings():
	# These will be used to detect if the player has died or obtained treasure.
	var sentences = {
		"died": [
			"I will eat you alive.",
			"A good meal awaits.",
			"Perish under my fiery breath.",
			"I will burn you to a crisp.",
			"I'll stomp and crush you.",
			"You are dead meat."
		],
		"give_treasure": [
			"You may have some treasure.",
			"I will give you some treasure.",
			"I can spare some treasure for you.",
			"You can have some gold.",
			"Take some gold and leave.",
			"I will part with some of my gold.",
			"Here is one coin for you.",
			"Grab some treasure and never come back.",
			"Take some trinkets before I change my mind."
		]
	}
	var embeddings = {"died": [], "give_treasure": []}
	for action in sentences:
		for sentence in sentences[action]:
			# TODO: Instead of storing embeddings, we store the sentences and
			# create embeddings from them later because of a weird bug with
			# similarity values being incorrect if embeddings are created here.
			#embeddings[action].append(await nobody_who_embedding.embed(sentence))
			embeddings[action].append([action, sentence])
	
	return embeddings

func match_sentence(sentence: String):
	# Test if the dragon has taken an action.
	# Returns the name of the action if yes
	# Returns null otherwise
	var max_similarity = 0
	var most_similar = null
	var input_embed = await nobody_who_embedding.embed(sentence)
	for action in action_embeddings:
		for embedding in action_embeddings[action]:
			var current_sentence_embed = await nobody_who_embedding.embed(embedding[1])
			var similarity = NobodyWhoEmbedding.cosine_similarity(input_embed, current_sentence_embed)
			if similarity > max_similarity:
				most_similar = action
				max_similarity = similarity
	
	var threshold = 0.85
	print("Max Similarity: " + str(max_similarity) + "\nAction: " + most_similar)
	if max_similarity > threshold:
		return most_similar
	
	return null

func _on_history_button_pressed() -> void:
	chat_history.visible = not chat_history.visible
	if chat_history.visible:
		var scrollbar = chat_history.get_v_scroll_bar()
		chat_history.scroll_vertical = scrollbar.max_value

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://TitleScreen.tscn")
