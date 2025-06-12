extends "effect_30000.gd"

#引伏小战场效果 #战术值
#【引伏】大战场,诱发技。你被发起攻击宣言的场合，你可以消耗5点机动力，发动：指定一个你方武将，替你进入白兵战斗，且该武将的战术值额外+（你的智*0.13），该武将本次白兵胜利时，你的经验额外+500

const EFFECT_ID = 30127
const YINFU_EFFECT_ID = 20149

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_attacker_id():
		return false
	var marked = ske.get_war_skill_val_dic(YINFU_EFFECT_ID)
	if not marked.has("ing"):
		return false
	var tp = int(ActorHelper.actor(ske.skill_actorId).get_wisdom() * 0.13)
	ske.battle_change_tactic_point(tp, bf.get_attacker())
	return false
