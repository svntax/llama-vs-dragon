extends Node2D

const MessageScene = preload("res://Chat/Message.tscn")

@onready var nobody_who_chat: NobodyWhoChat = $NobodyWhoChat

@onready var chat_box: TextEdit = %ChatBox
@onready var response_label: RichTextLabel = %ResponseLabel
@onready var chat_history: ScrollContainer = %ChatHistory
@onready var chat_history_container: VBoxContainer = %ChatHistoryContainer

@onready var chat_thinking: bool = false

func _ready() -> void:
	nobody_who_chat.response_updated.connect(_on_response_updated)
	nobody_who_chat.response_finished.connect(_on_response_finished)

func add_message_to_history(message: String) -> void:
	var message_label = MessageScene.instantiate()
	message_label.set_text(message)
	chat_history_container.add_child(message_label)

func _on_response_updated(new_token: String) -> void:
	if chat_thinking:
		chat_thinking = false
		response_label.set_text("")
	
	response_label.add_text(new_token)

func _on_response_finished(response: String) -> void:
	add_message_to_history("Ignis:\n" + response)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("send_message"):
		chat_thinking = true
		chat_box.set_text(chat_box.text.strip_edges())
		
		var player_message = chat_box.get_text()
		add_message_to_history("You:\n" + player_message)
		nobody_who_chat.say(player_message)
		
		chat_box.set_text("")

func _on_history_button_pressed() -> void:
	chat_history.visible = not chat_history.visible
	if chat_history.visible:
		var scrollbar = chat_history.get_v_scroll_bar()
		chat_history.scroll_vertical = scrollbar.max_value
