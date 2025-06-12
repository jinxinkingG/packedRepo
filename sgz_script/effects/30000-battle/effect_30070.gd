extends "effect_30000.gd"

#泅禁效果实现
#【泅禁】小战场,主动技。在水地形时，你可以发动本技能：若对方不是水军，定止对方3回合；否则：定止对方1回合。

func effect_30070_start():
	var stopTurns = 3
	if enemy.get_troops_type() == "水":
		stopTurns = 1

	ske.battle_cd(99999)
	ske.set_battle_buff(actorId, "咒缚", stopTurns)

	var msg = "泅水为牢\n半渡而击！"
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("tactic_end", false)
	return
