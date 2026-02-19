extends "effect_40000.gd"

#招架效果
#【招架】单挑，锁定技。①你体力＞60时，若承受的伤害＞20，你消耗20点体力，完全格挡本次伤害。②你主动退出单挑时，直接退出小战场，并且体力减为1。

func on_trigger_40003()->bool:
	var damage = DataManager.get_env_int("单挑.伤害数值")
	if actor.get_hp() > 60:
		damage = min(damage, 20)
		DataManager.set_env("单挑.伤害数值", damage)
	return false

func on_trigger_40006()->bool:
	var bu = me.battle_actor_unit()
	if bu == null:
		return false
	actor.set_hp(min(actor.get_hp(), 1))
	var bf = DataManager.get_current_battle_fight()
	bf.loserId = actorId
	bf.lostType = BattleFight.ResultEnum.ActorRetreat
	bu.disabled = true
	bu.unit_position = Vector2(-5, -5)
	return false
