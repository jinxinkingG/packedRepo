extends "effect_30000.gd"

#逆骑主动技
#【逆骑】小战场，主动技。你为城地形的防守方可使用：消耗20金，使你方所有士兵变为骑兵，每个大战场回合限1次。使用本技能后，若本次白刃战你获胜，重置本技能冷却，你的兵力恢复100。

const EFFECT_ID = 30253
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 30254
const GOLD_COST = 20

# AI 暂不发动

func effect_30253_start():
	var wv = me.war_vstate()
	if wv == null or wv.money < GOLD_COST:
		var msg = "金不足，需 >= {0}".format([GOLD_COST])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2000)
		return
	ske.battle_cd(99999)
	ske.cost_war_cd(1)
	ske.cost_wv_gold(GOLD_COST)
	var affected = []
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if not bu.get_unit_type() in ["步", "弓"]:
			continue
		affected.append(bu)
	var changed = ske.battle_change_units_type(actorId, affected, "骑")
	var recorded = ske.battle_get_skill_val_int_array(PASSIVE_EFFECT_ID)
	recorded[1] = 1
	ske.battle_set_skill_val(recorded, 99999, PASSIVE_EFFECT_ID)
	ske.battle_report()
	var msg = "全体冲锋，逆击{0}！\n（{1}单位变为骑兵".format([
		me.get_battle_enemy_war_actor().get_name(), changed
	])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return false

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30253_end():
	tactic_end()
	return
