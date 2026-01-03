extends "effect_30000.gd"

#藤甲小战场效果实现 #布阵 #减伤
#【藤甲】大战场&小战场,锁定技。你乘坐大象，默认8步2弓，且步兵站骑兵位，布阵后可以选择是否武将前置。非水战，你的步兵和弓兵只承受50%的伤害；大战场，处于非水地形时，火属性计策会对你造成125%的伤害

func on_trigger_30003()->bool:
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "常规", {
			"兵种数量": {"弓":2,"步":8},
			"分配顺序": ["弓", "步"],
		}
	)
	return false

func on_trigger_30005()->bool:
	var bu = get_leader_unit(me.actorId)
	if bu == null or bu.disabled:
		return false
	bu.reset_combat_info("将(象)")
	bu.dic_combat["武器特性"] = []
	bu.requires_update = true
	return not bu.dic_combat.has("布阵前突")

func on_trigger_30024()->bool:
	var unitId = get_env_int("白兵.初始化单位ID")
	var bu = get_battle_unit(unitId)
	if bu == null or bu.Type != "步":
		return false
	bu.reset_combat_info("步(藤甲)")
	return false

func on_trigger_30011()->bool:
	ske.battle_reduce_damage_rate(0.5, ["弓", "步"], ["ALL"], ["ALL"])
	return false

func effect_30024_AI_start():
	goto_step("2")
	return

func effect_30024_start():
	var bu = get_leader_unit(me.actorId)
	if bu == null or bu.dic_combat.has("布阵前突"):
		LoadControl.end_script()
		return
	SceneManager.show_yn_dialog("武将是否列阵在前？", me.actorId, 2)
	var lastOption = get_env_int("藤甲选项")
	if lastOption == 0 or lastOption == 1:
		SceneManager.actor_dialog.lsc.cursor_index = lastOption
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	match wait_for_skill_option():
		0:
			goto_step("2")
		1:
			goto_step("no")
	return

func effect_30024_2():
	var bu = get_leader_unit(me.actorId)
	if bu != null:
		ske.battle_unit_jump_forward(5, bu)
		ske.battle_report()
	skill_end_clear()
	return

func effect_30024_no():
	var bu = get_leader_unit(me.actorId)
	if bu != null:
		bu.dic_combat["布阵前突"] = 0
	skill_end_clear()
	return
