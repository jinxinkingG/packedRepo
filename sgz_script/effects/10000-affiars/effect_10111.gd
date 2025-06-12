extends "effect_10000.gd"

# 衡法效果
#【衡法】内政，锁定技。你执行内政开发和防灾时，优先采用“你能执行的最高金额项目”，且开发效果随机值最大。

func on_trigger_10002()->bool:
	var cmd = DataManager.get_current_develop_command()
	cmd.randomMax = 1
	cmd.append_extra_message("【{0}】令随机效果最大化".format([ske.skill_name]))
	return false
