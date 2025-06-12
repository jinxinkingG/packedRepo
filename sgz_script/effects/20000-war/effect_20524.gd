extends "effect_20000.gd"

#恩绝锁定效果
#【恩绝】大战场，限定技。刷新敌方主将点数，若你的点数比对方大：直到回合结束前禁用其「锁定」和「主将」类技能；否则，你立刻执行一次机动力恢复。若以此法禁用了敌将技能，己方对攻击那名敌将时，解除封禁效果。

const ACTIVE_EFFECT_ID = 20523

func on_trigger_20015() -> bool:
	var enemyLeader = me.get_enemy_leader()
	if enemyLeader == null:
		return false
	var bf = DataManager.get_current_battle_fight()
	if bf.get_defender_id() != enemyLeader.actorId:
		return false
	return cancel_effect_if_any(enemyLeader)

func on_trigger_20027() -> bool:
	var enemyLeader = me.get_enemy_leader()
	if enemyLeader == null:
		return false
	return cancel_effect_if_any(enemyLeader)

func cancel_effect_if_any(wa:War_Actor) -> bool:
	if wa == null:
		return false
	var banned = ske.get_war_skill_val_array(ACTIVE_EFFECT_ID, wa.actorId)
	if banned.empty():
		return false
	SkillHelper.clear_ban_actor_skill(20000, [wa.actorId], banned)
	return false
