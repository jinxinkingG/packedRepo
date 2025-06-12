extends "effect_30000.gd"

#计袭被动效果
#【计袭】大战场,主动技&诱发技。你使用伤兵类计策命中的场合，你可以发动：你方武力最高的将领与该受计者进入白刃战，且在此次白刃战中，那名敌将技能失效。每个回合限1次。若本次战争未触发过，你可以主动发动，修改计袭的发起武将。

const KEY_SKILL_ACTOR = "技能.计袭.武将"

func on_trigger_30099()->bool:
	var bf = DataManager.get_current_battle_fight()
	if not check_env([KEY_SKILL_ACTOR]):
		return false
	var selected = get_env_int(KEY_SKILL_ACTOR)
	unset_env(KEY_SKILL_ACTOR)
	if selected != ske.actorId:
		# 当前战斗未触发计袭
		return false
	var wa = DataManager.get_war_actor(selected)
	if wa == null:
		return false
	var enemy = wa.get_battle_enemy_war_actor()
	if enemy == null:
		return false
	var buffStatus = enemy.get_buff("沉默")
	if buffStatus["回合数"] <= 0:
		return false
	if buffStatus["来源武将"] != me.actorId:
		return false
	ske.remove_war_buff(enemy.actorId, "沉默")
	return false
