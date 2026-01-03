extends "effect_20000.gd"

# 后援锁定技
#【后援】大战场，锁定技。你方回合结束时，你进行调配辎重，令你方已损体武将之中，体力最低的武将回复10点体力。你的五行为木、土时，该武将体力回复量额外+5点。

const HP_RECOVER = 10
const HP_RECOVER_EXTRA = 5

func on_trigger_20016()->bool:
	var teammates = me.get_teammates(false, true)
	teammates.append(me)
	var minHp = 9999
	var minHpTeammate = null
	for teammate in teammates:
		if not teammate.actor().is_injured():
			continue
		if teammate.actor().get_hp() < minHp:
			minHp = teammate.actor().get_hp()
			minHpTeammate = teammate
	if minHpTeammate == null:
		return false
	var recover = HP_RECOVER
	if me.five_phases in [War_Character.FivePhases_Enum.Wood, War_Character.FivePhases_Enum.Earth]:
		recover += HP_RECOVER_EXTRA
	recover = ske.change_actor_hp(minHpTeammate.actorId, recover)
	ske.war_report()

	if recover > 0:
		var msg = "{0}可稍歇，明日再战\n（【{1}】效果\n（{2}体力回复 {3} -> {4}".format([
			DataManager.get_actor_honored_title(minHpTeammate.actorId, actorId),
			ske.skill_name,
			minHpTeammate.get_name(), recover,
			minHpTeammate.actor().get_hp(),
		])
		me.attach_free_dialog(msg, 1)
	return false
