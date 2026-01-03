extends "effect_20000.gd"

# 诳武战后效果
#【诳武】大战场，主动技。你可消耗所有机动力（至少1），选择1名相邻敌将发动。你与之进入白刃战，若此战你获胜，恢复因发动而消耗的机动力，每回合限3次。

func on_trigger_20020() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.source != ske.skill_name:
		return false
	var ap = ske.get_war_skill_val_int()
	if ap <= 0:
		return false
	var winner = bf.get_winner()
	if winner == null or winner.actorId != actorId:
		return false
	ap = ske.change_actor_ap(actorId, ap)
	ske.war_report()

	var msg = "不堪一击！\n（【{0}】机动力回复 {1}".format([
		ske.skill_name, ap
	])
	me.attach_free_dialog(msg, 1)
	return false
