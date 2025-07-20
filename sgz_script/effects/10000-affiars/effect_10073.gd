extends "effect_10000.gd"

#禁绝锁定技
#【禁绝】内政，太守锁定技。被招揽成功时，可以选择出面挽留：使之留下来。每3个月限1次。

func on_trigger_10016()->bool:
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or not cmd.type in ["招揽"]:
		return false
	if cmd.result <= 0:
		return false
	var target = cmd.target_actor()
	if target.actorId == actorId:
		return false
	ske.affair_cd(3)
	cmd.result = 0
	var msg = "既如此，{0}不宜久留\n这便动身吧".format([
		cmd.target_city().get_full_name(),
	])
	cmd.append_result_messages(msg.split("\n"), 1, target.actorId, cmd.target_city().ID)
	msg = "素日未尝薄待，何以至此？\n{0}且回，吾既往不咎".format([
		DataManager.get_actor_honored_title(target.actorId, actorId)
	])
	cmd.append_result_messages(msg.split("\n"), 2, actorId, cmd.target_city().ID)
	msg = "惭愧，{0}本已意动\n奈何为{1}【{2}】\n招揽失败".format([
		target.get_name(), actor.get_name(), ske.skill_name,
	])
	cmd.append_result_messages(msg.split("\n"), 3)
	return false
