extends "effect_30000.gd"

#秘丸效果实现，主动技部分
#【秘丸】小战场，主动技。每日限一次。你吃下黄巾军秘药大力丸：若体力>50，你在小战场的武力立即+x。大战场次回合，效果消失，体力-x，最低为1。其中x＝武/5。

const EFFECT_ID = 30087
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const HP_LIMIT = 50

# 小战场主动技部分
func effect_30087_start() -> void:
	if ske.get_war_skill_val_int() > 0:
		ske.battle_cd(99999)
		# 小战场 CD
		SceneManager.show_confirm_dialog("秘丸虽好，过量为鸩…", me.actorId, 3)
		LoadControl.set_view_model(2000)
		return

	ske.cost_war_cd(1)
	ske.battle_cd(99999)

	if actor.get_hp() <= HP_LIMIT:
		SceneManager.show_confirm_dialog("体力难支…\n（需50体力", me.actorId, 3)
		LoadControl.set_view_model(2000)
		return

	var power = actor.get_power()
	var x = int(power / 5)
	if x <= 0:
		goto_step("end")
		return

	ske.battle_change_power(x)

	# 同时记录下技能变量，以便下次进入小战场仍然生效
	# 技能变量生效周期两个大战场回合，因为次回合要产生副作用
	ske.set_war_skill_val(x, 2)
	ske.battle_report()

	var msg = "这……就是力量吗！\n（吞下秘丸，武力 +{0}".format([x])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30087_end():
	tactic_end()
	return
