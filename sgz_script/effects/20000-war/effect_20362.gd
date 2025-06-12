extends "effect_20000.gd"

#独揽主将技
#【独揽】大战场，主将主动技。你可指定1名营帐内有兵的武将发动。将之任意数量兵力转移给你，不可超过2500。每回合限一次。

const EFFECT_ID = 20362
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const SOLDIERS_LIMIT = 2500

func on_view_model_2000():
	wait_for_choose_item(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

func check_AI_perform_20000()->bool:
	if actor.get_soldiers() > 2000:
		return false
	for targetId in get_camp_targets(me):
		var targetActor = ActorHelper.actor(targetId)
		var soldiers = targetActor.get_soldiers()
		if soldiers < 100:
			continue
		return true
	return false

func effect_20362_AI_start():
	for targetId in get_camp_targets(me):
		var targetActor = ActorHelper.actor(targetId)
		var soldiers = targetActor.get_soldiers()
		if soldiers < 100:
			continue
		set_env("目标项", targetId)
		goto_step("3")
		return
	ske.cost_war_cd(1)
	LoadControl.end_script()
	FlowManager.add_flow("AI_before_ready")
	return

func effect_20362_start():
	if me.get_soldiers() >= SOLDIERS_LIMIT:
		play_dialog(me.actorId, "兵力已达上限", 2, 2009)
		return
	var targets = [null]
	for targetId in get_camp_targets(me):
		var targetActor = ActorHelper.actor(targetId)
		var soldiers = targetActor.get_soldiers()
		if soldiers <= 0:
			continue
		for i in targets.size():
			if targets[i] != null and targets[i].get_soldiers() > soldiers:
				continue
			targets.insert(i, targetActor)
			break
		if targets.size() >= 9:
			break
	targets.erase(null)
	if targets.empty():
		play_dialog(me.actorId, "营帐中没有可发动的目标", 3, 2009)
		return
	var items = []
	var values = []
	for target in targets:
		var name = target.get_name()
		var spaces = "　".repeat(max(1, 6 - name.length()))
		items.append("{0}{1}兵力：{2}".format([
			name, spaces, target.get_soldiers()
		]))
		values.append(target.actorId)
	var msg = "请选择【{0}】目标".format([ske.skill_name])
	SceneManager.show_unconfirm_dialog(msg, me.actorId)
	bind_menu_items(items, values, 1)
	LoadControl.set_view_model(2000)
	return

func effect_20362_2():
	var targetId = get_env_int("目标项")
	var msg = "发动【{0}】\n夺取{1}的兵力\n可否？".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20362_3():
	var targetId = get_env_int("目标项")
	var targetActor = ActorHelper.actor(targetId)
	var soldiers = min(SOLDIERS_LIMIT - actor.get_soldiers(), targetActor.get_soldiers())

	ske.cost_war_cd(1)
	soldiers = ske.change_actor_soldiers(targetId, -soldiers)
	soldiers = ske.change_actor_soldiers(me.actorId, -soldiers)
	ske.war_report()

	var msg = "兵符在此\n{0}交出所部，吾独统之\n（{1}夺取{2}兵力".format([
		targetActor.get_name(), me.get_name(), soldiers,
	])
	play_dialog(me.actorId, msg, 0, 2009)
	return
