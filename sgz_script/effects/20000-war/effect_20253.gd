extends "effect_20000.gd"

#系师效果实现
#【系师】大战场,主将诱发技。若你方米＞500，你方武将每次受到计策伤害的场合，你可以发动道术：米-50，该武将机动力+2，恢复本次计策伤害25%的士兵。

const EFFECT_ID = 20253
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const REQUIRED_RICE = 500
const COST_RICE = 50
const AP_RECOVER = 2


func on_trigger_20012()->bool:
	if ske.actorId == actorId:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.succeeded <= 0:
		return false
	if not se.damage_soldier():
		return false
	if ske.actorId != se.targetId:
		return false
	if se.get_soldier_damage_for(se.targetId) <= 0:
		return false
	var teammate = DataManager.get_war_actor(ske.actorId)
	if teammate == null or teammate.disabled:
		return false
	var wv = me.war_vstate()
	if wv.rice <= REQUIRED_RICE:
		return false
	return true

func effect_20253_AI_start():
	goto_step("2")
	return

func effect_20253_start():
	var teammate = DataManager.get_war_actor(ske.actorId)
	var msg = "消耗{0}米发动【{1}】\n为{2}恢复机动力和兵力\n可否？".format([
		COST_RICE, ske.skill_name, teammate.get_name()
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20253_2():
	var se = DataManager.get_current_stratagem_execution()
	var damage = se.get_soldier_damage_for(ske.actorId)
	ske.cost_wv_rice(COST_RICE)
	ske.change_actor_soldiers(ske.actorId, int(damage / 4))
	ske.change_actor_ap(ske.actorId, AP_RECOVER)
	ske.war_report()
	var msg = "景行焯灵, 出禅治化"
	FlowManager.add_flow("draw_actors")
	report_skill_result_message(ske, 2001, msg, 2)
	return

func on_view_model_2001()->void:
	wait_for_pending_message(FLOW_BASE + "_3", "")
	return

func effect_20253_3():
	report_skill_result_message(ske, 2001)
	return
