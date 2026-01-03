extends "effect_20000.gd"

#奸雄锁定技
#【奸雄】大战场，锁定技。你方武将被用计时：若被伤兵，则用计者兵力下降50，该50点伤害视为被用计者的技能型伤害；若未被伤兵，则该用计者机动力-3。

const REFLECT_DAMAGE = 50

func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	# 允许隐身用计，无视反伤
	var fromId = se.get_action_id(actorId)
	if fromId != ske.actorId:
		return false
	if not se.damage_soldier():
		return false
	var damaged = false
	for targetId in se.get_all_damaged_targets():
		var target = DataManager.get_war_actor(targetId)
		if target == null:
			continue
		if target.actorId == actorId or me.is_teammate(target):
			# 伤到我的队友
			damaged = true
			break
	if damaged:
		# 由主要受计者对计策发动者造成50反伤
		var fromActor = ActorHelper.actor(fromId)
		var reflectedDamage = min(fromActor.get_soldiers(), REFLECT_DAMAGE)
		if reflectedDamage <= 0:
			return false
		DataManager.damage_sodiers(se.targetId, fromId, reflectedDamage)
		se.append_result("反伤", ske.skill_name, reflectedDamage, actorId)
	else:
		var ap = ske.change_actor_ap(fromId, -3)
		if ap < 0:
			se.append_result("机动力", ske.skill_name, ap, fromId)
	return false
