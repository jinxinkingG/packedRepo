extends "effect_20000.gd"

# 自矜锁定技
#【自矜】大战场，主将锁定技。若你方武将白刃战未胜利，其失去一半机动力。

func on_trigger_20020() -> bool:
	# 敌方触发
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null or loser.disabled:
		return false
	if not me.is_teammate(loser):
		return false
	var ap = int(loser.action_point / 2)
	if ap <= 0:
		return false
	ske.change_actor_ap(loser.actorId, -ap)
	ske.war_report()
	return false
