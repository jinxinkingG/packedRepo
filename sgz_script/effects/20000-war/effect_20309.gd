extends "effect_20000.gd"

#优游主动技实现
#【优游】大战场，主将主动技。你可以指定任意你方武将，将其任意点数的机动力交给你，每回合限一次。

const EFFECT_ID = 20309
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_number_input(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation()
	return

func effect_20309_start():
	var targets = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.action_point <= 0:
			continue
		targets.append(targetId)
	var msg = "选择队友发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20309_2():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	SceneManager.hide_all_tool()
	var msg = "欲从{0}处获取多少机动力？".format([targetWA.get_name()])
	SceneManager.show_input_numbers(msg, ["机动力"], [targetWA.action_point], [0], [2])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2001)
	return

func effect_20309_3():
	var targetId = get_env_int("目标")
	var ap = get_env_int("数值")

	ske.cost_war_cd(1)
	ap = -ske.change_actor_ap(targetId, -ap)
	ske.change_actor_ap(me.actorId, ap)
	ske.war_report()

	map.update_ap()
	FlowManager.add_flow("draw_actors")
	var msg = "不拘一格，看我将略\n（{0}发动{1}，向{2}借得{3}机动力".format([
		me.get_name(), ske.skill_name,
		ActorHelper.actor(targetId).get_name(), ap,
	])
	play_dialog(me.actorId, msg, 1, 2002)
	return
