extends "effect_20000.gd"

#猛探锁定技 #胜利触发 #失败触发 #机动力 #施加状态
#【猛探】大战场,锁定技。你白兵每胜利一次，则你方主将机动力+3，每回合限3次；每失败一次，则你方主将定止回合数+1，每回合限1次。

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	var loser = bf.get_loser()
	if loser == null:
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null:
		return false

	if winner.actorId == me.actorId:
		# 白兵胜利
		var res = _mark_battle_result(true)
		if res[0] > 3:
			return false
		# 前三次胜利
		ske.change_actor_ap(me.get_main_actor_id(), 3)

	if loser.actorId == me.actorId:
		# 白兵失败
		var res = _mark_battle_result(false)
		if res[1] > 1:
			return false
		# 第一次失败
		var stopTurns = 1
		# 绕一圈取胜者的敌方主将，避免自身转换阵营带来问题
		var winnerWV = winner.war_vstate()
		var leaderId = winnerWV.get_enemy_vstate().main_actorId
		var leader = DataManager.get_war_actor(leaderId)
		if leader == null:
			return false
		var stopped = leader.get_buff("定止")
		if stopped["回合数"] > 0:
			stopTurns = int(stopped["回合数"]) + 1
		ske.set_war_buff(leader.actorId, "定止", stopTurns)

	ske.war_report()
	return false

# 累加记录本回合白兵战结果，并返回累计后的状态
func _mark_battle_result(won:bool):
	var wonTimes = 0
	var lostTimes = 0
	var skv = SkillHelper.get_skill_variable(20000, 20114, self.actorId)
	if skv["turn"] > 0 and skv["value"] != null:
		var parsed = str(skv["value"]).split("|")
		wonTimes = int(parsed[0])
		lostTimes = int(parsed[1])
	if won:
		wonTimes += 1
	else:
		lostTimes += 1
	var val = "{0}|{1}".format([wonTimes, lostTimes])
	SkillHelper.set_skill_variable(20000, 20114, self.actorId, val, 1)
	return [wonTimes, lostTimes]
