extends "effect_20000.gd"

#耐行主动技
#【耐行】大战场，主动技。你可以消耗经验值进行移动，每步消耗50经验。每回合限4步。

const EFFECT_ID = 20717
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const EXP_COST_PER_STEP = 50
const MAX_STEPS_PER_TURN = 4

func effect_20717_start() -> void:
	# 获取当前可用步数
	var status = _get_skill_status()
	var availableSteps = MAX_STEPS_PER_TURN - status[1]

	if availableSteps <= 0:
		var msg = "本回合【{0}】步数已尽".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	# 检查经验是否足够
	var currentExp = actor.get_exp()
	if currentExp < EXP_COST_PER_STEP:
		var msg = "经验不足\n（每步消耗{0}".format([EXP_COST_PER_STEP])
		play_dialog(actorId, msg, 3, 2999)
		return

	var msg = "发动【{0}】\n可消耗{1}经验移动\n可否？".format([
		ske.skill_name, EXP_COST_PER_STEP,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirm", true)
	return

func effect_20717_confirm() -> void:
	var msg = "虽千万里，吾往矣！"
	play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_execute")
	return

func effect_20717_execute():
	# 标记技能移动开始
	var status = _get_skill_status()
	status[0] = 1
	ske.set_war_skill_val(status, 1)
	# 启动移动流程
	LoadControl.end_script()
	DataManager.player_choose_actor = actorId
	FlowManager.add_flow("load_script|war/player_move.gd")
	FlowManager.add_flow("actor_move_start")
	return

func on_trigger_20007()->bool:
	# 处理移动时的机动力消耗
	var status = _get_skill_status()
	# 检查是否在耐行移动状态
	if status[0] <= 0:
		return false
	if status[1] >= MAX_STEPS_PER_TURN:
		return false

	# 设置移动消耗为0
	set_max_move_ap_cost([], 0)
	return false

func on_trigger_20003()->bool:
	var status = _get_skill_status()
	if status[0] <= 0:
		return false

	# 处理移动完成后的状态更新
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")
	if moveStopped > 0:
		# 移动完成，更新状态
		status[0] = 0
		if status[1] >= MAX_STEPS_PER_TURN:
			ske.cost_war_cd(1)
		return false

	match moveType:
		1: # 尝试移动
			status[1] += 1
			if status[1] > 0 and status[1] <= MAX_STEPS_PER_TURN:
				actor.add_exp(-EXP_COST_PER_STEP)
		-1: # 撤回移动
			status[1] -= 1
			if status[1] >= 0 and status[1] < MAX_STEPS_PER_TURN:
				actor.add_exp(EXP_COST_PER_STEP)
	ske.set_war_skill_val(status, 1)
	if status[1] >= 0 and status[1] <= MAX_STEPS_PER_TURN:
		var msgs = DataManager.get_env_str("对白").split("\n")
		if msgs.size() <= 3:
			var msg = "【{0}】：{1}/{2}步，经验：{3}".format([
				ske.skill_name, status[1], MAX_STEPS_PER_TURN, actor.get_exp()
			])
			msgs.append(msg)
		DataManager.set_env("对白", "\n".join(msgs))
	return false

func _get_skill_status() -> PoolIntArray:
	var status = ske.get_war_skill_val_int_array()
	if status.size() != 2:
		status = [0, 0]
	return status
