extends "effect_20000.gd"

#遗计效果实现
#【遗计】大战场，锁定技。你用伤兵计成功的场合，某队友（默认为主将）获得你本次计策消耗一半的机动力值。
#【遗计】大战场，主动技。你可以主动发动本技能，更改机动力馈赠的目标。

const EFFECT_ID = 20224
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation()
	return

func effect_20224_start():
	var targets = get_teammate_targets(me)
	var targetId = _get_marked_actor_id()
	var msg = "选定【{0}】目标".format([ske.skill_name])
	if targetId >= 0:
		targets.erase(targetId)
		targets.insert(0, targetId)
		msg += "（当前：{0}".format([
			ActorHelper.actor(targetId).get_name()
		])
	if not wait_choose_actors(targets, msg):
		return
	if targetId >= 0:
		var targetWA = DataManager.get_war_actor(targetId)
		map.show_color_block_by_position([targetWA.position])
	LoadControl.set_view_model(2000)
	return

func effect_20224_2():
	var targetId = get_env_int("目标")
	ske.set_war_skill_val(targetId, 99999)
	var msg = "{0}安坐\n只须如此……\n（改变【{1}】的目标".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
		ske.skill_name,
	])
	map.show_color_block_by_position([])
	play_dialog(me.actorId, msg, 2, 2001)
	return

func _get_marked_actor_id()->int:
	var targetId = ske.get_war_skill_val_int(-1, -1, -1)
	if targetId < 0:
		targetId = me.get_main_actor_id()
	var wa = DataManager.get_war_actor(targetId)
	if wa == null or wa.disabled or not wa.has_position():
		targetId = me.get_main_actor_id()
		wa = DataManager.get_war_actor(targetId)
	if not me.is_teammate(wa):
		targetId = -1
	return targetId

func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.succeeded <= 0:
		return false
	if not se.damage_soldier():
		return false
	if se.get_action_id(me.actorId) != me.actorId:
		return false
	var ap = int(se.cost / 2)
	if ap <= 0:
		return false
	var targetId = _get_marked_actor_id()
	if targetId < 0:
		return false
	ske.change_actor_ap(targetId, ap)
	ske.war_report()
	var msg = "{0}发动【{1}】\n令{2}获得{3}机动力".format([
		me.get_name(), ske.skill_name,
		ActorHelper.actor(targetId).get_name(), ap,
	])
	se.append_result(ske.skill_name, msg, ap, targetId)
	return false
