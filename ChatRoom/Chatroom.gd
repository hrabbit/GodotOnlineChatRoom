extends CanvasLayer

@onready var message = $vbxChatRoomContainer/HBoxContainer2/txtMessage
@onready var history = $vbxChatRoomContainer/HBoxContainer/txtChatHistory
@onready var users : ItemList = $vbxChatRoomContainer/HBoxContainer/itlUsers

func _ready() -> void:
	#Connect to our custom signal in Network
	Network.connect("update_user_list",Callable(self,"update_user_list"))
	multiplayer.connect("peer_disconnected",Callable(self,"user_left"))
	
	# if we're server just update list
	if(multiplayer.get_unique_id() == 1): 
		update_user_list() 
	
#Called when a user enters the chat, clear the list and repopulate withupdated one
func update_user_list():
	users.clear()
	for i in Network.user_list:
		var data = Network.user_list[i]
		users.add_item(Network.user_list[i])

#Remove user by it's ID and repopulate userlist
func user_left(ID):
	print(ID)
	Network.user_list.erase(str(ID)) # remove  from user_list
	update_user_list()

func _physics_process(delta: float) -> void:
	if(Input.is_action_just_pressed("return_key")):
		#Check it's not an empty space, if it isn't, then sendmessage
		if(message.text != "\n"):
			#Create the message and tell everyone else to add it to their history
			rpc("send_chat",create_message(message.text))
			history.text += create_message(message.text)
			message.text = ""
		else:
			message.text = ""

@rpc("any_peer") func send_chat(txt):
	history.text += txt
	history.text += ""

#We're using richtextlabel which allows us to format
func create_message(new_message) -> String:
	return "[b][color=" + Network.user_color +"]" + Network.user_name + ": "+"[/color][/b]" + new_message + "\n"

func _on_btnLogout_pressed() -> void:
	get_tree().network_peer = null
	Network.user_list.clear()
	get_tree().change_scene_to_file("res://Lobby/Lobby.tscn")


func _on_txt_message_text_submitted(new_message):
	rpc("send_chat",create_message(new_message))
	history.text += create_message(new_message)
	message.text = ""
	pass # Replace with function body.
