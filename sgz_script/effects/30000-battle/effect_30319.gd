extends "effect_30000.gd"

#挟喝主动技 #兵种转换 #范围效果
#【挟喝】小战场，主动技。可消耗X点机动力发动：①以你为中心，5x5范围内的敌兵，有Y%的概率变为步兵。X=本日内发动此技能的次数，Y＝你的等级×8。②若你为孙策，你的胆临时+12。

const EFFECT_ID = 30319
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# 孙策胆加成
const COURAGE_BONUS = 12

# AI 是否可发动
func check_AI_perform() -> bool:
	if me.action_point < get_cost_ap():
		return false
	var bu = me.battle_actor_unit()
	if _get_enemy_units_in_range(bu, 2).size() <= 2:
		return false
	return true

func effect_30319_AI_start() -> void:
	goto_step("confirmed")
	return

func effect_30319_start() -> void:
	var cost = get_cost_ap()
	if me.action_point < cost:
		var msg = "机动力不足（需 >= {0}）\n无法发动【{1}】".format([
			cost, ske.skill_name
		])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2009)
		return
	var msg = "消耗{0}机动力发动【{1}】\n可否？".format([
		cost, ske.skill_name
	])
	SceneManager.show_yn_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_confirmed", "tactic_end")
	return

func effect_30319_confirmed()->void:
	var x = get_x()
	ske.battle_cd(99999)
	ske.cost_ap(x)
	ske.set_war_skill_val(x, 1)

	var unit = me.battle_actor_unit()
	if unit == null:
		tactic_end()
		return

	# 以自己为中心，5x5 范围内的敌兵
	var changed = _chance_to_trans_enemy_unit_in_range(unit)

	var msg = ""
	if changed > 0:
		msg = "{0}部心胆俱裂\n{1}单位变为步兵".format([
			enemy.get_name(), changed,
		])
	else:
		msg = "敌兵不为所动"
	# 孙策特殊效果：胆临时+12
	if actorId == StaticManager.ACTOR_ID_SUNCE:
		ske.battle_change_courage(COURAGE_BONUS, me)
		msg += "\n胆 +{0}".format([COURAGE_BONUS])

	ske.battle_report()
	SceneManager.show_confirm_dialog(msg, actorId, 1)
	LoadControl.set_view_model(2009)
	return

func on_view_model_2009() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

func effect_30319_end() -> void:
	tactic_end()
	return

func _get_enemy_units_in_range(centerUnit:Battle_Unit, rng:int) -> Array:
	var ret = []
	var center = centerUnit.unit_position
	for unit in bf.battle_units(enemy.actorId):
		if not unit.is_soldier():
			continue
		var distance = Global.get_range_distance(unit.unit_position, center)
		if distance > 2:
			continue
		ret.append(unit)
	return ret

func _chance_to_trans_enemy_unit_in_range(centerUnit:Battle_Unit, dryRun:bool=false)->int:
	var center = centerUnit.unit_position
	var level = actor.get_level()
	var affected = []
	for unit in _get_enemy_units_in_range(centerUnit, 2):
		# Y% 概率变为步兵
		if Global.get_rate_result(level * 8):
			affected.append(unit)
	var changed = ske.battle_change_units_type(enemy.actorId, affected, "步")
	ske.battle_report()
	return changed

func get_x()->int:
	return ske.get_war_skill_val_int() + 1

func get_cost_ap()->int:
	return get_x()
