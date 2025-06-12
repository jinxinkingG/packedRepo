extends "effect_10000.gd"

#疑异锁定技
#【疑异】内政，锁定技。你所在城其他武将被离间/招揽/策反成功时，你增加500经验。

const EXP_GAIN = 500

const MESSAGES = {
	"招揽": "吾观{0}，素怀异志\n果不出所料",
	"离间": "{0}行止，大不寻常\n必起异心",
	"策反": "{0}野望素著\n今日之事，实非无因",
}

func on_trigger_10016()->bool:
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or cmd.result <= 0:
		return false
	if cmd.targetActorId == actorId:
		return false
	if not cmd.type in MESSAGES:
		return false
	var msg = MESSAGES[cmd.type]
	actor.add_exp(EXP_GAIN)
	msg += "\n（{2}【{1}】经验 +{3}"
	msg = msg.format([
		cmd.target_actor().get_name(), ske.skill_name,
		actor.get_name(), EXP_GAIN
	])
	cmd.append_result_messages(msg.split("\n"), 2, actorId, cmd.target_city().ID)
	return false
