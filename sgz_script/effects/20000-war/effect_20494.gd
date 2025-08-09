extends "effect_20000.gd"

#守射锁定技
#【守射】大战场，主将锁定技。你为战争守方，敌将白刃战结束的场合，若那名敌将是“回合内第一个发起攻击的将领”，你对之发射乱矢，造成体力和兵力伤害（等同于“落石”的伤害效果）。

const EFFECT_ID = 20494
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const STRATAGEM = "落石"

func on_trigger_20020()->bool:
	if ske.get_war_skill_val_int() > 0:
		return false
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_attacker_id():
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if not me.is_enemy(wa):
		return false
	ske.set_war_skill_val(1, 1)
	return true

func effect_20494_AI_start()->void:
	goto_step("start")
	return
	
func effect_20494_start()->void:
	var se = DataManager.new_stratagem_execution(actorId, STRATAGEM)
	se.work_as_skill = 1
	se.set_target(ske.actorId)
	se.set_must_success(actorId, ske.skill_name)

	ske.cost_war_cd(1)
	ske.war_report()
	se.perform_to_targets([ske.actorId], true)

	var msg = "{0}无谋，操切莽进\n弩石伺候！".format([
		ActorHelper.actor(se.targetId).get_name()
	])

	ske.play_se_animation(se, 2002, msg, 0)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20494_report():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return
