extends "effect_30000.gd"

#激石主动技
#【激石】小战场，主动技。非攻城、非水地形可以使用，消耗8点体力，从对方半场两侧随机位置各滚出3颗巨石，对巨石碰到的士兵单位造成X点激石伤害，对巨石碰到的武将单位造成X/5点激石伤害。X＝你的武×0.8，白刃战限1次。

const EFFECT_ID = 30275
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const HP_COST = 8

func effect_30275_start()->void:
	var unit = me.battle_actor_unit()
	if unit == null:
		tactic_end()
		return
	if unit.get_hp() <= HP_COST:
		var msg = "体力不足，需 > {0}".format([HP_COST])
		me.attach_free_dialog(msg, 3, 30000)
		tactic_end()
		return

	var offsets = range(0, 8)
	if unit.get_side() == Vector2.LEFT:
		offsets = range(15, 7, -1)
	offsets.shuffle()
	offsets.resize(3)
	var positions = []
	for off in offsets:
		positions.append(Vector2(off, 0))
		positions.append(Vector2(off, 9))
	DataManager.set_env("战斗.激石.位置", offsets)
	var x = int(ceil(me.get_battle_power() * 0.8))
	DataManager.set_env("战斗.激石.伤害", x)
	var scene = SceneManager.current_scene()
	scene.battle_tactic.hide()
	scene.mark_selectable_positions(positions)

	ske.battle_change_unit_hp(unit, -HP_COST)
	unit.add_status_effect("-{0}#FF0000".format([HP_COST]))
	ske.battle_cd(99999)
	ske.battle_report()

	SceneManager.show_confirm_dialog("乱石惊尘！", actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_30275_2() -> void:
	var unit = me.battle_actor_unit()
	var scene = SceneManager.current_scene()
	tactic_end()
	scene.mark_selectable_positions([])
	scene.play_rock(unit)
	return
