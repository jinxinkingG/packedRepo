extends "effect_30000.gd"

#虎魄技能实现，注意为敌方触发
#【虎魄】小战场，锁定技。你未装备“丈八蛇矛”时，敌方对方统-10，胆-15；否则，你五行为木、火时，也附加<咆哮>。

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var actor = ActorHelper.actor(self.actorId)
	if actor.get_weapon().id != StaticManager.WEAPON_ID_SHEMAO:
		return ret
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return ret
	match me.five_phases:
		War_Character.FivePhases_Enum.Wood:
			ret.append("咆哮")
		War_Character.FivePhases_Enum.Fire:
			ret.append("咆哮")
	return ret

func on_trigger_30006():
	var bf = DataManager.get_current_battle_fight()
	if bf.get_attacker_id() != me.actorId \
		and bf.get_defender_id() != me.actorId:
		return false
	var enemy = me.get_battle_enemy_war_actor()
	if enemy == null or enemy.actorId != ske.actorId:
		return false
	if actor.get_weapon().id == StaticManager.WEAPON_ID_SHEMAO:
		return false
	var sbp = ske.get_battle_skill_property()
	sbp.courage -= 15
	sbp.leader -= 10
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	return false
