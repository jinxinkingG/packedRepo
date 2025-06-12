extends "effect_30000.gd"

#暗杀小战场的锁定效果，包括阵型和结束时退回所有保存的兵力
#【暗杀】大战场，主动技。若你于本场战争未获得过负面状态，你可指定1名敌将作为目标，消耗5点机动力发动。你与目标进入白刃战；仅在此次白刃战中，你的兵力视为0，并获得3动效果。每回合限一次

const ACTIVE_EFFECT_ID = 20394

func on_trigger_30004()->bool:
	#获取暗杀标记
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	#获得劫营前的兵力
	var soldiers = ske.get_battle_skill_val_int()
	actor.set_soldiers(soldiers)
	# 暂不判断，默认劫营为进攻
	bf.attackerSoldiers = soldiers
	bf.attackerRemaining = soldiers
	return false

func on_trigger_30003()->bool:
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	ske.set_battle_skill_val(actor.get_soldiers())
	actor.set_soldiers(0)
	# 修正白兵战数据
	bf.attackerSoldiers = 0

	return false

func on_trigger_30005()->bool:
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	var bu = me.battle_actor_unit()
	bu.dic_combat[ske.skill_name] = 1
	bu.set_action_times(3, true)
	bu.dic_combat["BUFF"] = 1
	bu.requires_update = true
	var msg = "{0}可知鱼肠之利！".format([
		DataManager.get_actor_naughty_title(bf.get_defender_id(), me.actorId)
	])
	append_free_dialog(me, msg, 0)
	return false
