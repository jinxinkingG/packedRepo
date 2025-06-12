extends "effect_30000.gd"

#勇突锁定技 #布阵 #武将强化
#【勇突】小战场，锁定技。布阵后，可以选择是否武将前置。你的基础伤害倍率+0.1

const ENHANCEMENT = {
	"额外伤害": 0.1,
	"BUFF": 1,
}

func effect_30194_AI_start():
	var bf = DataManager.get_current_battle_fight()
	if actorId == bf.get_defender_id() and bf.get_terrian_cn() in StaticManager.CITY_BLOCKS_CN:
		skill_end_clear()
		return
	goto_step("2")
	return

func effect_30194_start():
	var bu = get_leader_unit(me.actorId)
	if bu == null or bu.dic_combat.has("布阵前突"):
		LoadControl.end_script()
		return
	SceneManager.show_yn_dialog("武将是否列阵在前？", me.actorId, 2)
	var lastOption = get_env_int("勇突选项")
	if lastOption == 0 or lastOption == 1:
		SceneManager.actor_dialog.lsc.cursor_index = lastOption
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	match wait_for_skill_option():
		0:
			goto_step("2")
		1:
			goto_step("no")
	return

func effect_30194_2():
	var bu = get_leader_unit(me.actorId)
	if bu != null:
		ske.battle_unit_jump_forward(5, bu)
		ske.battle_report()
	skill_end_clear()
	return

func effect_30194_no():
	var bu = get_leader_unit(me.actorId)
	if bu != null and not bu.dic_combat.has("布阵前突"):
		bu.dic_combat["布阵前突"] = 0
	skill_end_clear()
	return

func on_trigger_30005()->bool:
	var bu = get_leader_unit(me.actorId)
	if bu == null:
		return false
	if me.get_controlNo() < 0:
		var bf = DataManager.get_current_battle_fight()
		if bf.get_terrian_cn() == "太守府":
			return false
	return not bu.dic_combat.has("布阵前突")

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["将"])
	return false
