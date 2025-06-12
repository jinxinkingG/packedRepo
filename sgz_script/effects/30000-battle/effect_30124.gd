extends "effect_30000.gd"

#铁骑小战场生效 #骑兵强化
#【铁骑】小战场,锁定技。非城战布阵后，可以额外消耗1点机动力,使本次白刃战的骑兵获得3动效果。同一回合多次发动，机动力消耗将逐渐增加。

const EFFECT_ID = 30124
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP_BASE = 1
const COST_AP_ACCU = 1

func on_trigger_30005()->bool:
	if DataManager.battle_unit_type_hp(actorId, "骑") <= 0:
		return false
	if me.action_point < get_cost_ap():
		return false
	return true

func effect_30124_AI_start():
	goto_step("2")
	return

func effect_30124_start():
	var cost = get_cost_ap()
	if me.action_point < cost:
		var msg = "机动力不足（需 >= {0}）\n无法发动【{1}】".format([
			cost, ske.skill_name
		])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2001)
		return
	var msg = "消耗{0}机动力发动【{1}】\n本次白兵战骑兵获得三动\n可否？".format([
		cost, ske.skill_name
	])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	Global.wait_for_yesno(FLOW_BASE + "_2", FLOW_BASE + "_end")
	return

func effect_30124_2():
	ske.battle_cd(99999)
	ske.cost_ap(get_cost_ap())
	ske.set_war_skill_val(ske.get_war_skill_val_int() + 1, 1)

	for bu in DataManager.battle_units:
		if bu == null or bu.disabled:
			continue
		if bu.leaderId != actorId or bu.get_unit_type() != "骑":
			continue
		bu.set_action_times(3)

	SceneManager.show_confirm_dialog("西凉铁骑，雄于天下！", actorId, 0)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	Global.wait_for_confirmation(FLOW_BASE + "_end")
	return

func effect_30124_end():
	LoadControl.end_script()
	return

func get_cost_ap()->int:
	return ske.get_war_skill_val_int() * COST_AP_ACCU + COST_AP_BASE
