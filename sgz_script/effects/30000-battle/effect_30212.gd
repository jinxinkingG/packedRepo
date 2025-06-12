extends "effect_30000.gd"

#骁果主动技部分
#【骁果】小战场，主动技。使用后的3回合内，若你的士兵单位被攻击过，下回合行动次数+1。（持续性战术)

const EFFECT_ID = 30212
const BUFF_TURNS = 3

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("tactic_end", false)
	return

# 小战场主动技部分
func effect_30212_start():
	me.set_buff("骁果", BUFF_TURNS, me.actorId)
	ske.battle_cd(99999)
	SceneManager.show_confirm_dialog("果毅无匹，骁卫无敌！", me.actorId, 0)
	LoadControl.set_view_model(2000)
	return false
