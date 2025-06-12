extends "effect_20000.gd"

#明败锁定技
#【明败】大战场，锁定技。你的队友白刃战败时，使其额外获得本次白刃战所损失兵力数的一半经验值。

func on_trigger_20020() -> bool:
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null or loser.disabled:
		# 找不到战败者或战败者已败亡
		return false
	if loser.actorId != ske.actorId:
		# 非战败者触发
		return false
	if loser.actorId == me.actorId:
		# 自己不触发
		return false
	if not me.is_teammate(loser):
		# 已非队友
		return false
	var lostSoldiers = 0
	if loser.actorId == bf.get_attacker_id():
		lostSoldiers = bf.attackerSoldiers - bf.attackerRemaining
	else:
		lostSoldiers = bf.defenderSoldiers - bf.defenderRemaining
	var learning = int(lostSoldiers / 2)
	if learning <= 0:
		return false
	ske.change_actor_exp(loser.actorId, learning)
	var marked = ske.get_war_skill_val_int_array()
	if not loser.actorId in marked:
		marked.append(loser.actorId)
	ske.set_war_skill_val(marked, 1)
	ske.war_report()
	return false
