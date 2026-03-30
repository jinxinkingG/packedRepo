extends "effect_20000.gd"

#辨琴主动技
#【辨琴】大战场，主动技。若你五行为木、火：你可以选择 1 名队友，与之拼点，使其恢复 X 点体力。若你拼点胜出，与其交换五行点数。X = 你拼点时的点数。每个回合限 1 次。

const EFFECT_ID = 20119
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20119_start() -> void:
	match me.five_phases:
		War_Character.FivePhases_Enum.Fire:
			pass
		War_Character.FivePhases_Enum.Wood:
			pass
		_:
			var msg = "五行为{0}\n不可发动辨琴".format([me.get_five_phases_str()])
			play_dialog(actorId, msg, 3, 2999)
			return
	if not wait_choose_actors(get_teammate_targets(me), "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20119_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "对{0}发动【{1}】\n将与其拼点并尝试恢复体力\n可否？".format([
		targetWA.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20119_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	ske.cost_war_cd(1)
	var diff = me.get_poker_point_diff(targetWA)
	var msgs = ["抚奏一曲，为君平心正念"]

	# 拼点时「我」的点数
	var effectivePoint = diff + targetWA.poker_point
	var hp = ske.change_actor_hp(targetId, effectivePoint)
	if hp > 0:
		msgs.append("（{0}体力回复{1}，至{2}".format([
			targetWA.get_name(), hp, targetWA.actor().get_hp()
		]))
	if diff > 0:
		var decor = me.five_phases
		var point = me.poker_point
		ske.change_actor_five_phases(actorId, targetWA.five_phases, targetWA.poker_point)
		ske.change_actor_five_phases(targetWA.actorId, decor, point)

		msgs.append("（互换了五行点数".format([
			me.get_name(), targetWA.get_name()
		]))

	ske.war_report()
	play_dialog(actorId, "\n".join(msgs), 1, 2999)
	return
