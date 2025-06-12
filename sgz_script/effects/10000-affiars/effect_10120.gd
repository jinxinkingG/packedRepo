extends "effect_10000.gd"

# 固拥效果锁定技
#【固拥】内政，锁定技。你方君主死亡时，若<选嫡>武将（<未指定>）最终未成为君主，则你直接死亡。反之，你的忠变为99，并永久获得<宴请>。

const EFFECT_ID = 10120
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const XUANDI_EFFECT_ID = 10119

func on_trigger_10020() -> bool:
	var targetId = ske.affair_get_skill_val_int(XUANDI_EFFECT_ID)
	if targetId < 0:
		return false
	if ske.actorId == actorId:
		return false
	ske.affair_cd(1)
	return true

func effect_10120_start() -> void:
	var targetId = ske.affair_get_skill_val_int(XUANDI_EFFECT_ID)
	if targetId != ske.actorId:
		# 拥护对象未被选为继承人
		var msg = "今主公不幸，当奉{0}为主\n{1}何能服众？\n吾宁死也！".format([
			DataManager.get_actor_honored_title(targetId, actorId),
			DataManager.get_actor_honored_title(ske.actorId, actorId),
		])
		play_dialog(actorId, msg, 0, 2000)
	else:
		# 拥护对象被选为继承人
		var msg = "今主公不幸，当奉{0}为主\n吾等誓死追随！".format([
			DataManager.get_actor_honored_title(targetId, actorId),
		])
		play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_suicide")
	return

func effect_10120_suicide() -> void:
	actor.set_hp(-1)
	actor.set_status_dead()
	clCity.move_out(actorId)
	var msg = "{0}伏剑自尽\n… …".format([
		actor.get_name(),
	])
	play_dialog(-1, msg, 2, 2999)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_ok")
	return

func effect_10120_ok() -> void:
	ske.affair_add_skill(actorId, "宴请", 99999)
	var msg = "{0}拥立{1}".format([
		actor.get_name(), ActorHelper.actor(ske.actorId).get_name(),
	])
	if actor.get_loyalty() < 99:
		actor.set_loyalty(99)
		msg += "\n忠现为 99"
	msg += "\n解锁【宴请】"
	play_dialog(-1, msg, 2, 2999)
	return
