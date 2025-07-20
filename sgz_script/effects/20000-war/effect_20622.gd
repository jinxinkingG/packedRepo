extends "effect_20000.gd"

# 血卫诱发部分
#【血卫】大战场，主动技。你可指定1名队友，消耗你5机动力发动。直到下次对方回合结束前，指定的队友被攻击时，你可选择代替之进行战斗。不能连续两轮指定同1队友，每回合限1次。

const EFFECT_ID = 20622
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const ACTIVE_EFFECT_ID = 20621

func on_trigger_20015() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_defender_id():
		# 不是防守方，跳过
		return false
	if ske.actorId != _get_marked_actor_id():
		# 不是保护目标，跳过
		return false
	return true

func effect_20622_start() -> void:
	var bf = DataManager.get_current_battle_fight()

	var msg = "发动【{0}】\n替代{1}战斗防御\n可否？".format([
		ske.skill_name, ActorHelper.actor(ske.actorId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", false)
	return

func effect_20622_confirmed() -> void:
	var bf = DataManager.get_current_battle_fight()

	bf.set_env("血卫", actorId)
	ske.replace_battle_defender(ske.actorId)
	ske.war_report()

	var msg = "{0}受袭，岂能坐视？\n({1}代替被攻击".format([
		DataManager.get_actor_honored_title(ske.actorId, me.actorId),
		me.get_name(),
	])
	play_dialog(actorId, msg, 0, 2990)
	return

func _get_marked_actor_id() -> int:
	var marked = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID)
	if marked < 0:
		return me.get_main_actor_id()
	var wa = DataManager.get_war_actor(marked)
	if wa == null or wa.disabled or not wa.has_position():
		return me.get_main_actor_id()
	return marked

