extends "effect_10000.gd"

#忠纯效果
#【忠纯】内政,锁定技。若你的忠>政，则你在进行内政活动时，以你的忠替代政计算。你忠99时，每月经验+150

func on_trigger_10001()->bool:
	if actor.get_loyalty() == 99:
		actor.add_exp(150)
	return false

func on_trigger_10002()->bool:
	var cmd = DataManager.get_current_develop_command()
	if actor.get_loyalty() > actor.get_politics():
		cmd.actionAttr = actor.get_loyalty()
	return false
