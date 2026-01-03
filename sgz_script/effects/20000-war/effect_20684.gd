extends "effect_20000.gd"

# 摸鱼效果
#【摸鱼】大战场，锁定技。每日初始，若你的机动力恢复时，超过上限。则你的经验+30X。X为机动力超出的数量，且最多为20。

const EXP_GAIN = 30
const AP_EXP_LIMIT = 20

func on_trigger_20013() -> bool:
	var apOverflow = get_env_int("战争.机动力溢出.{0}".format([actorId]))
	if apOverflow <= 0:
		return false
	var expGain = min(apOverflow, AP_EXP_LIMIT) * EXP_GAIN
	expGain = ske.change_actor_exp(actorId, expGain)
	if expGain <= 0:
		return false
	ske.war_report()

	var msg = "难得半日闲 ……\n（【{0}】经验 +{1}".format([
		ske.skill_name, expGain,
	])
	me.attach_free_dialog(msg, 1)
	return false
