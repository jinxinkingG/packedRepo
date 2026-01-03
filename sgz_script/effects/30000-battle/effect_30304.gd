extends "effect_30000.gd"

# 难守主动技和锁定效果
#【难守】小战场，主动技。守城战中，你发动「强弩」「火矢」「士气向上」消耗1点战术值，且战术持续期间：每回合战术值-1，减到0战术结束。你可发动此技能，提前结束战术。

const EFFECT_ID = 30304
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_30005() -> bool:
	for buff in ["强弩", "火矢", "士气向上"]:
		me.set_ext_variable(buff + "固定消耗", 1)
	return false

func on_trigger_30010() -> bool:
	var buffKey = "BUFF.{0}".format([actorId])
	var buffDecKey = "BUFF.DEC.{0}".format([actorId])
	var buffName = DataManager.get_env_str(buffKey)
	var buffDec = DataManager.get_env_int(buffDecKey)
	if buffDec > 0:
		return false
	if not buffName in ["强弩", "火矢", "士气向上"]:
		return false
	var buff = me.get_buff(buffName)
	if buff["回合数"] <= 0:
		return false
	# 设定回合数，且仅设定不触发技能
	me.set_buff(buffName, 999, actorId, ske.skill_name, true)
	ske.set_battle_skill_val(buffName)
	return false

func on_trigger_30009() -> bool:
	var buffName = ske.get_battle_skill_val_str()
	if not buffName in ["强弩", "火矢", "士气向上"]:
		return false
	var buff = me.get_buff(buffName)
	if buff["回合数"] <= 0:
		return false
	ske.battle_change_tactic_point(-1)
	if me.battle_tactic_point <= 0:
		# 没得减了
		ske.remove_battle_buff(actorId, buffName)
		ske.set_battle_skill_val("", 0)
	ske.battle_report()
	return false

func effect_30304_start() -> void:
	var buffName = ske.get_battle_skill_val_str()
	if not buffName in ["强弩", "火矢", "士气向上"]:
		var msg = "未启动【{0}】战术效果".format([ske.skill_name])
		SceneManager.show_confirm_dialog(msg, actorId, 2)
		LoadControl.set_view_model(2000)
		return
	var buff = me.get_buff(buffName)
	if buff["回合数"] <= 0:
		var msg = "未启动【{0}】战术效果".format([ske.skill_name])
		SceneManager.show_confirm_dialog(msg, actorId, 2)
		LoadControl.set_view_model(2000)
		return
	ske.remove_battle_buff(actorId, buffName)
	ske.set_battle_skill_val("", 0)
	ske.battle_report()

	var msg = "已取消「{0}」\n可另择战术".format([buffName])
	me.attach_free_dialog(msg, 0, 30000)
	goto_step("end")
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30304_end()->void:
	tactic_end()
	return
