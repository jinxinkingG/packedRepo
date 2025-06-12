extends "effect_20000.gd"

#庸肆主动技部分
#【庸肆】大战场，主将主动技。直到发动的回合结束之前，己方所有武将无视其等级条件获得技能。每3回合限1次。

const EFFECT_ID = 20487
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20487_start()->void:
	var wv = me.war_vstate()
	for wa in wv.get_war_actors(false, true):
		for skillName in SkillHelper.get_actor_locked_skill_names(wa.actorId).values():
			ske.add_war_skill(wa.actorId, skillName, 1)
	ske.cost_war_cd(3)
	var msg = "循规蹈矩，庸人尔\n我就是规矩！\n（【{0}】暂时解锁众将技能".format([ske.skill_name])
	ske.war_report()
	play_dialog(actorId, msg, 1, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
