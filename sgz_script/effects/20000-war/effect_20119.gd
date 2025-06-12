extends "effect_20000.gd"

#辨琴主动技
#【辨琴】大战场,主动技。若你花色为红色：你可以选择1名队友发动。你与之交换花色和点数，并且使之恢复交换后点数的体力值。每回合限1次。

const EFFECT_ID = 20119
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2099():
	wait_for_skill_result_confirmation()
	return

func effect_20119_start():
	match me.five_phases:
		War_Character.FivePhases_Enum.Fire:
			pass
		War_Character.FivePhases_Enum.Wood:
			pass
		_:
			var msg = "五行为{0}\n不可发动辨琴".format([me.get_five_phases_str()])
			play_dialog(me.actorId, msg, 3, 2099)
			return
	if not wait_choose_actors(get_teammate_targets(me), "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20119_2():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "与{1}互换五行点数\n并为{1}恢复{2}点体力\n可否？".format([
		me.get_name(), targetWA.get_name(), me.poker_point
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20119_3():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	ske.cost_war_cd(1)
	var decor = me.five_phases
	var point = me.poker_point
	ske.change_actor_five_phases(me.actorId, targetWA.five_phases, targetWA.poker_point)
	ske.change_actor_five_phases(targetWA.actorId, decor, point)

	var msgs = ["{0}和{1}\n互换了五行与点数".format([
		me.get_name(), targetWA.get_name()
	])]

	ske.change_actor_hp(targetId, point)
	ske.war_report()
	msgs.append("{0}的体力恢复至{1}".format([
		targetWA.get_name(), int(ActorHelper.actor(targetId).get_hp())
	]))
	play_dialog(me.actorId, "\n".join(msgs), 1, 2099)
	return
