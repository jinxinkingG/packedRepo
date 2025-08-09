extends "effect_20000.gd"

#驻防主动技部分
#【驻防】大战场，主动技。你方为战争防守方，且你在平地形时，你可发动：标记当前位置，当你处于此位置时，此地视为城墙，你拥有额外的25%计策减伤效果。回合结束时，若你不在标记位置，效果消失。每3回合限1次。

const EFFECT_ID = 20482
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 20483

func effect_20482_start()->void:
	var terrian = map.get_blockCN_by_position(me.position)
	if terrian != "平原":
		var msg = "【{0}】只能在平地发动".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	map.set_temp_block(me.position, "wall_3")
	var posInfo = {"x": me.position.x, "y": me.position.y}
	ske.set_war_skill_val(posInfo, 99999, PASSIVE_EFFECT_ID)
	ske.cost_war_cd(3)
	ske.war_report()
	var msg = "筑墙扎寨，步步为营"
	play_dialog(actorId, msg, 2, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
