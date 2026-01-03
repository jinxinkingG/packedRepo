extends "effect_30000.gd"

# 盗武效果实现
#【盗武】小战场，锁定技。本场战斗中，敌方武将武器被禁用。

const EFFECT_ID = 30162
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_30050() -> bool:
	DataManager.disable_actor_equip(30000, enemy.actorId, enemy.actor().get_weapon())
	ske.set_battle_skill_val(1, 99999)
	return false

func on_trigger_30005() -> bool:
	if ske.get_battle_skill_val_int() <= 0:
		return false
	return true

func effect_30162_AI_start()->void:
	goto_step("start")
	return

func effect_30162_start()->void:
	var msg = "{0}！看你如何威风\n（发动【{1}】".format([
		DataManager.get_actor_naughty_title(enemy.actorId, me.actorId),
		ske.skill_name
	])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirmed", false)
	return

func effect_30162_confirmed()->void:
	ske.battle_cd(99999)

	var msg = "{0}的武器被禁用".format([enemy.get_name()])
	ske.append_message(msg)
	ske.battle_report()

	SceneManager.show_simply_actor_info(enemy.actorId, msg, true)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	SceneManager.show_simply_actor_info(enemy.actorId, "", true)
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30162_end()->void:
	skill_end_clear()
	return
