extends Resource


const current_step_name = "内政-灾害-当前步骤";
const next_step_name = "内政-灾害-下个步骤";
const set_tarcitys_name = "内政-灾害-城市";
const set_disater_name = "内政-灾害";

#读取本月灾害
func get_disater()->String:
	if(!set_disater_name in DataManager.common_variable):
		return "";
	return DataManager.common_variable[set_disater_name];

func set_disater(disatar:String):
	DataManager.common_variable[set_disater_name]=disatar;


#读取受灾城市
func get_tar_citys()->Array:
	if(!set_tarcitys_name in DataManager.common_variable):
		return [];
	return Array(DataManager.common_variable[set_tarcitys_name]);

func set_tar_citys(citys:Array):
	DataManager.common_variable[set_tarcitys_name]=citys;

#读取当前步骤
func get_current_step():
	if(!current_step_name in DataManager.common_variable):
		return -1;
	return int(DataManager.common_variable[current_step_name]);

#设置当前步骤
func set_current_step(step:int):
	DataManager.common_variable[current_step_name]=int(step);
	
#读取下个步骤
func get_next_step():
	if(!next_step_name in DataManager.common_variable):
		return -1;
	return int(DataManager.common_variable[next_step_name]);

#设置下个步骤
func set_next_step(step:int):
	DataManager.common_variable[next_step_name]=int(step);

func _init() -> void:
	FlowManager.bind_signal_method("_disater_next_step",self,"_disater_next_step");
	

func start():
	SceneManager.hide_all_tool();
	set_next_step(0);
	set_current_step(-1);
	pass

func end():
	SceneManager.hide_all_tool();
	set_next_step(-1);
	FlowManager.add_flow("month_auto_events_end");
	return

func _process(delta: float) -> void:
	var next_step:int = get_next_step();
	var month = DataManager.month;
	if(next_step<0):
		return;
	if(next_step == get_current_step()):
		_input_key();
		return;
	set_current_step(next_step);
	match get_current_step():
		0:
			DataManager.player_choose_city = 0;#事件动画一定显示在左侧
			var disater_name = "";
			if(month in [5,6]):
				disater_name = "洪涝";
			elif(month in [8,9]):
				disater_name = "旱灾";
			else:
				set_next_step(3);
				return;
			var disater_citys = [];
			for city in clCity.all_cities():
				if city.get_vstate_id() < 0:
					continue;
				if city.chance_for_disaster(disater_name):
					disater_citys.append(city.ID)
			set_tar_citys(disater_citys);
			if(disater_citys.empty()):
				set_next_step(3);
				return;
			set_disater(disater_name);
			if(disater_name == "洪涝"):
				SceneManager.show_unconfirm_dialog("各地出现洪涝");
				SceneManager.play_affiars_animation("Disaster_Waterlog","_disater_next_step");
			elif(disater_name == "旱灾"):
				SceneManager.show_unconfirm_dialog("各地出现旱情");
				SceneManager.play_affiars_animation("Disaster_Dry","_disater_next_step");
		1:#具体城市的灾害影响
			texts.clear();
			SceneManager.hide_all_tool()
			var is_effect = true;
			var disater_citys = get_tar_citys();
			if(disater_citys.empty()):
				set_next_step(3);
				return;
			var city = clCity.city(disater_citys.pop_front())
			if city.get_defence() >= 99:
				is_effect = false;
				city.add_city_property("防灾", -Global.get_random(10,20))
			else:
				var sodierDead = Global.get_random(0,110-city.get_defence())/4;#单人损兵量
				var farmHurt = Global.get_random(0,110-city.get_defence())/4;#土地损失
				var bussHurt = Global.get_random(0,110-city.get_defence())/4;#产业损失
				var poplationHurt=Global.get_random(0,110-city.get_defence())/4*100;#人口损失
				city.add_city_property("土地", farmHurt)
				city.add_city_property("产业", -bussHurt)
				city.add_city_property("人口", -poplationHurt)
			if city.get_vstate_id() == -1:
				set_next_step(2);
				return;
			var talk_confirm_playerNo = -1;
			#寻找本城最高统治的玩家（有君主显示君主，无君主判断太守）
			var satrapId = city.get_actor_ids()[0]
			var lord_controlNo = DataManager.get_actor_controlNo(city.get_lord_id());
			var satrap_controlNo = DataManager.get_actor_controlNo(satrapId);
			if(lord_controlNo>=0):
				talk_confirm_playerNo = lord_controlNo;
			else:
				talk_confirm_playerNo = satrap_controlNo;
			var talk_actorId = satrapId
			#玩家非君主和太守时，寻找城内是否存在武将
			if(talk_confirm_playerNo<0):
				var find_player = false;
				for actorId in city.get_actor_ids():
					var controlNo = DataManager.get_actor_controlNo(actorId);
					if(controlNo<0):
						continue;
					find_player = true;
					talk_actorId = actorId;
					talk_confirm_playerNo = controlNo;
					break;
			
			if(talk_confirm_playerNo>=0):
				DataManager.twinkle_citys = [city.ID];
				DataManager.player_choose_city = city.ID
				var msg = "大事不好\n{0}出现{1}".format([
					city.get_name(), get_disater()
				])
				push_dialogs(talk_confirm_playerNo,msg,talk_actorId,3);
				if(!is_effect):
					push_dialogs(talk_confirm_playerNo,"但是请放心\n我国并未受到影响",talk_actorId,1);
			if(!texts.empty()):
				#显示对话
				pop_show_dialog();
			else:
				set_next_step(get_current_step()+1);
		2:
			set_next_step(1);
		3:#暴动事件
			var disater_citys = [];
			for city in clCity.all_cities():
				if city.get_vstate_id() < 0:
					continue;
				if city.chance_for_rebellion():
					disater_citys.append(city.ID);
			set_tar_citys(disater_citys);
			set_next_step(4);
		4:#具体每个城市暴动
			texts.clear();
			SceneManager.hide_all_tool()
			var is_effect = true;
			var disater_citys = get_tar_citys();
			if(disater_citys.empty()):
				set_next_step(6);
				return;
			var city = clCity.city(disater_citys.pop_front())
			var X:int=0;
			var r=Global.get_random(1,3);
			city.add_loyalty(-Global.get_random(2,5))
			var msg_list:Array = [];
			match r:
				1:#减人口
					city.add_city_property("人口", -Global.get_random(1,5)*100)
					msg_list.append("城内民众\n纷纷背井离乡");
				2:#减金米
					city.add_gold(-int(Global.get_random(1,2)*city.get_pop()/2000.0))
					city.add_rice(-int(Global.get_random(1,2)*city.get_pop()/2000.0))
					msg_list.append("民众集结于城内\n开仓放粮，分摊官银");
				3:#减土地产业
					city.add_city_property("土地", -int(Global.get_random(0,max(5,city.get_land()/16))))
					city.add_city_property("产业", -int(Global.get_random(0,max(5,city.get_eco()/16))))
					msg_list.append("民众皆不事生产\n以抗议暴政");

			var talk_confirm_playerNo = -1;
			#寻找本城最高统治的玩家（有君主显示君主，无君主判断太守）
			var lord_controlNo = DataManager.get_actor_controlNo(city.get_lord_id());
			var satrap_controlNo = DataManager.get_actor_controlNo(city.get_actor_ids()[0]);
			if(lord_controlNo>=0):
				talk_confirm_playerNo = lord_controlNo;
			else:
				talk_confirm_playerNo = satrap_controlNo;
			var talk_actorId = city.get_actor_ids()[0]
			#玩家非君主和太守时，寻找城内是否存在武将
			if(talk_confirm_playerNo<0):
				var find_player = false;
				for actorId in city.get_actor_ids():
					var controlNo = DataManager.get_actor_controlNo(actorId);
					if(controlNo<0):
						continue;
					find_player = true;
					talk_actorId = actorId;
					talk_confirm_playerNo = controlNo;
					break;
			if(talk_confirm_playerNo>=0):
				DataManager.twinkle_citys = [city.ID];
				for s in msg_list:
					push_dialogs(talk_confirm_playerNo,s,talk_actorId,3);
				
			if(!texts.empty()):
				#显示对话
				DataManager.player_choose_city = city.ID;
				DataManager.common_variable["对话"]="大事不好\n{0}发生叛乱!".format([city.get_name()])
				SceneManager.show_unconfirm_dialog(DataManager.common_variable["对话"]);
				SceneManager.play_affiars_animation("Disaster_Riot","_disater_next_step");
			else:
				set_next_step(6);
		5:#等待玩家自行确认
			SceneManager.show_confirm_dialog(DataManager.common_variable["对话"]);
			SceneManager.dialog_msg_complete(true);
		6:#结束
			end();
			
func _disater_next_step():
	FlowManager.flows_history_list.clear();
	set_next_step(get_current_step()+1);

#按键操控
func _input_key():
	var current_step:int = get_current_step();
	match current_step:
		1:#灾害确认
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				if(pop_show_dialog()):
					return;
				DataManager.twinkle_citys.clear();
				set_next_step(current_step+1);
				
		5:#暴动确认
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				if(pop_show_dialog()):
					return;
				DataManager.twinkle_citys.clear();
				set_next_step(4);
				
	pass



var texts:Array = [];
#type:0-确认对话框，1-无需确认的对话框
func push_dialogs(confirmNo:int,text:String,actorId:int=-1,mood:int=2):
	var dic = {
		"confirmNo":confirmNo,
		"text":text,
		"actorId":actorId,
		"mood":mood,
	}
	texts.append(dic);

func pop_show_dialog(type:int=0)->bool:
	if(texts.size()==0):
		return false;
	
	var dic:Dictionary = texts[0];
	var confirmNo = dic["confirmNo"];
	FlowManager.set_current_control_playerNo(confirmNo);
	match type:
		0:
			SceneManager.show_confirm_dialog(dic["text"],dic["actorId"],dic["mood"]);
		1:
			SceneManager.show_unconfirm_dialog(dic["text"],dic["actorId"],dic["mood"]);
	texts.remove(0);
	return true;
