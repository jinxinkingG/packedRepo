extends "effect_20000.gd"

# 舰楼效果
#【舰楼】大战场，锁定技。移动结束时，若你的<乘流>减机动力效果处于触发中的场合，你可选择以下效果之一生效：●与1名相邻的敌将进入白刃战。●下次计策不消耗机动力（回合内限1次）。

const EFFECT_ID = 20605
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const CHENGLIU_EFFECT_ID = 20604

func on_trigger_20003() -> bool:
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")
	var flag = ske.get_war_skill_val_int(CHENGLIU_EFFECT_ID)
	if moveType == 0 and moveStopped == 1 and flag > 0:
		# 已经结束移动，且乘流状态是开启的
		if me.get_controlNo() < 0:
			# AI 总是不触发，选择免费计策
			free_scheme()
			return false
		var targetIds = []
		for dir in StaticManager.NEARBY_DIRECTIONS:
			var pos = me.position + dir
			var target = DataManager.get_war_actor_by_position(pos)
			if me.is_enemy(target):
				targetIds.append(target.actorId)
		if targetIds.empty():
			# 周围无敌军，自动选择免费计策
			free_scheme()
			return false
		# 周围有敌军，玩家触发技能选择攻击
		return true
	return false

func on_trigger_20005() -> bool:
	if ske.get_war_skill_val_int() == 1:
		set_scheme_ap_cost("ALL", 0)
		if DataManager.get_env_int("计策.消耗.仅对比") == 0:
			# 已扣减，标记已经用完
			ske.set_war_skill_val(2)
			# 取消连策
			var se = DataManager.get_current_stratagem_execution()
			se.skip_redo = 1
	return false

func effect_20605_start() -> void:
	var targetIds = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		var target = DataManager.get_war_actor_by_position(pos)
		if me.is_enemy(target):
			targetIds.append(target.actorId)
	var msg = "选择【{0}】攻击目标，可取消"
	wait_choose_actors(targetIds, msg)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_targeted", false, true, FLOW_BASE + "_cancel")
	return

func effect_20605_cancel() -> void:
	# 取消攻击，选择免费计策效果
	free_scheme()
	skill_end_clear()
	return

func effect_20605_targeted() -> void:
	var targetId = DataManager.get_env_int("目标")

	var msg = "舰楼猛冲！\n{0}为齑粉矣".format([
		DataManager.get_actor_naughty_title(targetId, actorId),
	])
	play_dialog(actorId, msg, 0, 2001)
	map.next_shrink_actors = [actorId, targetId]
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_fight")
	return

func effect_20605_fight() -> void:
	map.next_shrink_actors = []
	var targetId = DataManager.get_env_int("目标")
	start_battle_and_finish(actorId, targetId)
	return

func free_scheme() -> bool:
	if ske.get_war_skill_val_int() <= 0:
		# 没触发过
		ske.set_war_skill_val(1, 1)
		var msg = "乘流而下，安知吾计之所出？\n（【{0}】效果\n（下次计策不消耗机动力".format([
			ske.skill_name,
		])
		me.attach_free_dialog(msg, 1)
	return false
