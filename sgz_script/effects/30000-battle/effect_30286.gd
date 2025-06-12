extends "effect_30000.gd"

# 明刀主动技
#【明刀】小战场，主动技。你的武器非S级才能使用：本次白刃战，你的武器临时变为“日月双刀”，每个大战场回合限1次。该临时日月双刀无法被抢夺。

const EFFECT_ID = 30286
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const EQUIP_ID = StaticManager.WEAPON_ID_RIYUESHUANGDAO

func effect_30286_start()->void:
	var weapon = actor.get_weapon()
	if weapon.level() == "S":
		var msg = "{0}在手，犹不知足？".format([
			weapon.name()
		])
		me.attach_free_dialog(msg, 2, 30000)
		tactic_end()
		return

	actor.set_battle_equip(weapon.type, EQUIP_ID)
	weapon = actor.get_weapon()
	ske.battle_cd(99999)
	ske.cost_war_cd(1)
	var msg = "{0}在手，{1}受死！".format([
		weapon.name(),
		DataManager.get_actor_naughty_title(enemy.actorId, actorId)
	])
	me.attach_free_dialog(msg, 0, 30000)
	tactic_end()
	return
