class_name Player

extends Object

var device_id: int
var name: String
var character_id: int = -7777
var score: int = 0
var health: int = 100

func _init(device_id: int, name: String):
	self.device_id = device_id
	self.name = name
