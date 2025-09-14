extends "effect_20000.gd"

# 钧发限定技
#【钧发】大战场，限定技。你方总兵力比对方总兵力小3000以上时才能发动。你可指定1名己方将领机动力翻倍；若以此法指定自己，则你当回合用伤兵计成功率+20%，计策造成的士兵伤害+20%。

const EFFECT_ID = 20636
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20636_start() -> void:
	# 兵力判断
	if me.war_vstate().get_all_soldiers() > me.get_enemy_war_vstate().get_all_soldiers() - 3000:
		var msg = "兵力差距尚可\n未到存亡之分"
		play_dialog(actorId, msg, 2, 2999)
		return

	var targets = get_teammate_targets(me)
	targets.append(actorId)
	wait_choose_actors(targets)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20636_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "对{0}发动【{1}】\n机动力翻倍"
	var name = ActorHelper.actor(targetId).get_name()
	if targetId == actorId:
		msg += "并增强计策"
		name = "自身"
	msg += "\n可否？"
	msg = msg.format([name, ske.skill_name])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20636_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)

	var ap = wa.action_point
	ske.change_actor_ap(targetId, ap)
	ske.set_war_skill_val(targetId, 1)
	ske.cost_war_cd(99999)
	ske.war_report()

	var msg = "千钧一发，不奋力而何待！\n（{0}机动力 +{1} => {2}"
	if targetId == actorId:
		msg += "\n（本回合伤兵计命中增伤+20%"
	msg = msg.format([
		wa.get_name(), ap, wa.action_point
	])
	play_dialog(actorId, msg, 0, 2999)
	return
