extends "effect_20000.gd"

#敛财效果
#【敛财】内政,主动技。贪婪是你的本性，发动后，损害所在城市的产业、土地和统治度，转化为你的[金]标记。 你被击杀或俘虏时，对方军势获得你的[金] ，转化为金，最高 9999。

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
	
