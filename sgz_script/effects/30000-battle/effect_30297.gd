extends "effect_30000.gd"

# 幻骑主动技
#【幻骑】小战场，主动技。非城战，你发动黄巾秘术，将你所有剩余兵力，集中到某个骑兵单位。该骑兵单位每轮行动次数+1。每个大战场回合限1次。（无骑兵单位时不可发动。）

const EFFECT_ID = 30297
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_30297_start() -> void:
	if DataManager.battle_unit_type_hp(actorId, "骑") < 0:
		var msg = "无骑兵单位！"
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2000)
		return

	var target = null
	var others = 0.0
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if bu.get_unit_type() == "将":
			continue
		if target == null and bu.get_unit_type() == "骑":
			target = bu
		else:
			others += bu.get_hp() - 1.0
	if target == null:
		var msg = "无骑兵单位！"
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2000)
		return
	if others <= 0:
		var msg = "余部兵力不足"
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2000)
		return

	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if bu.get_unit_type() == "将":
			continue
		if bu.unitId == target.unitId:
			bu.set_hp(bu.get_hp() + others, true)
			ske.battle_enhance_unit(bu, {"行动次数": 3})
		else:
			if bu.get_hp() < 1.0:
				continue
			else:
				bu.set_hp(1.0, true)

	var status = "{0} +{1}".format([
		ske.skill_name, int(others)
	])
	target.add_status_effect(status)
	ske.battle_cd(99999)
	ske.cost_war_cd(1)
	me.attach_free_dialog("形散神聚，亦幻亦真！", 0, 30000)
	goto_step("end")
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30297_end()->void:
	tactic_end()
	return
