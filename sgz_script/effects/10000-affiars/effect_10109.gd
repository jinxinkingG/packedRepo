extends "effect_10000.gd"

#哀书锁定技
#【哀书】内政，锁定技。你所在势力选择了继承顺序较低的将领为新君主时，你出面劝阻，并指出更为合适的一名继承人。若听从，势力内的所有武将忠+5；否则，德>80的武将忠-5。（优先级:前法定继承人>后法定继承人>非法继承人）

const EFFECT_ID = 10109
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_10020() -> bool:
	# 多人有「哀书」，只发动一次
	if DataManager.get_env_int("哀书.继承人") >= 0:
		return false
	# 选定的继承人
	var vstateId = DataManager.get_env_int("值")
	var vs = clVState.vstate(vstateId)
	var candidates = vs.get_inheritage_candidates()
	var allActors = []
	for city in clCity.all_cities([vstateId]):
		allActors.append_array(city.get_actor_ids())
	for candidate in candidates:
		if candidate in allActors:
			# 第一个合法继承人
			if candidate == ske.actorId:
				return false
			if candidate == actorId:
				# 自己避嫌
				return false
			# 但未被选为继承人
			var key = "哀书.继承人".format([actorId])
			DataManager.set_env(key, candidate)
			ske.affair_cd(1)
			return true
	return false

func effect_10109_start() -> void:
	var candidate = DataManager.get_env_int("哀书.继承人")
	var msg = "主公虽蒙不幸，早有成议\n当奉{0}为主\n{1}恐难服众".format([
		DataManager.get_actor_honored_title(candidate, actorId),
		DataManager.get_actor_honored_title(ske.actorId, actorId),
	])
	play_dialog(actorId, msg, 3, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_ask")
	return

func effect_10109_ask() -> void:
	var candidate = DataManager.get_env_int("哀书.继承人")
	var msg = "{0}哀书以谏\n议推{1}为主\n是否采纳？".format([
		actor.get_name(), ActorHelper.actor(candidate).get_name(),
	])
	play_dialog(-1, msg, 2, 2001, true)
	SceneManager.actor_dialog.lsc.cursor_index = 1
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_ok", FLOW_BASE + "_deny", false)
	return

func effect_10109_ok() -> void:
	var candidate = DataManager.get_env_int("哀书.继承人")
	DataManager.unset_env("哀书.继承人")
	DataManager.set_env("武将", candidate)
	var vstateId = DataManager.get_env_int("值")
	for city in clCity.all_cities([vstateId]):
		for memberId in city.get_actor_ids():
			ActorHelper.actor(memberId).add_loyalty(5)
	var msg = "幸甚！必继先主遗志！\n（众将拜服\n（忠诚度 +5"
	play_dialog(actorId, msg, 1, 2999)
	return

func effect_10109_deny() -> void:
	DataManager.unset_env("哀书.继承人")
	var vstateId = DataManager.get_env_int("值")
	var memberIds = []
	for city in clCity.all_cities([vstateId]):
		for memberId in city.get_actor_ids():
			if memberId == ske.actorId:
				continue
			if ActorHelper.actor(memberId).get_moral() > 80:
				memberIds.append(memberId)
	memberIds.erase(actorId)
	if ske.actorId != actorId:
		memberIds.insert(0, actorId)
	var names = []
	for memberId in memberIds:
		var actor = ActorHelper.actor(memberId)
		actor.add_loyalty(-5)
		names.append(actor.get_name())
	if names.size() > 3:
		names[2] += "等{0}人".format([names.size()])
		names = names.slice(0, 2)
	var msg = "主非主，臣非臣，国将何存？"
	if actorId == ske.actorId:
		msg = "勉为其难，众意难平……"
	msg += "\n（{0}心怀不满\n（忠诚度 -5".format([
		"、".join(names)
	])
	play_dialog(actorId, msg, 3, 2999)
	return
