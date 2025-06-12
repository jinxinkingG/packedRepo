extends "effect_20000.gd"

#后勤效果
#【后勤】大战场,锁定技。每回合初始，你方所有武将体力+3，最高恢复到其体力上限。你花色为红桃时，恢复效果加倍。

# TODO，潜在问题，战争第一天，未初始化的武将不能享受
func on_trigger_20013():
	var recover = 3
	if me.five_phases == War_Character.FivePhases_Enum.Wood:
		recover = 6
	var targets = get_teammate_targets(me, 9999)
	targets.append(me.actorId)
	for targetId in targets:
		ske.change_actor_hp(targetId, recover)
	ske.war_report()
	return false
