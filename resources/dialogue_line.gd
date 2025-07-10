extends Resource
class_name dialogue_line

@export var qui: String
@export var text: String
@export var audio: AudioStream
@export var actions_trigger : String

@export var response:Array[dialogue_line]
@export var action_called : Event_scenario
