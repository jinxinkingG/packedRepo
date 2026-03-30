extends "effect_30000.gd"

# 狼骑规则技
#【狼骑】小战场，规则技。你默认6骑，第3～6回合内，你的骑兵行动次数+1。你的骑兵首次击杀对方士兵单位时，你可以选择，直接与对方进入单挑。

const EFFECT_ID = 30315
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_30003() -> bool:

	var data = {
		"兵种数量": {"骑": 6},
		"分配顺序": ["骑"],
	}
	# 固定阵型 10/11
	var formation = 11110
	if actorId == bf.get_attacker_id():
		data["攻方阵型"] = formation
	else:
		data["守方阵型"] = formation

	bf.update_extra_formation_setting(actorId, ske.skill_name, "特殊", data)

	return false

func on_trigger_30009() -> bool:
	var turn = bf.turns()
	if turn < 3 or turn > 6:
		return false
	for bu in bf.battle_units(actorId):
		if bu.get_unit_type() != "骑":
			continue
		bu.wait_action_times = min(3, bu.get_action_times() + 1)
	return false

func on_trigger_30023() -> bool:
	if ske.get_battle_skill_val_int() > 0:
		# 已经触发过
		return false

	var bu = ske.battle_is_unit_hit_by(["骑"], UNIT_TYPE_SOLDIERS, ["ALL"])
	if bu == null:
		return false

	var hurtId = DataManager.get_env_int("白兵.受伤单位")
	var hurtUnit = ske.get_battle_unit(hurtId)
	if hurtUnit == null or not hurtUnit.disabled:
		return false

	if enemy == null:
		return false
	var enemyBU = enemy.battle_actor_unit()
	if enemyBU == null:
		return false
	ske.battle_set_skill_val(1)
	return false

func on_trigger_30001() -> bool:
	if ske.get_battle_skill_val_int() != 1:
		return false
	ske.set_battle_skill_val(2)
	return true

func effect_30315_AI_start() -> void:
	goto_step("confirmed")
	return

func effect_30315_start() -> void:
	var enemy = me.get_battle_enemy_war_actor()
	var msg = "【{0}】触发\n是否与{1}进入单挑？".format([
		ske.skill_name, enemy.get_name(),
	])
	SceneManager.show_yn_dialog(msg, actorId, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_30315_confirmed() -> void:
	var msg = "狼骑之威，{0}知否？\n勿令士卒徒死\n与{1}堂堂一战！".format([
		DataManager.get_actor_naughty_title(enemy.actorId, actorId),
		actor.get_short_name(),
	])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_go", false)
	return

func effect_30315_go() -> void:
	SceneManager.hide_all_tool()
	# 强制进入单挑
	var st = SkillHelper.get_current_skill_trigger()
	st.next_flow = "go_to_solo"
	LoadControl.end_script()
	return
