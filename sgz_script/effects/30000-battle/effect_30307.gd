extends "effect_30000.gd"

# 猝袭小战场效果
#【猝袭】大战场，锁定技。你方回合结束时，你选择你一格范围内非城地形的一个对方武将发动：无消耗对其使用一次计策要击。若成功，结算要击伤害；若失败，你对其发起攻击，且你的步兵和弓兵不参与白刃战。

func on_trigger_30003()->bool:
	if bf.source != ske.skill_name:
		return false

	var prevSoldiers = actor.get_soldiers()
	var soldiers = 0

	var settings = {
		"兵种数量": {},
		"分配顺序": ["骑"],
	}
	var numberSetting = bf.get_env_dict("兵种数量.{0}".format([actorId]))
	# 计算骑兵数量
	var diff = prevSoldiers - numberSetting["步"] * 100 - numberSetting["弓"] * 100
	if prevSoldiers >= 1000:
		soldiers = prevSoldiers
		soldiers -= numberSetting["步"] * int(prevSoldiers / 10)
		soldiers -= numberSetting["弓"] * int(prevSoldiers / 10)
	elif diff > 0:
		soldiers = diff
	actor.set_soldiers(soldiers)
	numberSetting["步"] = 0
	numberSetting["弓"] = 0
	settings["兵种数量"] = numberSetting
	bf.update_extra_formation_setting(
		actorId, ske.skill_name,
		"场合", settings
	)

	# 修正白兵战数据
	bf.attackerSoldiers = soldiers

	# 记录扣减的兵力
	ske.set_war_skill_val(prevSoldiers - soldiers, 1)
	return false

func on_trigger_30004() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.source != ske.skill_name:
		return false

	# 战后加上扣减的兵力
	var soldiers = ske.get_war_skill_val_int()
	actor.set_soldiers(actor.get_soldiers() + soldiers)
	ske.set_war_skill_val(0, 0)
	return false
