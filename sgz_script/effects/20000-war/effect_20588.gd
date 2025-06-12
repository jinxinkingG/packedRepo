extends "effect_20000.gd"

# 藏祸主动技
#【藏祸】大战场，主动技。你立刻失去该技能，并以下选择一项功能发动之： 1.选择1名攻击范围内的敌将，与之进入白刃战。 2.进入计策列表，不消耗机动力选择一个计策发动。

const EFFECT_ID = 20588
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20588_start() -> void:
	var options = ["攻击", "计策"]
	var msg = "仁不用兵，当先下手为强！\n如何行动？"
	play_dialog(actorId, msg, 2, 2000, true, options)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_attack", true, FLOW_BASE + "_scheme", false)
	return

func effect_20588_attack() -> void:
	ske.remove_war_skill(actorId, ske.skill_name)
	skill_end_clear()
	LoadControl.load_script("res://resource/sgz_script/war/player_attack.gd")
	FlowManager.add_flow("attack_anyway")
	return

func effect_20588_scheme() -> void:
	ske.remove_war_skill(actorId, ske.skill_name)
	skill_end_clear()
	LoadControl.load_script("res://resource/sgz_script/war/player_stratagem_menu.gd")
	FlowManager.add_flow("stratagem_anyway")
	return

