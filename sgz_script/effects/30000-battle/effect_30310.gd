extends "effect_30000.gd"

# 神魂锁定技
#【神魂】大战场，锁定技。你与敌方即将进入白刃战时，若敌方的五行与你不同，直接扣除敌将一半兵力，结算为对方失败。

func on_trigger_30003() -> bool:
	if enemy.five_phases == me.five_phases:
		return false
	# 保留战后兵力
	var recover = bf.get_env_dict("战后兵力")
	recover[str(actorId)] = actor.get_soldiers()
	# 0 兵出场
	actor.set_soldiers(0)
	return false

func on_trigger_30005() -> bool:
	if enemy.five_phases == me.five_phases:
		return false

	# 模拟损兵
	var recover = bf.get_env_dict("战后兵力")
	var soldiers = enemy.actor().get_soldiers()
	var lost = 0
	if soldiers > 0:
		lost = int(soldiers / 2)
		var key = str(enemy.actorId)
		if key in recover:
			soldiers = recover[key]
		recover[key] = soldiers - lost
		bf.set_env("战后兵力", recover)
	bf.loserId = enemy.actorId
	bf.lostType = BattleFight.ResultEnum.NoMind
	ske.battle_cd(99999)

	var battleMsg = "凡愚退散！\n（【{0}】效果\n（{1}败退".format([
		ske.skill_name, enemy.get_name(),
	])
	me.attach_free_dialog(battleMsg, 0, 30000)

	var msg = "是何妖法！"
	if lost > 0:
		msg += "\n（损兵 {0}".format([lost])
	enemy.attach_free_dialog(msg, 0, 20000)

	return false
