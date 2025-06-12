extends "effect_20000.gd"

#当先诱发技
#【当先】大战场，诱发技。你方回合开始阶段才能发动。你可不消耗机动力移动1-2格，若移动后，存在与你相邻的敌将，则你必须与之进入白刃战；若此白刃战最终战败，你主要阶段不能进行攻击和用计。

const PASSIVE_EFFECT_ID = 20520

func on_trigger_20028() -> bool:
	ske.cost_war_cd(1)
	return true

func effect_20519_start() -> void:
	ske.set_war_skill_val([2, 0], 1, PASSIVE_EFFECT_ID)
	SkillHelper.remove_current_skill_trigger()
	LoadControl.end_script()
	map.set_cursor_location(me.position, true)
	DataManager.player_choose_actor = actorId
	FlowManager.add_flow("load_script|war/player_move.gd")
	FlowManager.add_flow("actor_move_start")
	return
