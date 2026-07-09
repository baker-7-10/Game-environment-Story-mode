extends Node

var _hit_pool: Array[AudioStreamPlayer2D] = []
var _hit_index: int = 0
var _alarm_player: AudioStreamPlayer2D
var _gold_player: AudioStreamPlayer2D

const POOL_SIZE: int = 4
const HIT_RANGE: float = 600.0

func _ready() -> void:
	for i in POOL_SIZE:
		var p = AudioStreamPlayer2D.new()
		p.name = "HitPool" + str(i)
		add_child(p)
		_hit_pool.append(p)

	_alarm_player = AudioStreamPlayer2D.new()
	_alarm_player.name = "AlarmPlayer"
	add_child(_alarm_player)

	_gold_player = AudioStreamPlayer2D.new()
	_gold_player.name = "GoldPlayer"
	add_child(_gold_player)

func play_hit(at: Vector2) -> void:
	# TODO: assign AudioStream to _hit_pool[i] when hit_sound.ogg is available
	# var p = _hit_pool[_hit_index]
	# _hit_index = (_hit_index + 1) % POOL_SIZE
	# p.global_position = at
	# p.play()
	pass

func play_base_alarm() -> void:
	# TODO: assign AudioStream to _alarm_player when base_alarm.ogg is available
	# _alarm_player.play()
	pass

func play_gold_deposit() -> void:
	# TODO: assign AudioStream to _gold_player when gold_deposit.ogg is available
	# _gold_player.play()
	pass

func play_footstep(at: Vector2) -> void:
	# TODO: play footstep loop during MoveState — assign AudioStream when available
	pass
