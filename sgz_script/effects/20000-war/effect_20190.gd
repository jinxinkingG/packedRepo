extends "effect_20000.gd"

#急功被动效果部分
#【急功】大战场,限定技。发动后：你立刻解除定止，并进入移动模式，体＞10时，可以此法进行的移动不消耗机动力，每步消耗5体力，可随时退出本移动状态。

const ACTIVE_EFFECT_ID = 20189
const MIN_HP = 10
const COST_HP = 5

func on_trigger_20007()->bool:
	# 检查急功状态
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) != 1:
		return false
	if not check_env([KEY_MOVE_AP_COST]):
		return false
	# 检查体力
	if actor.get_hp() < MIN_HP:
		# 通过模拟机动力不足的情况，实现体力不足时禁止移动的效果
		set_env(KEY_MOVE_AP_COST, me.action_point + 1)
		return false
	set_env(KEY_MOVE_AP_COST, 0)
	return false

func on_trigger_20003()->bool:
	# 检查急功状态
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) != 1:
		return false
	match DataManager.get_env_int("移动", -99):
		1: # 前进一步
			ske.change_actor_hp(actorId, -COST_HP)
		-1: # 后退一步
			ske.change_actor_hp(actorId, COST_HP)
		0: # 进入或结束移动模式
			if DataManager.get_env_int("结束移动") != 1:
				return false
			# 结束移动，清除急功状态
			ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
			# 判断历史记录
			var moveHistory = get_env_array("历史移动记录")
			if moveHistory.empty():
				# 没有有效移动
				ske.clear_actor_skill_cd(actorId, [], [ACTIVE_EFFECT_ID])
	var msg = "（体: {0}）".format([int(ceil(actor.get_hp()))])
	var msgs = DataManager.get_env_str("对白").split("\n")
	if msgs.size() == 2:
		msgs.append(msg)
	else:
		msgs[2] = msgs[2].replace("）", "，") + msg.right(1)
	DataManager.set_env("对白", "\n".join(msgs))
	return false
