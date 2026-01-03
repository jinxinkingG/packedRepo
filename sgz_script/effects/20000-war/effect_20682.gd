extends "effect_20000.gd"

# 连杀锁定效果
#【连杀】大战场，限定技。你可指定1名敌将，对之发起攻击，之后你的机动力清零。若以此法造成敌将被击杀/俘虏，重置该技能冷却。

const ACTIVE_EFFECT_ID = 20681

func on_trigger_20020() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.source != ske.skill_name:
		return false
	var winner = bf.get_winner()
	if winner == null or winner.actorId != actorId:
		return false
	if actorId != bf.get_attacker_id():
		return false
	var loser = bf.get_loser()
	if loser == null or not loser.disabled:
		return false
	if loser.actorId != ske.get_war_skill_val_int(ACTIVE_EFFECT_ID):
		return false
	if not loser.actor().is_status_captured() \
		and not loser.actor().is_status_dead():
		return false
	ske.clear_actor_skill_cd(actorId, [20000], [ACTIVE_EFFECT_ID], -1, 99999)
	ske.war_report()

	var msg = "下一个！\n（重置【{0}】冷却".format([
		ske.skill_name,
	])
	me.attach_free_dialog(msg, 0)
	return false
