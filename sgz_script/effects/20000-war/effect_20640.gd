extends "effect_20000.gd"

# 胁停诱发技
#【胁停】大战场，诱发技。你的队友被攻击时，你可以派出X/2兵力发动突袭：使对方减少X兵力。每个回合限3次。X＝你的政。

const EFFECT_ID = 20640
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_defender_id():
		# 不是防守方，跳过
		return false
	if ske.actorId == me.actorId:
		# 自己没必要触发
		return false
	if me.get_soldiers() == 0:
		return false
	if bf.get_attacker().get_soldiers() == 0:
		return false
	return true

func effect_20640_AI_start() -> void:
	goto_step("start")
	return

func effect_20640_start() -> void:
	var bf = DataManager.get_current_battle_fight()
	var attacker = bf.get_attacker()

	ske.cost_war_limited_times(3)
	var x = int(actor.get_politics() / 2)
	x = ske.sub_actor_soldiers(actorId, x)
	ske.sub_actor_soldiers(attacker.actorId, x * 2)
	ske.war_report()

	var msg = "突袭{0}侧翼，挫其锋锐！\n（{1}损兵 {2}\n（令{0}损兵 {3}".format([
		attacker.get_name(), me.get_name(), x, x * 2,
	])
	play_dialog(actorId, msg, 0, 2990)
	return
