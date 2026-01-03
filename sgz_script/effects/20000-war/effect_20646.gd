extends "effect_20000.gd"

# 透阵主动技部分
#【透阵】大战场，主动技。相邻敌军若可后退，且你可移动到其后退位置，你可消耗5机动力，对其发起攻击。若攻击获胜，视为成功突破敌阵，你体力+15，并移动到其后退位置，敌军原地不动。

const EFFECT_ID = 20646
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

func effect_20646_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var targetIds = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		if not me.try_move(pos, false, true):
			continue
		var terrian = map.get_blockCN_by_position(pos)
		if terrian in ["城门", "太守府"]:
			continue
		var wa = DataManager.get_war_actor_by_position(pos)
		if not me.is_enemy(wa):
			continue
		var next = pos * 2 - me.position
		if not wa.try_move(next):
			continue
		# 测试自己是否能移动过去
		me.position = pos
		var possible = me.try_move(next)
		# 恢复自己的位置
		me.position = pos - dir
		if not possible:
			continue
		targetIds.append(wa.actorId)
	targetIds = check_combat_targets(targetIds)
	if targetIds.empty():
		var msg = "没有可以发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	if targetIds.size() == 1:
		DataManager.set_env("目标", targetIds[0])
		goto_step("selected")
		return
	if not wait_choose_actors(targetIds):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20646_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	
	var msg = "对{0}发动【{1}】\n可否？".format([
		targetWA.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	map.next_shrink_actors = [actorId, targetId]
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_fight")
	return

func effect_20646_fight() -> void:
	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(1)
	ske.war_report()

	var targetId = DataManager.get_env_int("目标")
	var msg = "中央突击！\n凿穿{0}阵型！".format([
		DataManager.get_actor_naughty_title(targetId, actorId),
	])
	me.attach_free_dialog(msg, 0)
	start_battle_and_finish(actorId, targetId)
	return
