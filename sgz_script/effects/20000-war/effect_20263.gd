extends "effect_20000.gd"

#进策等令队友免费移动效果实现，TODO 未来可以考虑其他类似技能触发复用
#【进策】大战场,主动技。你可以消耗10点机动力，指定一个你方武将，该武将立即进入移动状态，可以移动5步，无需消耗机动力。每2回合限1次

const FREE_STEPS = 5

func on_trigger_20007()->bool:
	var setting = get_skill_setting()
	var freeSteps = setting[0]
	if freeSteps <= 0:
		return false
	if setting[2] >= 0 and setting[2] != actorId:
		return false
	set_max_move_ap_cost([], 0)
	return false

func on_trigger_20003()->bool:
	var setting = get_skill_setting()
	var freeSteps = setting[0]
	var source = setting[1]
	if source != ske.skill_name:
		return false
	if setting[2] >= 0 and setting[2] != actorId:
		return false
	match get_move_type():
		1: # 尝试移动
			freeSteps -= 1
		-1: # 撤回移动
			freeSteps += 1
	ske.set_war_skill_val([freeSteps, source, actorId], 1, -1, ske.actorId)
	if freeSteps < 0:
		return false
	var msg = DataManager.get_env_str("对白")
	if msg.split("\n").size() >= 3:
		return false
	msg += "\n{0}【{1}】剩余：{2}步".format([
		me.get_name(), source, freeSteps,
	])
	DataManager.set_env("对白", msg)
	return false

# 兼容两种设置和输入方式
# @return [步数, 来源技能]
func get_skill_setting() -> Array:
	var freeSteps = -1
	var source = ske.skill_name
	var fromId = -1
	var freeStepInfo = ske.get_war_skill_val_array(-1, ske.actorId)
	if freeStepInfo.size() >= 2:
		freeSteps = Global.intval(freeStepInfo[0])
		source = Global.strval(freeStepInfo[1])
		if freeStepInfo.size() == 3:
			fromId = Global.intval(freeStepInfo[2])
	else:
		freeSteps = ske.get_war_skill_val_int(-1, ske.actorId, -1)
	return [freeSteps, source, fromId]
