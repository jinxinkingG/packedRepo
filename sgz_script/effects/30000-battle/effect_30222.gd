extends "effect_30000.gd"

#枪阵效果实现
#【枪阵】小战场，主动技。发动后，你获得持续型战术“枪阵”3回合：你的步兵和骑兵近战距离变为1-2，并拥有穿刺效果。白刃战限1次。

const EFFECT_ID = 30222
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const TURNS = 3

func effect_30222_start():
	ske.battle_cd(99999)
	ske.set_battle_buff(actorId, "枪阵", TURNS)
	ske.battle_report()
	# 立即更新令 BUFF 生效
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if not bu.get_unit_type() in ["步", "骑"]:
			continue
		bu.check_buff()
	SceneManager.show_confirm_dialog("兵如火，枪如林！", actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30222_end()->void:
	skill_end_clear(true)
	LoadControl.load_script("battle/player_tactic.gd")
	FlowManager.add_flow("tactic_end")
	return
