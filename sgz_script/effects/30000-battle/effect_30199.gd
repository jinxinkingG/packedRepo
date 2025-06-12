extends "effect_30000.gd"

#射马锁定技
#【射马】【射马】小战场，锁定技。你方单位射出的箭矢命中敌方骑兵或武将单位时，那个对方单位下次行动有X%的概率只能行动1步（X=你的等级*8）。

func on_trigger_30002()->bool:
	var bu = get_action_unit()
	if bu == null or bu.leaderId == me.actorId:
		return false
	if not bu.dic_combat.has(ske.skill_name):
		return false
	var rate = int(bu.dic_combat[ske.skill_name])
	bu.dic_combat.erase(ske.skill_name)
	if not Global.get_rate_result(rate):
		return false
	bu.remove_action_task()
	bu.wait_action_times = 0
	bu.add_status_effect("伤残#FF0000")
	return false

func on_trigger_30023()->bool:
	var bu = ske.battle_is_unit_hit_by(["ALL"], ["骑", "将"], ["射箭"])
	if bu == null:
		return false
	var hurtId = get_env_int("白兵伤害.单位")
	var hurt = get_battle_unit(hurtId)
	if hurt == null or hurt.disabled:
		return false

	var x = actor.get_level() * 8
	hurt.dic_combat[ske.skill_name] = x
	
	bu.add_status_effect("射马")
	return false
