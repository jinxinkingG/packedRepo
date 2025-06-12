extends "effect_30000.gd"

#懈志锁定技
#【懈志】大战场，锁定技。若你方的总兵力比敌方总兵力的一半还要少，你进入白刃战时，立刻投降（若为君主，则死亡/入狱）。

const EFFECT_ID = 30213
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_30005() -> bool:
	var wv = me.war_vstate()
	var enemyWV = wv.get_enemy_vstate()
	if wv.get_all_soldiers() * 2 >= enemyWV.get_all_soldiers():
		return false

	var msg = "敌势汹汹，何以为战\n不如投了吧。。。"
	var d = me.attach_free_dialog(msg, 3, 30000)
	d.callback_script = "effects/30000-battle/effect_30213.gd"
	d.callback_method = "surrender"
	return false

func surrender()->void:
	actor = ActorHelper.actor(actorId)
	var me = DataManager.get_war_actor(actorId)
	var wv = me.war_vstate()
	var enemyWV = wv.get_enemy_vstate()
	var bu = me.battle_actor_unit()
	bu.disabled = true
	bu.is_surrend = true
	if actor.get_loyalty() == 100:
		me.actor_capture_to(enemyWV.id, "投降")
		actor.set_status_captured()
	else:
		me.actor_surrend_to(enemyWV.id)
	return
