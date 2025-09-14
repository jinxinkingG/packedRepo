extends "effect_20000.gd"

# 冒进被动效果部分
#【冒进】大战场，主动技。你可以不消耗机动力，移动3步，并获得1回合 {围困} 状态，每2回合限1次。

func on_trigger_20003() -> bool:
	var setting = ske.get_war_skill_val_int_array()
	if setting.size() != 2 or setting[0] <= 0:
		return false
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")
	match moveType:
		1:
			setting[1] += 1
			var msg = "【{0}】可自由移动{1}步".format([ske.skill_name, setting[0] - setting[1]])
			DataManager.set_env("对白", msg)
		-1:
			setting[1] -= 1
			var msg = "【{0}】可自由移动{1}步".format([ske.skill_name, setting[0] - setting[1]])
			DataManager.set_env("对白", msg)
	ske.set_war_skill_val(setting, 1)
	return false

func on_trigger_20007() -> bool:
	var setting = ske.get_war_skill_val_int_array()
	if setting.size() != 2 or setting[0] <= 0:
		return false
	var limit = setting[0]
	var moved = setting[1]
	if moved < limit:
		DataManager.set_env("行军消耗机动力", 0)
	else:
		DataManager.set_env("行军消耗机动力", 99999)
	return false
