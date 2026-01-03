extends "effect_20000.gd"

# 慑敌锁定技
#【慑敌】大战场，锁定技。你方为战争守方时，对方武将使用计策命中时，你对其附加1回合 {伤神} ；对方武将为白刃战攻方胜利时，你对其附加一回合 {疲兵} ；每回合限3次。以上任意效果每触发一次，你的体力-5，你体力＜15时，不再触发。

const EFFECT_ID = 20699
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const HP_COST = 5
const HP_LIMIT = 15
const MAX_TRIGGERS = 3
const BUFF_SCHEME = "伤神"
const BUFF_BATTLE = "疲兵"

func on_trigger_20012() -> bool:
	if actor.get_hp() < HP_LIMIT:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != ske.actorId:
		return false
	if se.succeeded <= 0:
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	if wa.get_buff(BUFF_SCHEME)["回合数"] > 0:
		return false
	se.skip_redo = 1
	ske.set_war_buff(ske.actorId, BUFF_SCHEME, 1)
	ske.change_actor_hp(actorId, -HP_COST)
	ske.cost_war_limited_times(MAX_TRIGGERS)
	ske.war_report()

	var msg = "{0}好计，可再施为？\n（【{1}】触发，体力 -{2}\n（{3}附加一回合 [{4}]".format([
		DataManager.get_actor_honored_title(ske.actorId, actorId),
		ske.skill_name, HP_COST, wa.get_name(), BUFF_SCHEME,
	])
	me.attach_free_dialog(msg, 2)
	return false

func on_trigger_20020() -> bool:
	if actor.get_hp() < HP_LIMIT:
		return false
	var bf = DataManager.get_current_battle_fight()
	if bf.get_attacker_id() != ske.actorId:
		return false
	var loser = bf.get_loser()
	if loser == null or loser.actorId == ske.actorId:
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	if wa.get_buff(BUFF_BATTLE)["回合数"] > 0:
		return false
	ske.set_war_buff(ske.actorId, BUFF_BATTLE, 1)
	ske.change_actor_hp(actorId, -HP_COST)
	ske.cost_war_limited_times(MAX_TRIGGERS)
	ske.war_report()

	var msg = "{0}骁勇，尚能战否？\n（【{1}】触发，体力 -{2}\n（{3}附加一回合 [{4}]".format([
		DataManager.get_actor_honored_title(ske.actorId, actorId),
		ske.skill_name, HP_COST, wa.get_name(), BUFF_BATTLE,
	])
	me.attach_free_dialog(msg, 2)
	return false
