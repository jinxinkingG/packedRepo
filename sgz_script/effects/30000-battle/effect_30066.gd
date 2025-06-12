extends "effect_30000.gd"

#烈魂技能实现
#【烈魂】小战场，主动技。你的体力＞10时，才可以使用。使用后你的体力-10，你方士气+x，x＝（120-你的体力）/6，且最大为16，每个大战场回合1次。

const EFFECT_ID = 30066
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_HP = 10
const FACTOR = 6
const X_LIMIT = 16
const HP_LIMIT = 120

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2", false)
	return

func check_AI_perform()->bool:
	if actor.get_soldiers() < 200:
		return false
	var unit = me.battle_actor_unit()
	if unit == null or unit.disabled:
		return false
	if unit.get_hp() < HP_LIMIT and unit.get_hp() > 70:
		return true
	return false

func effect_30066_AI_start():
	goto_step("start")
	return

func effect_30066_start():
	var bf = DataManager.get_current_battle_fight()
	var unit = me.battle_actor_unit()
	var hp = unit.get_hp()
	if unit == null or hp <= COST_HP or hp >= HP_LIMIT - COST_HP:
		var msg = "体力不足，需 > {0}".format([COST_HP])
		SceneManager.show_confirm_dialog(msg, me.actorId, 3)
		LoadControl.set_view_model(2000)
		return
	ske.cost_war_cd(1)
	ske.battle_cd(99999)
	ske.battle_change_unit_hp(unit, -COST_HP)
	var x:int = ceil((HP_LIMIT - unit.get_hp()) / FACTOR)
	x = min(X_LIMIT, x)
	ske.battle_change_morale(x)
	ske.battle_report()
	var msg = "疾痛死生，与吾若无\n壮士之勇，得其所哉！\n（体力降为{1}，士气+{2}".format([
		me.get_name(), unit.get_hp(), x
	])
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	LoadControl.set_view_model(2000)
	return

func effect_30066_2():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
