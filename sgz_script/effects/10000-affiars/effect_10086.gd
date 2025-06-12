extends "effect_10000.gd"

#过论内政效果
#【过论】内政&大战场,锁定技。1.内政:非12月,你整日醉酒不参与任何内政活动；12月，你方命令书不多于2枚时，你执行提升产业/土地/人口/防灾/赏赐/民忠，效果为4倍。2.大战场：战争前8日，你拥有<看破>；战争第9日开始，你拥有<急功>。

const DIALOGS = [
	"我有嘉宾，鼓瑟吹笙~",
	"既醉以酒，既饱以德…",
	"宾之初筵，左右秩秩…",
]

const EFFECT_ID = 10086
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_10008()->bool:
	return DataManager.month != 12

func effect_10086_start():
	SceneManager.hide_all_tool()
	var msg = DIALOGS[randi() % DIALOGS.size()]
	msg += "\nZzz Zzzzzz\n（{0}醉酒中，不能理事".format([actor.get_name()])
	SceneManager.show_confirm_dialog(msg, actorId, 1)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation("player_ready")
	return

func on_trigger_10002()->bool:
	if DataManager.month != 12:
		return false
	if DataManager.orderbook > 2:
		return false
	var cmd = DataManager.get_current_develop_command()
	cmd.effectRate *= 4
	var msg = "区区小事，有何难哉\n（临阵烧香，四倍效果".format([actor.get_name()])
	cmd.append_extra_message(msg)
	return false
