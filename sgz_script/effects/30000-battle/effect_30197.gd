extends "effect_30000.gd"

#屡战锁定技
#【屡战】大战场，锁定技。若你白刃战失败，兵力恢复本次白刃战损失兵力的50%。

func check_trigger_correct():
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false

	if bf.loserId != me.actorId:
		return false

	var prev = 0
	if me.actorId == bf.get_attacker_id():
		prev = bf.attackerSoldiers
	elif me.actorId == bf.get_defender_id():
		prev = bf.defenderSoldiers
	else:
		return false

	var current = me.get_soldiers()
	var recover = int((prev - current) / 2)
	if recover <= 0:
		return false
	ske.change_actor_soldiers(me.actorId, recover)
	# 虽然是小战场触发，但属于大战场效果，汇报大战场日志
	ske.war_report()
	var msg = "败而知耻，自当后勇\n竖将旗，收拢残部再战！\n（因【{0}】士兵回复{1}".format([
		ske.skill_name, recover,
	])
	var d = append_free_dialog(me, msg, 0)
	# 大战场对话
	d.sceneId = 20000
	return false
