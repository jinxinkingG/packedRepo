extends "effect_20000.gd"

# 遥援诱发技 #替代防御
#【遥援】大战场，诱发技。你方6格以外的武将被攻击的场合：你替代之进入白刃战。若本次白刃战你战败，你位移到该队友身边；若你获胜且你<烈袭>处于冷却状态时，你的<烈袭>冷却回合数-1。每回合限2次。

const EFFECT_ID = 20655
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TIMES_LIMIT = 2

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_defender_id():
		# 不是防守方，跳过
		return false
	if ske.actorId == me.actorId:
		# 自己没必要触发
		return false
	var defender = bf.get_defender()
	if defender == null or defender.actorId != ske.actorId:
		return false
	if Global.get_range_distance(defender.position, me.position) <= 6:
		return false
	return true

func effect_20655_AI_start() -> void:
	var bf = DataManager.get_current_battle_fight()
	if me.get_soldiers() <= bf.get_defender().get_soldiers() \
		and me.get_soldiers() < 1500:
		LoadControl.end_script()
		return
	goto_step("confirmed")
	return

func effect_20655_start() -> void:
	if me.get_controlNo() < 0:
		# 托管时
		goto_step("AI_start")
		return
	var bf = DataManager.get_current_battle_fight()
	map.cursor.hide()
	var msg = "发动【{0}】\n替代{1}应战\n可否？".format([
		ske.skill_name, ActorHelper.actor(ske.actorId).get_name()
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", false)
	return

func effect_20655_confirmed() -> void:
	var bf = DataManager.get_current_battle_fight()
	var teammate = DataManager.get_war_actor(ske.actorId)
	var attacker = bf.get_attacker()

	ske.cost_war_limited_times(TIMES_LIMIT)
	# 记忆队友和位置
	var dir = attacker.position.direction_to(teammate.position)
	var pos = teammate.position + dir
	var key = "{0}.{1}".format([ske.skill_name, actorId])
	bf.set_env(key, [teammate.actorId, pos.x, pos.y])
	ske.replace_battle_defender(teammate.actorId)
	ske.war_report()

	var msg = "遥为呼应，击首尾至\n{0}来战！\n（{1}代为应战".format([
		DataManager.get_actor_naughty_title(bf.get_attacker_id(), actorId),
		me.get_name(),
	])
	play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation("")
	return
