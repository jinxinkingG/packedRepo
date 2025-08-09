extends "effect_20000.gd"

# 毒泉效果
#【毒泉】大战场，锁定技。战争初始，若你为守方，四面泉眼招来恶灵，所有敌将体力上限-10，该效果最多将体力上限降至40。

const MAX_HP_DEBUFF = 10
const MAX_HP_MIN = 40

func on_trigger_20019() -> bool:
	ske.cost_war_cd(99999)
	for wa in wf.get_war_actors(false, true):
		if not me.is_enemy(wa):
			continue
		ske.change_actor_max_hp(wa.actorId, -MAX_HP_DEBUFF, MAX_HP_MIN)
	ske.war_report()

	var enemyLeader = me.get_enemy_leader()
	var msg = "瘴毒乃神罚，{0}何计可施！\n（{1}军全体体上限 -{2}".format([
		DataManager.get_actor_naughty_title(enemyLeader.actorId, actorId),
		enemyLeader.get_name(), MAX_HP_DEBUFF,
	])
	me.attach_free_dialog(msg, 0)
	return false
