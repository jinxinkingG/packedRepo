extends "effect_30000.gd"

#蛮王效果
#【蛮王】大战场,主将锁定技。你方武将进入白兵时，统临时+x，武临时+x，其中x＝我方拥有<蛮裔>技能的武将数。

const EFFECT_ID = 30098

func on_trigger_30006():
	# 战斗武将
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false

	var x = 1
	for teammate in me.get_teammates(false):
		if SkillHelper.actor_has_skills(teammate.actorId, ["蛮裔"]):
			x += 1
	var sbp = ske.get_battle_skill_property()
	sbp.leader += x
	sbp.power += x
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()

	var msg = "吾力神授，谁敢欺我蛮裔！\n（【{0}】统、武增加{1}".format([
		ske.skill_name, x,
	])
	wa.attach_free_dialog(msg, 0, 30000, actorId)

	return false
