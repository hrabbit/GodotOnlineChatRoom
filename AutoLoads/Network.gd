extends Node

signal update_user_list

var user_name : String = "Default"
var user_color : String = "red"

var user_list : Dictionary
const SERVER_PORT = 9999

func _ready() -> void:
	multiplayer.connect("connected_to_server",Callable(self,"connected"))
	multiplayer.connect("server_disconnected",Callable(self,"server_disconnected"))

#If we successful connect to the server, go into the chatroom
func connected():
	print("connected to server")
	var compile_data : Array = [str(multiplayer.get_unique_id()),user_name]
	rpc_id(1,"update_user",compile_data)
	enter_chat_room()
	
#Only run on the server
@rpc("any_peer") func update_user(user):
	user_list[str(user[0])] = user[1]
	update_user_list.emit()
	rpc("client_update",user_list)
	pass
	
@rpc("any_peer") func client_update(update_user_list_args):
	user_list = update_user_list_args
	update_user_list.emit()
#	emit_signal("update_user_list")

#Server just closed
func server_disconnected():
	print("server_disconnected")
	OS.alert('Server closed', 'Status')
	get_tree().change_scene_to_file("res://Lobby/Lobby.tscn")
	

func create_server():
	var server : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	server.create_server(SERVER_PORT, 32)
#	get_tree().set_multiplayer_peer(server)
	multiplayer.multiplayer_peer = server
	enter_chat_room()
	
func enter_chat_room():
	get_tree().change_scene_to_file("res://ChatRoom/Chatroom.tscn")
