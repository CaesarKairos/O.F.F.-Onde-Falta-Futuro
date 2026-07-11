extends Node

# =========================
# PROGRESSO
# =========================

var chapter := 1
var scene := 1
var story_stage := 0

# =========================
# FLAGS
# =========================

var flags: Dictionary = {}

func set_flag(flag_name: String) -> void:
	flags[flag_name] = true

func remove_flag(flag_name: String) -> void:
	flags.erase(flag_name)

func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

# =========================
# INVENTÁRIO
# =========================

var inventory: Array = []

func add_item(item_name: String) -> void:
	if item_name not in inventory:
		inventory.append(item_name)

func remove_item(item_name: String) -> void:
	inventory.erase(item_name)

func has_item(item_name: String) -> bool:
	return item_name in inventory
