extends "effect_30000.gd"

#愈勇效果实现
#【愈勇】小战场,锁定技。双方第一次持续型战术时，你的武临时+5，统临时+5。

const ENPOWER = 5

func on_trigger_30010()->bool:
	var msg = "一鼓作气！杀！"
	return _on_buff_fired(msg, me.actorId)

func on_trigger_30020()->bool:
	var msg = "来得好！我还没过瘾！"
	return _on_buff_fired(msg, enemy.actorId)

func _on_buff_fired(msg:String, fromId:int)->bool:
	var key1 = "BUFF.{0}".format([fromId])
	var key2 = "BUFF.DEC.{0}".format([fromId])
	if get_env_int(key2) > 0:
		return false
	var buff = get_env_str(key1)
	if not buff in StaticManager.CONTINUOUS_TACTICS:
		return false
	# 任意一方发动战术并获得持续性效果
	ske.battle_cd(99999)
	var power = me.get_battle_power()
	var lead = me.battle_lead

	var baseMorale = me.calculate_battle_morale(me.get_battle_power(), me.battle_lead, 0)
	ske.battle_change_power(ENPOWER)
	ske.battle_change_leadership(ENPOWER)
	var enhancedMorale = me.calculate_battle_morale(me.get_battle_power(), me.battle_lead, 0)
	msg = msg + "\n（{0}发动【{1}】\n（武统增加{2}"
	var x = enhancedMorale - baseMorale
	if x > 0:
		ske.battle_change_morale(x)
		msg = msg + "，士气增加{3}"
	msg = msg.format([me.get_name(), ske.skill_name, ENPOWER, x])
	ske.battle_report()
	append_free_dialog(me, msg, 0)
	return false
