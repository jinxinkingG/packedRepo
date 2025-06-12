extends "effect_30000.gd"

#色胆效果实现
#【色胆】小战场,锁定技。若对方是女性，对方开局获得10回合咒缚；否则，你的胆+x，x=你的等级

func on_trigger_30006():
	var enemy = me.get_battle_enemy_war_actor()
	if enemy == null:
		return false
	if enemy.actor().get_gender() == "女":
		enemy.set_buff("咒缚", 10, enemy.actorId)
		return false
	var sbp = ske.get_battle_skill_property()
	sbp.courage += actor.get_level()
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	return false
