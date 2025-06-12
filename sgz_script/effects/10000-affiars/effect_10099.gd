extends "effect_10000.gd"

#策蛮效果
#【策蛮】内政，锁定技。你执行策反指令时，政以99计算；若你策反<蛮裔>武将成功，被策反的新势力与你方结盟12月。

func on_trigger_10004()->bool:
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or not cmd.type in ["策反"]:
		return false
	cmd.actionPolitics = 99
	return false

func on_trigger_10012()->bool:
	if DataManager.get_env_str("内政.命令") != "策略":
		return false
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or not cmd.type in ["策反"]:
		return false
	if cmd.result <= 0:
		# 未成功
		return false
	var target = cmd.target_actor()
	if not "蛮裔" in SkillHelper.get_actor_unlocked_skill_names(target.actorId).values():
		return false
	# 与策反势力结盟一年
	var newVstateId = cmd.target_city().get_vstate_id()
	var ourVstateId = cmd.city().get_vstate_id()
	clVState.set_alliance(ourVstateId, newVstateId, 12)
	# 消息提示
	var msg = "蛮裔相亲\n已与{0}缔结盟约\n为期12个月".format([
		target.get_name(),
	])
	cmd.append_result_messages([msg], 1)
	return false
