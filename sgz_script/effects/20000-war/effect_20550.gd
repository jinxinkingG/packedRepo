extends "effect_20000.gd"

#寻嫉锁定技
#【寻嫉】大战场，锁定技。若敌方武将移动至与你相邻的位置时，必须与你进入白刃战。

const EFFECT_ID = 20550
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const QIANZHUI_EFFECT_ID = 20548

func on_trigger_20003() -> bool:
	if DataManager.get_env_int("移动") != 0:
		return false
	if DataManager.get_env_int("结束移动") != 1:
		return false
	if check_combat_targets([ske.actorId]).empty():
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa.get_controlNo() >= 0:
		# 玩家要求历史移动记录，不允许原地触发
		if DataManager.get_env_array("历史移动记录").empty():
			return false

	if Global.get_distance(wa.position, me.position) != 1:
		return false

	return true

func effect_20550_AI_start() -> void:
	goto_step("start")
	return

func effect_20550_start() -> void:
	var marked = ske.get_war_skill_val_int(QIANZHUI_EFFECT_ID, -1, -1)
	var msg = "既敢近前，何妨一战！"
	if marked >= 0:
		if marked == ske.actorId:
			msg = "寻尔多时，竟自撞来\n却不是求死！"
		else:
			msg = "阻我寻仇\n容你不得！"
	me.attach_free_dialog(msg, 0)
	start_battle_and_finish(actorId, ske.actorId)
	skill_end_clear(true)
	return
