extends Node2D

var bytes = [];
var leaders = [];
var state = ["A", "B", "C", "D", "E", "F", "G", "H"];
var distance: float = 8192;#7992
var interface;
onready var camera = get_node("camera");
onready var player = get_node("byte");

func _ready():
	$byte.initialization();
	$byte.age = 18;
	$byte.position = Vector2(3394, -8192);
	#альфа-байты девяти племён
	spawn_byte($byte, [null, "Y", "B", "B", Vector2(8192, -3394)]);
	spawn_byte($byte, [null, "Y", "C", "C", Vector2(8192, 3394)]);
	spawn_byte($byte, [null, "Y", "D", "D", Vector2(3394, 8192)]);
	spawn_byte($byte, [null, "Y", "E", "E", Vector2(-3394, 8192)]);
	spawn_byte($byte, [null, "Y", "F", "F", Vector2(-8192, 3394)]);
	spawn_byte($byte, [null, "Y", "G", "G", Vector2(-8192, -3394)]);
	spawn_byte($byte, [null, "Y", "H", "H", Vector2(-3394, -8192)]);
	leaders += bytes;
	#генерация самок и дополнительных байтов для племён под контролем ИИ
	for _byte in leaders:
		spawn_byte($byte, [_byte, "X", _byte.code[1], _byte.code[2], _byte.position]);
		if _byte != $byte:
			spawn_byte($byte, [_byte, "Y", _byte.code[1], _byte.code[2], _byte.position]);
			spawn_byte($byte, [_byte, "X", _byte.code[1], _byte.code[2], _byte.position]);
	$byte.control = true;

	remove_child(camera);
	$byte.add_child(camera);
	camera.custom_viewport = get_parent();

	for _number in range(256):
		var _bit = $bit.duplicate();
		add_child(_bit);
		_bit.position = Vector2(0, distance).rotated(deg2rad(22.5 + 45 * (randi() % 9))) + Vector2(rand_range(-1024, 1024), rand_range(-1024, 1024)) * fmod(distance, 2048);
		_bit.code = "1";
		_bit.initialization();

func _process(delta):
	if distance > 0:
		distance -= delta * 16;
	elif distance < 0:
		distance = 0;

func camera(zoom):
	if zoom and camera.zoom.x > 1:
		camera.zoom /= Vector2(1.2, 1.2);
	elif not zoom and camera.zoom.x < 4:
		camera.zoom *= Vector2(1.2, 1.2);

func spawn_byte(_parent, _data):
	var _byte = _parent.duplicate();
	add_child(_byte);
	_byte.alpha = _data[0];
	_byte.code[0] = _data[1];
	_byte.code[1] = _data[2];
	_byte.code[2] = _data[3];
	_byte.code[3] = str(6 + randi() % 3);
	_byte.code[4] = str(6 + randi() % 3);
	_byte.code[5] = str(6 + randi() % 3);
	_byte.position = _data[4];
	_byte.initialization();
	_byte.age = 18;

func state_update():
	interface.get_node("text_bottom").text = "ПЛЕМЕНА: A";
	for _tribe in state:
		if _tribe != "A":
			interface.get_node("text_bottom").text += ", " + _tribe;
	if state == ["A"]:
		get_parent().get_parent().game_over(true);
	elif state.find("A") == -1:
		get_parent().get_parent().game_over(false);
