extends "effect_30000.gd"

#落雷主动技
#【落雷】小战场,主动技。非城地形可使用，消耗8点体力，随机对一名敌兵造成X点落雷伤害，该落雷伤害有75%概率进行传导，每次传导，伤害-25%，最多传导3次（共4个单位被落雷攻击）。其中X＝你的知，白刃战限1次。

const HP_COST = 8

func effect_30271_start()->void:
	var unit = me.battle_actor_unit()
	if unit == null:
		tactic_end()
		return
	if unit.get_hp() <= HP_COST:
		var msg = "体力不足，需 > {0}".format([HP_COST])
		me.attach_free_dialog(msg, 3, 30000)
		tactic_end()
		return

	ske.battle_change_unit_hp(unit, -HP_COST)
	unit.add_status_effect("-{0}#FF0000".format([HP_COST]))
	ske.battle_cd(99999)
	var bf = DataManager.get_current_battle_fight()
	var candidates = []
	for bu in bf.battle_units(enemy.actorId):
		if bu.get_unit_type() in ["城门", "将"]:
			continue
		candidates.append(bu)
	if candidates.empty():
		me.attach_free_dialog("紫霄无极！", 0, 30000)
		me.attach_free_dialog("…… ？！", 0, 30000)
		ske.battle_report()
		tactic_end()
		return

	candidates.shuffle()
	if candidates.size() > 4:
		candidates.resize(4)
	var x = actor.get_wisdom()
	ske.battle_report()
	tactic_end()
	var scene = SceneManager.current_scene()
	scene.play_thunder(actorId, candidates, x)

	me.attach_free_dialog("紫霄无极！", 0, 30000)
	return
