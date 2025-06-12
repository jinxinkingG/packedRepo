extends "effect_20000.gd"

#行歇锁定效果
#【行歇】大战场，主动技。你每移动一步，你的[歇]标记+1，上限20个。你可以发动本技能：每消耗2个[歇]标记，你的体+1。

const FLAG_EFFECT_ID = 20521
const FLAG_NAME = "歇"
const FLAG_LIMIT = 20

func on_trigger_20003() -> bool:
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")
	if moveType != 0:
		ske.add_skill_flags(20000, FLAG_EFFECT_ID, FLAG_NAME, moveType, FLAG_LIMIT)
	return false
