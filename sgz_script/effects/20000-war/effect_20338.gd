extends "effect_20000.gd"

#筹粮被动触发判断
#【筹粮】大战场，锁定技。大战场第5、10、15、20、25的回合初始，若你方米小于2000。你会办法筹措军粮，根据你方战况惨烈程度，使你方增加一定量的米。（实际公式不公开，米回复量＝你方累计损失的士兵/10，上限为150）

const EFFECT_ID = 20338

func on_trigger_20016()->bool:
	var wf = DataManager.get_current_war_fight()
	if wf.date % 5 != 0:
		return false
	var wv = me.war_vstate()
	if wv == null:
		return false
	if wv.rice >= 2000:
		return false
	var meat = min(150, int(wv.get_lose_sodiers() / 10))
	if meat <= 0:
		return false
	ske.change_wv_rice(meat)
	ske.war_report()
	return false
