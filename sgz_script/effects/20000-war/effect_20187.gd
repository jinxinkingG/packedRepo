extends "effect_20000.gd"

#头阵锁定技 #机动力
#【头阵】大战场,锁定技。本回合，若你是我方第一个进入白兵的武将，此次攻击返回双倍机动力

const EFFECT_ID = 20187

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	# 无论是谁首次触发，都设置 CD
	ske.cost_war_cd(1)
	if ske.actorId != me.actorId:
		# 不是自己
		return false
	# 自己进入战斗
	var ap = bf.ap * 2
	if ap <= 0:
		return false
	ske.change_actor_ap(me.actorId, ap)
	ske.war_report()
	return false

