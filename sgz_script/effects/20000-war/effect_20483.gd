extends "effect_20000.gd"

#驻防被动效果
#【驻防】大战场，主动技。你方为战争防守方，且你在平地形时，你可发动：标记当前位置，当你处于此位置时，此地视为城墙，你拥有额外的25%计策减伤效果。回合结束时，若你不在标记位置，效果消失。每3回合限1次。

const DAMAGE_REDUCE = -25

func on_trigger_20003()->bool:
	if DataManager.get_env_int("移动") != 0:
		return false
	if DataManager.get_env_int("结束移动") != 1:
		return false
	var pos = ske.get_war_skill_val_vector()
	if pos.x < 0 or pos.y < 0:
		return false
	if pos == me.position:
		map.set_temp_block(pos, "wall_3")
		FlowManager.add_flow("draw_actors")
	else:
		map.set_temp_block(pos, "")
		FlowManager.add_flow("draw_actors")
	return false

func on_trigger_20002()->bool:
	var pos = ske.get_war_skill_val_vector()
	if pos.x < 0 or pos.y < 0:
		return false
	if pos != me.position:
		return false
	change_scheme_damage_rate(DAMAGE_REDUCE)
	return false

func on_trigger_20016()->bool:
	var pos = ske.get_war_skill_val_vector()
	if pos.x < 0 or pos.y < 0:
		return false
	if pos == me.position:
		return false
	map.set_temp_block(pos, "")
	ske.set_war_skill_val(0, 0)
	return false

func on_trigger_20020()->bool:
	var pos = ske.get_war_skill_val_vector()
	if pos.x < 0 or pos.y < 0:
		return false
	if pos == me.position:
		map.set_temp_block(pos, "wall_3")
		FlowManager.add_flow("draw_actors")
	else:
		map.set_temp_block(pos, "")
		FlowManager.add_flow("draw_actors")
	return false

func on_trigger_20040()->bool:
	var pos = ske.get_war_skill_val_vector()
	if pos.x < 0 or pos.y < 0:
		return false
	if pos == me.position:
		map.set_temp_block(pos, "wall_3")
		FlowManager.add_flow("draw_actors")
	else:
		map.set_temp_block(pos, "")
		FlowManager.add_flow("draw_actors")
	return false

func on_trigger_20027()->bool:
	var pos = ske.get_war_skill_val_vector()
	if pos.x < 0 or pos.y < 0:
		return false
	if map == null:
		return false
	map.set_temp_block(pos, "")
	FlowManager.add_flow("draw_actors")
	return false
