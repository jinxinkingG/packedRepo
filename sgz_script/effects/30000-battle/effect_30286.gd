extends "effect_30000.gd"

# 明刀效果
#【明刀】小战场，锁定技。小战场，锁定技。战斗开始时，若你的武器非S级，临时装备<日月双刀>，无法被抢夺。

const EQUIP_ID = StaticManager.WEAPON_ID_RIYUESHUANGDAO

func on_trigger_30005() -> bool:
	var weapon = actor.get_weapon()
	if weapon.level() == "S":
		return false

	actor.set_battle_equip(weapon.type, EQUIP_ID)
	weapon = actor.get_weapon()
	var msg = "{0}在手\n{1}受死！".format([
		weapon.name(),
		DataManager.get_actor_naughty_title(enemy.actorId, actorId)
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false
