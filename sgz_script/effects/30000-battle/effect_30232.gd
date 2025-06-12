extends "effect_30000.gd"

#势众效果
#【势众】大战场，主将锁定技。非守城时，你方武将布阵后，你方金-40，令该己方武将兵力增加300，白刃战结束后，超过上限的士兵，遣散之。同时本次白刃战：前5轮，你方武将无法撤退；第一轮，你方士兵不受指挥乱动。每个己方武将每回合限触发1次。

const COST_GOLD = 40
const ADD_SOLDIERS = 300

func on_trigger_30003()->bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.get_terrian_cn() in StaticManager.CITY_BLOCKS_CN and ske.actorId == bf.get_defender_id():
		return false
	if me.war_vstate().money < COST_GOLD:
		return false
	var triggered = ske.get_war_skill_val_int_array()
	if ske.actorId in triggered:
		return false
	var targetWA = DataManager.get_war_actor(ske.actorId)
	triggered.append(targetWA.actorId)
	ske.set_war_skill_val(triggered, 1)
	ske.cost_wv_gold(COST_GOLD)
	var limit = DataManager.get_actor_max_soldiers(targetWA.actorId)
	var soldiers = targetWA.actor().get_soldiers()
	ske.change_actor_soldiers(targetWA.actorId, ADD_SOLDIERS)
	ske.set_battle_buff(targetWA.actorId, "武将死战", 5)
	ske.set_battle_buff(targetWA.actorId, "混乱", 1)
	ske.set_battle_skill_val(1)
	ske.battle_report()
	ske.war_report()
	var msg = "我军势众，乱战亦足取胜！"
	targetWA.attach_free_dialog(msg, 0, 30000, actorId)
	return false

func on_trigger_30004()->bool:
	if ske.get_battle_skill_val_int() <= 0:
		return false
	var targetWA = DataManager.get_war_actor(ske.actorId)
	var limit = DataManager.get_actor_max_soldiers(targetWA.actorId)
	var soldiers = targetWA.actor().get_soldiers()
	if soldiers > limit:
		ske.change_actor_soldiers(targetWA.actorId, limit - soldiers)
	ske.battle_report()
	ske.war_report()
	return false

func on_trigger_30009()->bool:
	if ske.get_battle_skill_val_int() != 1:
		return false
	var targetWA = DataManager.get_war_actor(ske.actorId)
	if targetWA.get_buff("混乱")["回合数"] > 0:
		return false
	ske.set_battle_skill_val(2)
	targetWA.attach_free_dialog("乱阵者斩！整队出击！", 0, 30000)
	var states = bf.get_units_states(targetWA.actorId)
	for k in states:
		if k == "将":
			continue
		states[k] = "前进"
	bf.set_unit_state(targetWA.actorId, states)
	return false
