extends "effect_20000.gd"

# 骤兵诱发技 #禁用计策
#【骤兵】大战场，诱发技。你攻击时，可以选择禁用你的1个计策，使那次的攻击宣言不消耗机动力。每回合限1次。

const EFFECT_ID = 20665
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20015()->bool:
	# 没有可用计策了，不可发动
	if me.get_stratagems().empty():
		return false
	# AI 有这个技能的都是笨蛋，可以无脑发动
	return true

func effect_20665_AI_start() -> void:
	var stratagems = me.get_stratagems()
	# AI 随便扔一个
	stratagems.shuffle()
	DataManager.set_env("目标项", stratagems[0].name)
	goto_step("selected")
	return

func effect_20665_start() -> void:
	var stratagems = me.get_stratagems()
	var items = []
	for stratagem in stratagems:
		items.append(stratagem.name)

	var msg = "禁用自身一个计策\n可返还攻击机动力消耗\n选哪个？"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.bind_top_menu(items, items, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_item(FLOW_BASE + "_selected", false)
	return

func effect_20665_selected() -> void:
	var scheme = DataManager.get_env_str("目标项")

	var bf = DataManager.get_current_battle_fight()
	me.dic_skill_cd[scheme] = 99999
	ske.append_message("选择禁用<y{0}>".format([scheme]), actorId)
	ske.cost_war_cd(1)
	var ap = ske.change_actor_ap(actorId, bf.ap)
	ske.war_report()

	var msg = "多算何益？速战速决！\n（已禁用{0}"
	if ap > 0:
		msg += "，机动力回复 {1}"
	msg = msg.format([
		scheme, ap
	])
	play_dialog(actorId, msg, 1, 2990)
	return
