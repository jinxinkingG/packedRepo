extends "effect_30000.gd"

#伏瓮锁定技
#【伏瓮】小战场，锁定技。非攻城战，战斗初始，你可消耗3机动力发动：将你的前两个士兵单位强制为步兵，并放置在敌将竖直方向的场地上下边界处。每个大战场回合限1次。


const EFFECT_ID = 30264
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 3

func on_trigger_30005() -> bool:
	if actor.get_soldiers() <= 100:
		return false
	if me.action_point < COST_AP:
		return false
	return true

func effect_30264_AI_start() -> void:
	goto_step("2")
	return

func effect_30264_start() -> void:
	var msg = "消耗{0}机动力发动【{1}】\n于敌侧埋伏奇兵\n可否？".format([
		COST_AP, ske.skill_name,
	])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	Global.wait_for_yesno(FLOW_BASE + "_2", FLOW_BASE + "_end")
	return

func effect_30264_2() -> void:
	ske.battle_cd(99999)
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP)

	var c = enemy.battle_actor_unit().unit_position
	var targetPositions = [Vector2(c.x, 1), Vector2(c.x, 9)]
	for bu in DataManager.battle_units:
		if targetPositions.empty():
			break
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if bu.get_unit_type() in ["将", "城门"]:
			continue
		var pos = targetPositions.pop_front()
		bu.reset_combat_info("步")
		bu.dic_combat["兵种锁定"] = 1
		bu.unit_position = pos

	SceneManager.show_confirm_dialog("伏下奇兵，或有奇效", actorId, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation("")
	return

func effect_30264_end():
	LoadControl.end_script()
	return
