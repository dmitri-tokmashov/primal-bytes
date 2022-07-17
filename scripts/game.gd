extends Node

var _glass: Texture;
var cursor: Vector2;
var mode: int = 0;#0 - стартовое меню, 1 - меню настройки генов, 2 - игра
var code: String = "YAA444000";
onready var _world = get_node("viewport/world");

func _ready():
	_world.interface = $viewport/canvas/interface;
	$room/monitor/glass.connect("input_event", self, "cursor_update");
	get_tree().paused = true;

func _process(delta):
	_glass = $viewport.get_texture();
	_glass.flags = 2;
	$room/monitor/RootNode/CRT_Monitor.get_active_material(0).set_shader_param("texture_albedo", _glass);
	$room/monitor/RootNode/CRT_Monitor.get_active_material(0).set_shader_param("texture_emission", _glass);

func _input(event):
	if event.is_action_pressed("zoom_in"):
		_world.camera(true);
	elif event.is_action_pressed("zoom_out"):
		_world.camera(false);
	if event.is_action_pressed("key_enter"):
		if mode == 0:
			_world.interface.get_node("logo").visible = false;
			_world.interface.get_node("enter").visible = false;
			_world.interface.get_node("code").visible = true;
			_world.interface.get_node("description").visible = true;
			_world.interface.get_node("text_top").visible = true;
			_world.interface.get_node("text_bottom").visible = true;
			_world.interface.get_node("background_bottom").visible = true;
			mode = 1;
		if mode == 1 and int(code[3]) + int(code[4]) + int(code[5]) == 16:
			_world.interface.get_node("text_top").text = "РЕЖИМ: АТАКА";
			_world.interface.get_node("text_bottom").set("custom_colors/font_color", Color(1, 1, 1));
			_world.state_update();
			_world.interface.get_node("cursor").visible = true;
			_world.interface.get_node("code").visible = false;
			_world.interface.get_node("description").visible = false;
			_world.interface.get_node("background_bottom").visible = false;
			_world.interface.get_node("background").visible = false;
			_world.player.code = code;
			get_tree().paused = false;
			mode = 2;
	if mode == 1:
		if (event.is_action_pressed("ui_right") and _world.interface.get_node("code").self_modulate == Color8(255, 85, 255)) or (event.is_action_pressed("ui_left") and _world.interface.get_node("code").self_modulate == Color8(255, 255, 255)):
			_world.interface.get_node("code").self_modulate = Color8(85, 255, 255);
			_world.interface.get_node("description").text = "ГЕН СИЛЫ\nУРОВЕНЬ: " + code[3] + "\nОПРЕДЕЛЯЕТ\nУРОН, НАНОСИМЫЙ\nАТАКАМИ БАЙТА";
		elif (event.is_action_pressed("ui_right") and _world.interface.get_node("code").self_modulate == Color8(85, 255, 255)) or (event.is_action_pressed("ui_left") and _world.interface.get_node("code").self_modulate == Color8(255, 85, 255)):
			_world.interface.get_node("code").self_modulate = Color8(255, 255, 255);
			_world.interface.get_node("description").text = "ГЕН ВЫНОСЛИВОСТИ\nУРОВЕНЬ: " + code[4] + "\nОПРЕДЕЛЯЕТ ЗАПАС\nЭНЕРГИИ БАЙТА\nИ ПРОДОЛЖИТЕЛЬНОСТЬ\nЕГО ЖИЗНИ";
		elif (event.is_action_pressed("ui_right") and _world.interface.get_node("code").self_modulate == Color8(255, 255, 255)) or (event.is_action_pressed("ui_left") and _world.interface.get_node("code").self_modulate == Color8(85, 255, 255)):
			_world.interface.get_node("code").self_modulate = Color8(255, 85, 255);
			_world.interface.get_node("description").text = "ГЕН ЛОВКОСТИ\nУРОВЕНЬ: " + code[5] + "\nОПРЕДЕЛЯЕТ\nСКОРОСТЬ ДВИЖЕНИЯ\nБАЙТА";
		if _world.interface.get_node("code").self_modulate == Color8(85, 255, 255) and (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down")):
			if event.is_action_pressed("ui_up") and code[3] != "8" and int(code[3]) + int(code[4]) + int(code[5]) != 16:
				code[3] = str(int(code[3]) + 1);
			elif event.is_action_pressed("ui_down") and code[3] != "1":
				code[3] = str(int(code[3]) - 1);
			_world.interface.get_node("description").text = "ГЕН СИЛЫ\nУРОВЕНЬ: " + code[3] + "\nОПРЕДЕЛЯЕТ\nУРОН, НАНОСИМЫЙ\nАТАКАМИ БАЙТА";
			if int(code[3]) + int(code[4]) + int(code[5]) == 16:
				_world.interface.get_node("text_top").text = "НАЖМИТЕ ENTER ДЛЯ НАЧАЛА ИГРЫ";
			else:
				_world.interface.get_node("text_top").text = "СВОБОДНЫХ ГЕНЕТИЧЕСКИХ ОЧКОВ: " + str(16 - int(code[3]) - int(code[4]) - int(code[5]));
		elif _world.interface.get_node("code").self_modulate == Color8(255, 255, 255) and (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down")):
			if event.is_action_pressed("ui_up") and code[4] != "8" and int(code[3]) + int(code[4]) + int(code[5]) != 16:
				code[4] = str(int(code[4]) + 1);
			elif event.is_action_pressed("ui_down") and code[4] != "1":
				code[4] = str(int(code[4]) - 1);
			_world.interface.get_node("description").text = "ГЕН ВЫНОСЛИВОСТИ\nУРОВЕНЬ: " + code[4] + "\nОПРЕДЕЛЯЕТ ЗАПАС\nЭНЕРГИИ БАЙТА\nИ ПРОДОЛЖИТЕЛЬНОСТЬ\nЕГО ЖИЗНИ";
			if int(code[3]) + int(code[4]) + int(code[5]) == 16:
				_world.interface.get_node("text_top").text = "НАЖМИТЕ ENTER ДЛЯ НАЧАЛА ИГРЫ";
			else:
				_world.interface.get_node("text_top").text = "СВОБОДНЫХ ГЕНЕТИЧЕСКИХ ОЧКОВ: " + str(16 - int(code[3]) - int(code[4]) - int(code[5]));
		elif _world.interface.get_node("code").self_modulate == Color8(255, 85, 255) and (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down")):
			if event.is_action_pressed("ui_up") and code[5] != "8" and int(code[3]) + int(code[4]) + int(code[5]) != 16:
				code[5] = str(int(code[5]) + 1);
			elif event.is_action_pressed("ui_down") and code[5] != "1":
				code[5] = str(int(code[5]) - 1);
			_world.interface.get_node("description").text = "ГЕН ЛОВКОСТИ\nУРОВЕНЬ: " + code[5] + "\nОПРЕДЕЛЯЕТ\nСКОРОСТЬ ДВИЖЕНИЯ\nБАЙТА";
			if int(code[3]) + int(code[4]) + int(code[5]) == 16:
				_world.interface.get_node("text_top").text = "НАЖМИТЕ ENTER ДЛЯ НАЧАЛА ИГРЫ";
			else:
				_world.interface.get_node("text_top").text = "СВОБОДНЫХ ГЕНЕТИЧЕСКИХ ОЧКОВ: " + str(16 - int(code[3]) - int(code[4]) - int(code[5]));
	elif mode == 2 and is_instance_valid(_world.player):
		if event.is_action_pressed("byte_bleed"):
			_world.player.fire_mode = 0;
			_world.interface.get_node("text_top").text = "РЕЖИМ: АТАКА";
		if event.is_action_pressed("byte_feed"):
			_world.player.fire_mode = 1;
			_world.interface.get_node("text_top").text = "РЕЖИМ: ПОДДЕРЖКА";
		if event.is_action_pressed("byte_seed"):
			_world.player.fire_mode = 2;
			_world.interface.get_node("text_top").text = "РЕЖИМ: РАЗМНОЖЕНИЕ";
		if event.is_action_pressed("byte_fire"):
			if _world.player.fire_mode == 0 and not _world.player.bites[0].visible:
				_world.player.fire_bleed(_world.player.position + cursor - Vector2(320, 240));
			elif _world.player.fire_mode == 1 and not _world.player.bites[1].visible:
				_world.player.fire_feed(_world.player.position + cursor - Vector2(320, 240));
			elif _world.player.fire_mode == 2 and not _world.player.bites[2].visible:
				_world.player.fire_seed(_world.player.position + cursor - Vector2(320, 240));

func cursor_update(camera, event, position, normal, shape_idx):
	if event is InputEventMouseMotion and mode == 2:
		cursor = Vector2(320 + position.x * 2133.333, 240 - (position.y - 0.088) * 2142.857);
		if cursor.x >= 0 and cursor.x <= 640 and cursor.y >= 0 and cursor.y <= 480:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
			if cursor.x < 0:
				cursor.x = 0;
			elif cursor.x > 640:
				cursor.x = 640;
			if cursor.y < 0:
				cursor.y = 0;
			elif cursor.y > 480:
				cursor.y = 480;
		_world.interface.get_node("cursor").rect_position = cursor + Vector2(-32, -32);

func monitor_update():
	_glass = $viewport.get_texture();
	_glass.flags = 14;
	$room/monitor/RootNode/CRT_Monitor.get_active_material(0).set_shader_param("texture_albedo", _glass);
	$room/monitor/RootNode/CRT_Monitor.get_active_material(0).set_shader_param("texture_emission", _glass);

func game_over(win):
	get_tree().paused = true;
	_world.interface.get_node("text_top").visible = false;
	_world.interface.get_node("text_bottom").visible = false;
	_world.interface.get_node("cursor").visible = false;
	if win:
		_world.interface.get_node("win").visible = true;
		$room/win.play();
	else:
		_world.interface.get_node("game_over").visible = true;
		$room/game_over.play();
	_world.interface.get_node("background").visible = true;
	mode = 3;
