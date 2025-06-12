extends "effect_10000.gd"

#纵恣效果
#【纵恣】内政，锁定技。你执行开发和防灾时，以“武”代替“政”进行结算，但民忠变为负增长。

func on_trigger_10002()->bool:
	var cmd = DataManager.get_current_develop_command()
	cmd.actionAttr = actor.get_power()
	return false

func on_trigger_10018()->bool:
	var cmd = DataManager.get_current_develop_command()
	cmd.append_extra_message("此善政也，谁敢不从！")
	cmd.loyalty = -cmd.loyalty
	return false
