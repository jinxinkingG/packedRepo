extends "effect_10000.gd"

# 告发效果锁定技
#【告发】内政，锁定技。同城的武将被离间/招揽时，优先由你汇报结果，每次你的经验+500。

const EXP_GAIN = 500

const MESSAGES = {
	"招揽": ["{0}尝与外人交接\n必有异动", "大事不好！\n{0}叛逃矣"],
	"离间": ["{0}行止可疑\n不可不防", "{0}行止可疑\n或存异心"],
}

func on_trigger_10016()->bool:
	var cmd = DataManager.get_current_policy_command()
	if cmd == null:
		return false
	if cmd.targetActorId == actorId:
		return false
	if not cmd.type in ["招揽", "离间"]:
		return false
	var idx = 1 if cmd.result > 0 else 0
	var msg = MESSAGES[cmd.type][idx]
	actor.add_exp(EXP_GAIN)
	msg += "\n（{2}【{1}】经验 +{3}"
	msg = msg.format([
		cmd.target_actor().get_name(), ske.skill_name,
		actor.get_name(), EXP_GAIN
	])
	cmd.append_result_messages(msg.split("\n"), 2, actorId, cmd.target_city().ID)
	return false
