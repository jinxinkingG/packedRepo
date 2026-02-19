extends "effect_20000.gd"

#敛财效果
#【敛财】内政，主动技。使用后，你的永久标记[金]+X，且产业和土地分别-（X/4），民忠-X/50，同时，你死亡或者被俘虏时，击杀方，获得杨松永久标记[金]等数量的金。X=（本城产业值+土地值）。

const FLAG_SCENE_ID = 10000
const FLAG_EFF_ID = 10023
const FLAG_NAME = "金"

func on_trigger_20027()->bool:
	var reason = DataManager.get_env_str("战争.DISABLE.TYPE")
	if not reason in ["俘虏", "阵亡"]:
		return false
	var wv = me.war_vstate().get_enemy_vstate()
	if wv == null:
		return false
	var leader = wv.get_leader()
	if leader == null:
		return false
	var gold = ske.get_skill_flags(FLAG_SCENE_ID, FLAG_EFF_ID, FLAG_NAME)
	gold = min(9999 - wv.money, gold)
	if gold <= 0:
		return false
	ske.add_skill_flags(FLAG_SCENE_ID, FLAG_EFF_ID, FLAG_NAME, -gold)
	ske.change_wv_gold(gold, wv)
	ske.war_report()
	var msg = "{0}此贼，贪腐成性！\n不义之财，充作军资\n（没收{0}的[金] {1}\n（{2}军金现为 {3}".format([
		actor.get_name(), gold, leader.get_name(), wv.money,
	])
	leader.attach_free_dialog(msg, 0)
	return false
	
