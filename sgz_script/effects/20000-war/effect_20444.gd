extends "effect_20000.gd"

#疏财主动技
#【疏财】大战场，主将主动技。你可指定一名你方其他武将赏赐10-100金。每回合限2次。若该武将忠不低于90，该武将获得隐藏技能<振勇>

const EFFECT_ID = 20444
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TARGET_SKILL = "振勇"

func effect_20444_start():
	if me.war_vstate().money < 10:
		var msg = "无财可疏"
		play_dialog(actorId, msg, 3, 2999)
		return
	if not wait_choose_actors(get_teammate_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20444_2():
	var targetId = DataManager.get_env_int("目标")
	SceneManager.hide_all_tool()
	var msg = "赏赐{0}多少金？".format([
		ActorHelper.actor(targetId).get_name()
	])
	var gold = min(100, me.war_vstate().money)
	gold = gold - gold % 10
	SceneManager.show_input_numbers(msg, ["金"], [gold], [1])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_number_input(FLOW_BASE + "_3")
	return

func effect_20444_3():
	var targetId = DataManager.get_env_int("目标")
	var cost = DataManager.get_env_int("数值")
	var targetActor = ActorHelper.actor(targetId)

	ske.change_wv_gold(-cost)
	ske.cost_war_limited_times(2)
	var msg = "财散人聚，赏赐{0}{1}金".format([
		targetActor.get_name(), cost,
	])
	var current = targetActor.get_loyalty()
	if current >= 90:
		ske.add_war_skill(targetId, TARGET_SKILL, 99999)
		msg += "\n{0}获得技能【{1}】".format([
			targetActor.get_name(), TARGET_SKILL
		])
	else:
		var lord = ActorHelper.actor(me.get_lord_id())
		#赏赐金，忠诚上升=君主德/10+消耗金额/20
		var val = min(int(lord.get_moral()/10)+int(cost/20),50)
		targetActor.set_loyalty(min(current + val, 99))
		val = targetActor.get_loyalty() - current
		msg += "\n{0}忠诚度 +{1}，现为{2}".format([
			targetActor.get_name(), val, targetActor.get_loyalty()
		])
	ske.war_report()
	play_dialog(actorId, msg, 1, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
