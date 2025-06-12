extends "effect_20000.gd"

#教退主动技
#【教退】大战场，主动技。指定1名与你相邻且不在城地形的武将，若其身后没有阻挡，你可消耗5点机动力发动。使目标强制后退1格。每回合限1次。

const EFFECT_ID = 20355
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func on_view_model_2003()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_5")
	return

func on_view_model_2009()->void:
	wait_for_skill_result_confirmation()

func effect_20355_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	var targets = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var wa = DataManager.get_war_actor_by_position(me.position + dir)
		if not me.is_enemy(wa):
			continue
		var terrian = map.get_blockCN_by_position(wa.position)
		if terrian in StaticManager.CITY_BLOCKS_CN:
			continue
		var next = me.position + dir * 2
		if not wa.can_move_to_position(next):
			continue
		terrian = map.get_blockCN_by_position(next)
		if terrian in StaticManager.CITY_BLOCKS_CN:
			continue
		targets.append(wa.actorId)
	if targets.empty():
		var msg = "没有可以发动【{0}】的目标".format([ske.skill_name])
		play_dialog(me.actorId, msg, 3, 2009)
		return
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20355_2():
	map.cursor.hide()
	var targetId = get_env_int("目标")

	var msg = "【{0}】{1}\n需{2}点机动力\n可否？".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(), COST_AP,
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20355_3():
	var targetId = get_env_int("目标")

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)

	var msg = "腐草萤光，怎及天心皓月\n何不倒戈卸甲，以礼来降？\n{0}退而熟思之".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
	])
	play_dialog(me.actorId, msg, 1, 2002)
	return

func effect_20355_4():
	var targetId = get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	if wa.actor().get_wisdom() >= 99:
		var msg = "皓首匹夫！苍髯老贼！\n行伍之前，妄称天数\n速退！教反臣与吾决胜负"
		play_dialog(targetId, msg, 0, 2003)
		return
	var msg = "…… ……"
	wa.move(wa.position * 2 - me.position, true)
	ske.war_report()
	play_dialog(targetId, msg, 2, 2009)
	return

func effect_20355_5():
	var targetId = get_env_int("目标")
	var msg = "尔！！如此无————\n啊 ……\n（{0}气恨落马".format([
		me.get_name(),
	])
	ske.change_actor_hp(me.actorId, 1 - actor.get_hp())
	ske.war_report()
	play_dialog(me.actorId, msg, 0, 2009)
	return
