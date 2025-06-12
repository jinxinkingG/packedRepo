extends "effect_10000.gd"

#警讯锁定技
#【警讯】内政，太守锁定技。敌方对你所在的城市，执行离间、招揽指令，有X%的概率直接失败。X=你的等级×6

func on_trigger_10014()->bool:
	if not Global.get_rate_result(actor.get_level() * 6):
		return false
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or not cmd.type in ["离间", "招揽"]:
		return false
	cmd.actionPolitics = 0
	cmd.actionMoral = 0
	var msg = "敌探活动频繁\n可疑人等，尔等须严加盘查！"
	cmd.append_result_messages(msg.split("\n"), 0, actorId, cmd.target_city().ID)
	msg = "因{0}【{1}】，策略失败".format([
		actor.get_name(), ske.skill_name,
	])
	cmd.append_extra_message(msg)
	return false
