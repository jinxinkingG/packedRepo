extends "effect_30000.gd"

#逆骑被动部分
#【逆骑】小战场，主动技。你为城地形的防守方可使用：消耗20金，使你方所有士兵变为骑兵，每个大战场回合限1次。使用本技能后，若本次白刃战你获胜，重置本技能冷却，你的兵力恢复100。

const ACTIVE_EFFECT_ID = 30253
const SOLDIERS_RECOVER = 100

func on_trigger_30003() -> bool:
	ske.battle_set_skill_val([me.get_soldiers(), 0], 99999)
	return false

func on_trigger_30004() -> bool:
	var recorded = ske.battle_get_skill_val_int_array()
	if recorded.size() != 2 or recorded[1] <= 0:
		return false
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null or loser.actorId == actorId:
		return false
	# 归整
	ske.change_actor_soldiers(actorId, SOLDIERS_RECOVER, recorded[0])
	ske.clear_actor_skill_cd(actorId, [], [ACTIVE_EFFECT_ID])
	# 汇报到大战场
	ske.war_report()
	return false
