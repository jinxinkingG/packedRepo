extends "effect_10000.gd"

#智辩效果
#【智辩】内政,锁定技。你执行“说服”和“”离间”时，视为德99，政99，且离间成功时，对方忠额外-（你的等级/2）

func on_trigger_10004()->bool:
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or not cmd.type in ["离间", "招揽", "策反"]:
		return false
	cmd.actionPolitics = 99
	cmd.actionMoral = 99
	cmd.append_extra_effect(ske.skill_name, actorId, int(actor.get_level() / 2))
	return false
