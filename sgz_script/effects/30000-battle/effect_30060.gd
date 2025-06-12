extends "effect_30000.gd"

#传教主动技部分
#【传教】小战场,主动技。非城地形：每回合结束前，对方每个士兵单位的兵力-x，你方所有士兵单位，平分对方减少的总兵力，每个单位最高300兵力。x＝你的等级/2，向下取整，持续3回合，显示特殊图标。

const BUFF_NAME = "传教"
const BUFF_TURNS = 3

func on_view_model_2000():
	wait_for_skill_result_confirmation("tactic_end", false)
	return

func on_view_model_3000():
	wait_for_skill_result_confirmation("unit_action")
	return

# AI 是否可发动
func check_AI_perform()->bool:
	return true

# AI 发动
func effect_30060_AI_start():
	ske.battle_cd(99999)
	ske.set_battle_buff(me.actorId, BUFF_NAME, BUFF_TURNS)
	ske.battle_report()

	var msg = "正以治邪\n一以统万！\n（{0}发动【传教】".format([
		me.get_name()
	])
	SceneManager.show_confirm_dialog(msg, me.actorId)
	LoadControl.set_view_model(3000)
	return

func effect_30060_start():
	ske.battle_cd(99999)
	ske.set_battle_buff(me.actorId, BUFF_NAME, BUFF_TURNS)
	ske.battle_report()

	SceneManager.show_confirm_dialog("正以治邪\n一以统万！", me.actorId)
	LoadControl.set_view_model(2000)
	return
