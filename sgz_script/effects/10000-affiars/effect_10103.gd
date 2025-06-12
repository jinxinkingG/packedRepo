extends "effect_10000.gd"

#留怠锁定技
#【留怠】内政，君主锁定技。你方回合开始时，命令书额外+X；你方命令书≤X时，无法执行出征指令（X=你方结盟的势力数）。

func on_trigger_10001()->bool:
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()
	var allied = 0
	for vs in clVState.all_vstates():
		if vs.id == vstateId:
			continue
		if vs.is_perished():
			continue
		if DataManager.is_alliance(vstateId, vs.id):
			allied += 1
	if allied <= 0:
		return false
	var orders = min(3, allied)
	DataManager.orderbook += orders
	var msg = "目前与{0}势力结盟\n【{1}】增加{2}枚命令书".format([
		allied, ske.skill_name, orders,
	])
	city.attach_free_dialog(msg, actorId)
	var forbidden = DataManager.get_env_dict("内政.MONTHLY.禁出征")
	var formula = "DataManager.orderbook <= {0}".format([orders])
	forbidden[str(city.get_vstate_id())] = [ske.skill_name, formula]
	DataManager.set_env("内政.MONTHLY.禁出征", forbidden)
	return false
