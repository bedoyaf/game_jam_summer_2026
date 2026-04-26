

extends Node2D

@onready var bang_1: AudioStreamPlayer2D = $Bang1
@onready var bang_2: AudioStreamPlayer2D = $Bang2

func play():
	bang_1.play()
	bang_2.play()
