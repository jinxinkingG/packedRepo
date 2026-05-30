extends "effect_20000.gd"

# 垫机锁定效果（白刃战结束后转嫁损失）
#【垫机】白刃战结束后，计算己方损失的兵力，由目标敌将代为损失。

const ACTIVE_EFFECT_ID = 20726

func on_trigger_20020() -> bool:
	if bf == null:
		return false

	# 检查本次白刃战中自己是否为被攻击方
	if actorId != bf.get_defender_id():
		return false

	# 检查是否有垫机状态
	var status = ske.get_war_skill_val_int_array(ACTIVE_EFFECT_ID)
	if status.size() != 2:
		return false

	var targetId = status[0]
	var prevSoldiers = status[1]

	# 清除垫机状态（无论是否生效都要清理）
	ske.set_war_skill_val(null, 0, ACTIVE_EFFECT_ID)

	# 检查目标敌将是否仍然有效
	var targetWa = DataManager.get_war_actor(targetId)
	if targetWa == null or targetWa.disabled:
		return false

	# 计算兵力损失
	var currentSoldiers = actor.get_soldiers()
	var loss = prevSoldiers - currentSoldiers
	if loss <= 0:
		return false

	# 让目标敌将损失同等兵力
	var actualLoss = ske.change_actor_soldiers(targetId, -loss)
	if actualLoss != 0:
		ske.change_actor_soldiers(actorId, abs(actualLoss))
	ske.war_report()

	# 植入对话
	var targetName = DataManager.get_actor_naughty_title(targetId, actorId)
	var msg = "【{0}】效果\n{1}代偿损失兵力 {2}".format([
		ske.skill_name, targetName, abs(actualLoss),
	])
	me.attach_free_dialog(msg, 1)

	return false
