extends "effect_10000.gd"

#勤政锁定效果
#【勤政】内政，锁定技，你所在城的其他武将执行开发(土地/产业/人口)时，视为你也执行一次同样的行动。

func on_trigger_10019()->bool:
	var cmd = DataManager.get_current_develop_command()
	if cmd.type == "防灾":
		return false
	if cmd.source == ske.skill_name:
		# 避免反复触发
		return false
	if ske.actorId == actorId:
		# 自己开发不触发
		return false
	var city = cmd.city()
	var cost = cmd.cost
	var lastActionId = cmd.lastActionId
	# 保存当前 cmd
	var prevCmd = cmd
	cmd = DataManager.new_develop_command(prevCmd.type, actorId, city.ID)
	cmd.source = ske.skill_name
	cmd.decide_cost()
	cmd.cost = prevCmd.cost
	# 免费开发
	cmd.realCost = 0
	cmd.execute()
	cmd.lastActionId = lastActionId
	# 恢复环境
	DataManager.affair_command = prevCmd
	if DataManager.get_scene_actor_control(actorId) < 0:
		return false
	if prevCmd.delegated > 0:
		# 委任日志
		prevCmd.affair_report()
		var msg = "- <r{0}>发动【{1}】".format([
			actor.get_name(), ske.skill_name
		])
		DataManager.record_affair_log(msg)
		cmd.affair_report()
		return false
	# 正常播报
	var msg = "政荒于怠而精于勤\n（{0}跟进开发{1}".format([
		cmd.actioner().get_name(), cmd.type,
	])
	city.attach_free_dialog(msg, cmd.actionId)
	var msgs = cmd.get_result_messages()
	while msgs.size() > 3:
		msg = "\n".join(msgs.slice(0, 2))
		city.attach_free_dialog(msg, cmd.actionId, 1)
		msgs = msgs.slice(3, msgs.size() - 1)
	if not msgs.empty():
		msg = "\n".join(msgs)
		city.attach_free_dialog(msg, cmd.actionId, 1)
	return false
