extends "effect_20000.gd"

#协力锁定技 #攻击机动力
#【协力】大战场，锁定技。你方其他武将伤兵计成功时，本回合结束前，你临时获得<耀武>和<勇进>。

const BUFF_SKILLS = ["耀武", "勇进"]

func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false
	if se.get_action_id(actorId) == actorId:
		return false
	ske.cost_war_cd(1)
	for skill in BUFF_SKILLS:
		ske.add_war_skill(actorId, skill, 1)
	var msg = "协力同心，金石辟易！\n（回合结束前\n（获得【{0}】".format([
		"】【".join(BUFF_SKILLS)
	])
	me.attach_free_dialog(msg, 0)
	return false
