# Game class - Contains the game logic for the demo game
extends Node

# Imports
var CardRng  = preload("res://addons/card_engine/card_rng.gd")

# Time to wait between step to account for animations
const STEP_WAIT_TIME = 0.5

signal turn_started()
signal player_check()
signal player_end()

var targets = []
var items = []
var enemy_targets = []

var max_moves = 2
var moves

var character = ""

var player
var tacos = false
var highlight = false
var once = false
var bars = {"health" : 9, "focus" : 3, "stamina" : 5}
var curr_bars = {}
var bar_press = {"focus" : 0, "stamina" : 0}
var curr_bar_press = {}
var count = 0

var _stepper = Timer.new()
var _steps = ["start_game", "your_turn"]
var _current_step = 0
var _discard_rng = CardRng.new()
export (NodePath) var hand

func _init():
	_stepper.one_shot = true
	_stepper.wait_time = STEP_WAIT_TIME
	add_child(_stepper)
	_stepper.connect("timeout", self, "_on_stepper_timeout")

func create_game(character_name):
	character = character_name
	
#	player_cards.copy_from(player_items)
	
	_stepper.start()

func bar_regen():
	if curr_bars.focus < bars.focus:
		curr_bars.focus += 1
	if curr_bars.stamina < bars.stamina:
		curr_bars.stamina += 1

func _step_start_turn():
	emit_signal("turn_started")
	print("steps: " + String(_steps))

func _on_stepper_timeout():
	var step = _steps[_current_step]
	if step == "start_game":
		_step_start_turn()
	
	_current_step += 1
	if _current_step >= _steps.size():
		_current_step = 1
	#print("current step: " + String(_current_step))

func enemy_use(ability, target, value):
	target.use(ability, value)

func return_state():
	_steps = ["start_game", "your_turn"]
	_current_step = 0
	targets.clear()
	enemy_targets.clear()

#func weapon_use(weapon, curr_target = null):
#	if weapon.targets in ItemUses.weapon_use_case:
#		ItemUses.weapon_use_case[weapon.targets].call_func(weapon, curr_target)
#	player.get_node("animations").play("attack")

func item_use(item, hand, curr_target = null):
	print(hand)
	if item.targets in ItemUses.item_use_case:
		ItemUses.item_use_case[item.targets].call_func(item, curr_target)
	if item.values.has("attack") and hand != "jutsus":
		player.animation("attack")
		yield(get_tree().create_timer(0.25),"timeout")
		player.animation("default")
	elif item.values.has("attack") and hand == "jutsus":
		player.animator.play("cast")
		yield(get_tree().create_timer(0.25),"timeout")
		player.animation("default")
	else:
		player.animation("default")
#	player.get_node("animations").play("attack")

#func jutsu_use(card, curr_target = null):
#	if card.targets in ItemUses.jutsu_use_case:
#		ItemUses.jutsu_use_case[card.targets].call_func(card, curr_target)
#	player.get_node("animations").play("attack")