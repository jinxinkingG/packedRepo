extends "effect_20000.gd"

#亲士大战场效果
#【亲士】大战场&小战场，主动技。①你的[士]不低于300时可发动：你的前、左、右，分别出现一队兵力100的骑兵、步兵、弓兵。每出现1队士兵：你的[士]-100，士气+2。白刃战限1次。②战争初始，你[士]+300，上限3000。

const FLAG_ID = 10068
const FLAG_NAME = "士"
const FLAG_LIMIT = 3000
const FLAGS_RECHAGE = 300

func on_trigger_20013()->bool:
	if ske.get_war_skill_val_int() > 0:
		return false
	ske.set_war_skill_val(1, 99999)
	ske.add_skill_flags(10000, FLAG_ID, FLAG_NAME, FLAGS_RECHAGE, FLAG_LIMIT)
	ske.war_report()
	return false
