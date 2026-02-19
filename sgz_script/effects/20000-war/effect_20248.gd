extends "effect_20000.gd"

#勉行主动技实现
#【勉行】大战场，主动技。你机动力＜3时才能使用：你可以无消耗移动一步。每个回合限1次。

const EFFECT_ID = 20248
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const AP_LIMIT = 3
const MAX_FREE_STEPS = 1

func effect_20248_start() -> void:
	if me.action_point >= AP_LIMIT:
		var msg = "机动力需 < {0}".format([AP_LIMIT])
		play_dialog(actorId, msg, 3, 2999)
		return

	var msg = "还差一步\n都给我打起精神来！"
	play_dialog(actorId, msg, 0, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirm")
	return

func effect_20248_confirm() -> void:
	# 标记技能移动开始 [移动中标记, 已用步数]
	var status = [1, 0]
	ske.set_war_skill_val(status, 1)

	# 启动移动流程
	LoadControl.end_script()
	DataManager.player_choose_actor = actorId
	FlowManager.add_flow("load_script|war/player_move.gd")
	FlowManager.add_flow("actor_move_start")
	return

func on_trigger_20007() -> bool:
	# 处理移动时的机动力消耗
	var status = _get_skill_status()

	# 检查是否在勉行移动状态且还有免费步数
	if status[0] <= 0:  # 不在移动状态
		return false
	if status[1] >= MAX_FREE_STEPS:  # 已用完免费步数
		return false

	# 设置移动消耗为0
	set_max_move_ap_cost([], 0)
	return false

func on_trigger_20003() -> bool:
	var status = _get_skill_status()
	if status[0] <= 0:  # 不在勉行移动状态
		return false

	# 处理移动状态变化
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")

	# 移动结束时清理状态
	if moveStopped > 0:
		status[0] = 0  # 清除移动状态
		ske.set_war_skill_val(status, 1)
		ske.cost_war_cd(1)
		return false

	match moveType:
		1:  # 尝试移动
			status[1] = min(status[1] + 1, MAX_FREE_STEPS)
		-1: # 撤回移动
			status[1] = max(0, status[1] - 1)

	ske.set_war_skill_val(status, 1)
	return false

func _get_skill_status() -> PoolIntArray:
	var status = ske.get_war_skill_val_int_array()
	if status.size() != 2:
		status = [0, 0]  # [移动中标记, 已用步数]
	return status
