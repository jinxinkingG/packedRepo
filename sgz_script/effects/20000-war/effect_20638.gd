extends "effect_20000.gd"

# 乾转限定技
#【乾转】大战场，限定技。你方总体损失至少2000兵力时，你可指定1名队友为目标发动。令之兵力变为(其兵力上限-当前兵力)的值。

const EFFECT_ID = 20638
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20638_start() -> void:
	# 损兵判断
	var lost = me.war_vstate().get_lose_sodiers()
	if lost < 2000:
		var msg = "战局焦灼，损兵未甚\n尚可相机而动\n（当前损兵：{0}".format([lost])
		play_dialog(actorId, msg, 2, 2999)
		return

	var targets = get_teammate_targets(me)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20638_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "对{0}发动【{1}】\n令其兵力变化\n可否？"
	var name = ActorHelper.actor(targetId).get_name()
	msg = msg.format([name, ske.skill_name])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20638_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)

	var current = wa.get_soldiers()
	var limit = DataManager.get_actor_max_soldiers(targetId)
	var changed = limit - current
	ske.change_actor_soldiers(targetId, changed - current)
	ske.cost_war_cd(99999)
	ske.war_report()

	map.draw_actors()
	var msg = "玄机暗伏久矣\n惟望{0}倒转乾坤！\n（{1}兵力变为 {2}"
	msg = msg.format([
		DataManager.get_actor_honored_title(targetId, actorId),
		wa.get_name(), wa.get_soldiers()
	])
	play_dialog(actorId, msg, 0, 2999)
	return
