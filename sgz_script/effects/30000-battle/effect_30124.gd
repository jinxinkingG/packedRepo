extends "effect_30000.gd"

#铁骑小战场生效 #骑兵强化
#【铁骑】小战场，锁定技。非城战，布阵后可以额外消耗X点机动力，使本次白刃战，你的骑兵：获得3动效果，减伤倍率+0.05*X。X=本日内发动此技能的次数。

const EFFECT_ID = 30124
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_30005()->bool:
	if DataManager.battle_unit_type_hp(actorId, "骑") <= 0:
		return false
	if me.action_point < get_cost_ap():
		return false
	return true

func effect_30124_AI_start():
	goto_step("confirmed")
	return

func effect_30124_start():
	var cost = get_cost_ap()
	if me.action_point < cost:
		var msg = "机动力不足（需 >= {0}）\n无法发动【{1}】".format([
			cost, ske.skill_name
		])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2990)
		return
	var msg = "消耗{0}机动力发动【{1}】\n获得骑兵增强\n可否？".format([
		cost, ske.skill_name
	])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_30124_confirmed() -> void:
	var x = get_x()
	ske.cost_ap(x)
	ske.set_war_skill_val(x, 1)
	ske.battle_cd(99999)

	for bu in DataManager.battle_units:
		if bu == null or bu.disabled:
			continue
		if bu.leaderId != actorId or bu.get_unit_type() != "骑":
			continue
		bu.init_combat_info()

	var msg = "西凉铁骑，雄于天下！\n（本次白刃战，骑兵三动\n（减伤倍率 +{0}%".format([
		x * 5
	])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2990)
	return

func get_x() -> int:
	return ske.get_war_skill_val_int() + 1

func get_cost_ap()->int:
	return get_x()
