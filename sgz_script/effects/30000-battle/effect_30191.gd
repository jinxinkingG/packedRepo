extends "effect_30000.gd"

#英烈锁定技 #武将强化 #格挡
#【英烈】大战场，主将锁定技。你方武将白刃战时，武将本身：对敌兵造成伤害结果+2X，且格挡率+X%，X＝你与该武将等级平均值。

func on_trigger_30021()->bool:
	var teammate = ActorHelper.actor(ske.actorId)
	var x = int((actor.get_level() + teammate.get_level()) / 2)
	var bu = ske.battle_extra_damage(x * 2, ["将"], ["ALL"], UNIT_TYPE_SOLDIERS)
	if bu == null:
		return false
	var msg = "{0} +{1}#FF0000".format([ske.skill_name, x * 2])
	bu.add_status_effect(msg)
	return false

func on_trigger_30005()->bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	var bu = wa.battle_actor_unit()
	if bu == null or bu.disabled:
		return false
	var x = int((actor.get_level() + wa.actor().get_level()) / 2)
	var buff = {
		"格挡率": x,
		"BUFF": 1,
	}
	ske.battle_buff_unit(bu, buff)
	return false
