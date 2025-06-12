extends "effect_30000.gd"

#胆裂效果实现
#【胆裂】小战场，锁定技。敌将使用「挑衅」，而你拒绝的场合。你的士气不因此降低，改为降低你的胆数值；若同一次战斗中你拒绝2次及以上，你的体力也降低那个的数值。

func on_trigger_30012():
	if me == null or enemy == null:
		return false
	var moraleChange = DataManager.get_env_int("白兵.士气变化", -4)
	ske.battle_change_morale(-moraleChange, me)
	ske.battle_change_courage(moraleChange, me)
	var val = abs(moraleChange)
	var triggered = ske.get_battle_skill_val_int(ske.effect_Id, 0)
	var hp = 0
	if triggered > 0 and val > 0:
		var bu = me.battle_actor_unit()
		hp = ske.battle_change_unit_hp(bu, -val)
	ske.set_battle_skill_val(triggered + 1, 99999)
	ske.battle_report()

	var msg = "不……不可徒逞匹夫之勇\n（【{0}】士气不变"
	if val > 0:
		msg += "，胆 -{1}"
	msg = msg.format([
		ske.skill_name, val,
	])
	if hp < 0:
		msg += "\n（多次拒战，体力 -{0}".format([abs(hp)])
	DataManager.set_env("对话", msg)
	DataManager.set_env("对话表情", 3)
	DataManager.set_env("对话武将", actorId)
	return false
