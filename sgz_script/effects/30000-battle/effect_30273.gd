extends "effect_30000.gd"

#火神主动技 #神策
#【火神】小战场，主动技。非水地形可使用，消耗8点体力，对随机2-4名敌兵各造成X点火神伤害。X＝你的德×0.6，白刃战限1次。

const HP_COST = 8

func get_hp_cost() -> int:
	var ret = HP_COST
	if actor.get_equip_feature_max("神策体力消耗减半") > 0:
		ret = int(ret / 2)
	return ret


func effect_30273_start()->void:
	var hpCost = get_hp_cost()
	var unit = me.battle_actor_unit()
	if unit == null:
		tactic_end()
		return
	if unit.get_hp() <= hpCost:
		var msg = "体力不足，需 > {0}".format([hpCost])
		me.attach_free_dialog(msg, 3, 30000)
		tactic_end()
		return

	ske.battle_change_unit_hp(unit, -hpCost)
	unit.add_status_effect("-{0}#FF0000".format([hpCost]))
	ske.battle_cd(99999)
	var bf = DataManager.get_current_battle_fight()
	var candidates = []
	for bu in bf.battle_units(enemy.actorId):
		if bu.get_unit_type() in ["城门", "将"]:
			continue
		candidates.append(bu)
	if candidates.empty():
		me.attach_free_dialog("朱陵真焱！", 0, 30000)
		me.attach_free_dialog("…… ？！", 0, 30000)
		ske.battle_report()
		tactic_end()
		return

	candidates.shuffle()
	var limit = Global.get_random(2, 4)
	if candidates.size() > limit:
		candidates.resize(limit)
	var x = int(ceil(actor.get_moral() * 0.6))
	ske.battle_report()
	tactic_end()

	var scene = SceneManager.current_scene()
	scene.play_fire(actorId, candidates, x)

	me.attach_free_dialog("朱陵真焱！", 0, 30000)
	return
