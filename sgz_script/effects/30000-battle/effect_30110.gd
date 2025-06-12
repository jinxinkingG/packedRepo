extends "effect_30000.gd"

#威赫效果
#【威赫】小战场,锁定技。对手士气降低 3*X，胆降低 5*X，前 X 回合无法发动战术。X = 本回合白兵胜利次数 + 1，最大为 3

func on_trigger_30005()->bool:
	var x = ske.get_war_skill_val_int() + 1
	x = min(3, x)
	ske.battle_change_morale(-x * 3, enemy)
	ske.battle_change_courage(-x * 5, enemy)
	ske.set_battle_buff(enemy.actorId, "威赫", x)
	ske.battle_report()
	return false

func on_trigger_30099()->bool:
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null:
		return false
	if me.actorId == loser.actorId:
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null:
		return false
	if winner.actorId != me.actorId:
		return false
	ske.set_war_skill_val(ske.get_war_skill_val_int() + 1, 1)
	return false
