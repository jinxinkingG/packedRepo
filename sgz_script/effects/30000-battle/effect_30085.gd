extends "effect_30000.gd"

#扬昂效果
#【扬昂】小战场,锁定技。你白兵胜利后，下次白兵战，战术值+5（每回合发动一次）。

const EFFECT_ID = 30085

func check_trigger_correct():
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	match ske.trigger_Id:
		30005:
			if ske.get_war_skill_val_int() <= 0:
				return false
			ske.cost_war_cd(1)
			ske.battle_change_tactic_point(5)
			ske.battle_report()
		30099:
			if bf.loserId == me.actorId:
				return false
			ske.set_war_skill_val(1, 1)
	return false
