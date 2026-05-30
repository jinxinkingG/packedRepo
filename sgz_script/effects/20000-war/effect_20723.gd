extends "effect_20000.gd"

#趫猛主动技 #限定技
#【趫猛】大战场，限定技。你可选择立刻获得6/12/18点机动力，回合结束阶段，受到50/100/150火焰伤害。

const EFFECT_ID = 20723
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const AP_OPTIONS = [6, 12, 18]
const DAMAGE_OPTIONS = [50, 100, 150]

func check_AI_perform_20000()->bool:
	return true

func effect_20723_AI_start():
	DataManager.set_env("目标项", 2)
	goto_step("3")
	return

func effect_20723_start():
	var items = []
	var values = []
	for i in AP_OPTIONS.size():
		items.append("机动力+{0}（{1}火焰伤害）".format([AP_OPTIONS[i], DAMAGE_OPTIONS[i]]))
		values.append(i)
	var msg = "请选择【{0}】档位".format([ske.skill_name])
	SceneManager.show_unconfirm_dialog(msg, me.actorId)
	bind_menu_items(items, values, 1)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_item(FLOW_BASE + "_2")
	return

func effect_20723_2():
	var idx = DataManager.get_env_int("目标项")
	var msg = "发动【{0}】\n获得{1}机动力，回合结束将受到{2}火焰伤害，可否？".format([
		ske.skill_name, AP_OPTIONS[idx], DAMAGE_OPTIONS[idx],
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20723_3():
	var idx = DataManager.get_env_int("目标项")
	var ap = AP_OPTIONS[idx]

	ske.cost_war_cd(99999)
	ske.change_actor_ap(actorId, ap)
	ske.set_war_skill_val(idx + 1)
	ske.war_report()

	var msg = "无以疏旷，何彰武才！\n（获得{0}机动力".format([ap])
	play_dialog(actorId, msg, 0, 2999)
	return
