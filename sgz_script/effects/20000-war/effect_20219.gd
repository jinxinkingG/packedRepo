extends "effect_20000.gd"

#饰非诱发技 #机动力
#【饰非】大战场,诱发技。你用计失败时，可以选择主将之外的1名队友发动。你获得其等于你计策消耗的1半机动力值（不足则全部获取）。

const EFFECT_ID = 20219
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation("")
	return

func effect_20219_AI_start():
	var targets = _get_possible_targets(me)
	if targets.empty():
		LoadControl.end_script()
		return
	set_env("目标", targets[0])
	FlowManager.add_flow(FLOW_BASE + "_2")
	return

func effect_20219_start():
	var targets = _get_possible_targets(me)
	if not wait_choose_actors(targets, "选择队友发动【饰非】", true):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20219_2():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var se = DataManager.get_current_stratagem_execution()
	var ap = int(se.cost / 2)
	ske.change_actor_ap(targetId, -ap)
	ske.change_actor_ap(me.actorId, ap)
	ske.war_report()
	var msg = "{0}，此皆尔之过也！\n（{1}夺取{2} {3}机动力".format([
		DataManager.get_actor_naughty_title(targetId),
		me.get_name(), targetWA.get_name(), ap
	])
	play_dialog(me.actorId, msg, 0, 2001)
	return

func on_trigger_20012()->bool:
	if me == null or me.disabled:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.succeeded > 0:
		return false
	if se.get_action_id(self.actorId) != self.actorId:
		return false
	if int(se.cost / 2) <= 0:
		return false
	# 计策失败
	var targets = _get_possible_targets(me)
	return targets.size() > 0

func _get_possible_targets(me:War_Actor)->PoolIntArray:
	var targets = []
	for targetId in get_teammate_targets(me):
		if targetId == me.get_main_actor_id():
			continue
		var wa = DataManager.get_war_actor(targetId)
		if wa == null or wa.disabled:
			continue
		if wa.action_point <= 0:
			continue
		targets.append(targetId)
	if not targets.empty():
		targets.shuffle()
	for specialId in StaticManager.HEBEI_4_BACKBONES:
		if specialId in targets:
			targets.erase(specialId)
			targets.insert(0, specialId)
			break
	return targets
