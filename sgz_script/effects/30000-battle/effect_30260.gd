extends "effect_30000.gd"

#胆撑锁定效果
#【胆撑】小战场，锁定技。若你上次白刃战获胜，本次战术值+X；否则，本次战术值-X。X＝你上次白刃战剩余的战术值。

func on_trigger_30005() -> bool:
	var x = ske.get_war_skill_val_int()
	if x == 0:
		return false
	x = ske.battle_change_tactic_point(x)
	if x == 0:
		return false
	var mood = 0
	var msg = "我部方胜，谁能当之？\n（【{0}】战术值 +{1}"
	if x < 0:
		msg = "我部新败，计将安出 …\n（【{0}】战术值 -{1}"
		mood = 3
	msg = msg.format([ske.skill_name, abs(x)])
	me.attach_free_dialog(msg, mood, 30000)
	return false

func on_trigger_30099() -> bool:
	ske.set_war_skill_val(0)
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null:
		return false
	var x = me.battle_tactic_point
	if loser.actorId == actorId:
		x = -x
	ske.set_war_skill_val(x)
	return false
