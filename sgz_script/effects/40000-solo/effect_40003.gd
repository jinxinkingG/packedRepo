extends "effect_40000.gd"

#招架效果
#【招架】单挑，锁定技。①你体力＞60时，若承受的伤害＞20，你消耗20点体力，完全格挡本次伤害。②你主动退出单挑时，直接退出小战场，并且体力减为1。

const COST_HP = 20

func on_trigger_40003()->bool:
	var extraMsgs = DataManager.get_env_array("单挑.补充信息")
	var damage = DataManager.get_env_int("单挑.伤害数值")
	if actor.get_hp() > 60 and damage > COST_HP:
		actor.set_hp(actor.get_hp() - COST_HP)
		DataManager.set_env("单挑.伤害数值", 0)
		var msg = "{0}【{1}】消耗{2}体格挡".format([
			actor.get_name(), ske.skill_name, COST_HP
		])
		extraMsgs.append(msg)
		DataManager.set_env("单挑.补充信息", extraMsgs)
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
