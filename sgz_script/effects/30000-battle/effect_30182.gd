extends "effect_30000.gd"

#镇乱效果
#【镇乱】小战场，锁定技。若敌将是「战争初始势力为你方，但转移阵营至对方」的将领，你的所有士兵单位免伤倍率+0.2。

const ENHANCEMENT = {
	"额外免伤": 0.2,
	"BUFF": 1,
}

# 开战时判断是否触发
func on_trigger_30003() -> bool:
	if me.changed_vstate():
		# 自己都。。。就算了吧
		return false
	if not enemy.changed_vstate():
		return false
	ske.set_battle_skill_val(1)
	var msg = "{0}反复无常！\n看{1}镇奸平乱！".format([
		DataManager.get_actor_naughty_title(enemy.actorId, actorId),
		DataManager.get_actor_self_title(actorId),
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false

func on_trigger_30024() -> bool:
	if ske.get_battle_skill_val_int() <= 0:
		return false
	ske.battle_enhance_current_unit(ENHANCEMENT, UNIT_TYPE_SOLDIERS)
	return false
