extends "effect_20000.gd"

#让贤锁定技部分
#【让贤】大战场，主将限定技。你为防守方的场合，指定1名队友为目标发动。直到战争结束前：每次己方回合结束时，自动消耗你的兵力，最大限度的为该武将补充兵力。（不超过其兵力上限）

func on_trigger_20016()->bool:
	var targetId = ske.get_war_skill_val_int(ske.effect_Id, ske.skill_actorId, -1)
	if targetId < 0:
		return false
	var target = DataManager.get_war_actor(targetId)
	if target == null or target.disabled or not me.is_teammate(target):
		return false
	var targetActor = ActorHelper.actor(targetId)
	var maxSoldiers = DataManager.get_actor_max_soldiers(targetId)
	var diff = maxSoldiers - targetActor.get_soldiers()
	if diff <= 0:
		return false
	
	# 在转移前，忽略临时兵力的影响
	var tmp = actor.get_tmp_soldiers()
	actor.remove_tmp_soldiers()
	# 有多少扣多少
	diff = ske.sub_actor_soldiers(me.actorId, diff)
	# 恢复临时兵力
	actor.add_tmp_soldiers(tmp)
	if diff == 0:
		return false
	# 扣多少加多少
	diff = ske.add_actor_soldiers(targetId, diff)
	var msg = "君之武略，远胜于我\n兵马足备，赖君破敌\n（援助{0}{1}兵力".format([
		target.get_name(), diff,
	])
	ske.war_report()
	append_free_dialog(me, msg, 1)
	return false
