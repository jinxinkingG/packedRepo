extends "effect_20000.gd"

#掘道主动技实现
#【掘道】大战场，主动技。你可以指定一个紧挨城墙的你方武将，消耗6点机动力，通过挖掘地道，使其移动到城墙的另一边。每回合限1次。

const EFFECT_ID = 20239
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 6

func check_AI_perform_20000()->bool:
	var targetIds = get_avaible_target_ids()
	if targetIds.empty():
		return false
	var center = map.builds_position["太守府"]
	for targetId in targetIds:
		var wa = DataManager.get_war_actor(targetId)
		for dir in StaticManager.NEARBY_DIRECTIONS:
			if not _direction_available(wa, dir):
				continue
			if Global.get_distance(center, wa.position) <= Global.get_distance(center, wa.position + dir):
				continue
			wa.set_AI_decided_route([])
			DataManager.set_env("目标", wa.actorId)
			DataManager.set_target_position(wa.position + dir * 2)
			return true
	return false

func effect_20239_AI_start():
	goto_step("4")
	return

func effect_20239_start():
	map.show_color_block_by_position([])
	if not assert_action_point(me.actorId, COST_AP):
		return
	var targetIds = get_avaible_target_ids()
	if targetIds.empty():
		var msg = "没有可以发动{0}的目标".format([ske.skill_name])
		play_dialog(me.actorId, msg, 3, 2999)
		return
	var msg = "选择目标发动{0}".format([ske.skill_name])
	if not wait_choose_actors(targetIds, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20239_2():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	map.show_color_block_by_position([])
	var positions = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		if _direction_available(targetWA, dir):
			positions.append(targetWA.position + dir * 2)
	if positions.empty():
		var msg = "没有可以发动{0}的位置".format([ske.skill_name])
		play_dialog(me.actorId, msg, 3, 2999)
		return
	map.next_shrink_actors = [targetId]
	map.show_color_block_by_position(positions)
	map.set_cursor_location(positions[0], true)
	set_env("可选目标", positions)
	DataManager.set_target_position(positions[0])
	SceneManager.show_unconfirm_dialog("请指定{0}位移地点".format([ske.skill_name]))
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_choose_position(FLOW_BASE + "_3")
	return

func effect_20239_3():
	var targetId = DataManager.get_env_int("目标")
	var msg = "消耗 {0} 机动力\n令{1}掘道潜越城墙\n可否？".format([
		COST_AP, ActorHelper.actor(targetId).get_name()
	])
	play_dialog(me.actorId, msg, 2, 2002, true)
	return

func on_view_model_2002():
	wait_for_yesno(FLOW_BASE + "_4")
	return

func effect_20239_4():
	var targetId = DataManager.get_env_int("目标")
	var pos = DataManager.get_target_position()
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.change_war_actor_position(targetId, pos)
	ske.war_report()
	map.update_ap()
	map.next_shrink_actors = []
	map.show_color_block_by_position([])
	#FlowManager.add_flow("draw_actors")
	var msg = "土攻之妙\n非深沟高垒可当"
	play_dialog(me.actorId, msg, 1, 2003)
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

func effect_20239_end():
	skill_end_clear()
	var endFlow = "player_skill_end_trigger"
	if me.get_controlNo() < 0:
		endFlow = "AI_skill_end_trigger"
	FlowManager.add_flow(endFlow)
	return

# 判断目标方向是否是可以穿越的城墙
func _direction_available(wa:War_Actor, dir:Vector2)->bool:
	if map == null:
		return false
	var pos = wa.position
	var blockCN = map.get_blockCN_by_position(pos)
	if blockCN in StaticManager.CITY_BLOCKS_CN:
		return false
	pos = wa.position + dir
	blockCN = map.get_blockCN_by_position(pos)
	if blockCN != "城墙":
		return false
	pos = wa.position + dir * 2
	blockCN = map.get_blockCN_by_position(pos)
	if blockCN in StaticManager.CITY_BLOCKS_CN:
		return false
	var existing = DataManager.get_war_actor_by_position(pos)
	if existing != null:
		return false
	return true

func get_avaible_target_ids()->PoolIntArray:
	var targets = get_teammate_targets(me)
	targets.append(me.actorId)
	var ret = []
	for targetId in targets:
		var wa = DataManager.get_war_actor(targetId)
		for dir in StaticManager.NEARBY_DIRECTIONS:
			if not _direction_available(wa, dir):
				continue
			ret.append(targetId)
			break
	return ret
