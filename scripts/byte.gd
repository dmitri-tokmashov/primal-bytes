extends RigidBody2D
class_name Byte
const phases = [8, 14, 18, 60];#0 - детство, 1 - пубертат, 2 - совершеннолетие, 3 - старость

var _force: Vector2;
#1 символ - пол (Y - мужской, X - женский)
#2 символ - ген Адама, передаётся от отца к сыну
#3 символ - ген Евы, передаётся от матери к дочери
#4 символ - сила
#5 символ - выносливость
#6 символ - ловкость
#3 последних символа - номер поколения
var code: String = "YAA599000";
var seed_code: String;
var alpha: Byte = null;
var target = null;
var age: float = 18;
var stamina: float = int(code[4]) * 5;
var behaviour_mode: int = 1;#0 - атака, 1 - собирательство, 2 - воспроизведение
var fire_mode: int = 0;
var timer: float = 0;
var control: bool = false;
var bites = [];

func _physics_process(delta):
	if visible:
		_force = Vector2.ZERO;
		if control:
			if Input.is_action_pressed("byte_forward"):
				_force.y -= 1024 * int(code[5]) * delta;
			if Input.is_action_pressed("byte_backward"):
				_force.y += 1024 * int(code[5]) * delta;
			if Input.is_action_pressed("byte_left"):
				_force.x -= 1024 * int(code[5]) * delta;
			if Input.is_action_pressed("byte_right"):
				_force.x += 1024 * int(code[5]) * delta;
		else:
			if not is_instance_valid(target):
				if is_instance_valid(alpha) and ((age >= phases[0] and position.distance_squared_to(alpha.position) > 1048576) or (age < phases[0] and position.distance_squared_to(alpha.position) > 16384)):
					target = alpha;
				elif code[0] == "Y" and age >= phases[0]:
					var _distance: float = 4194304;
					var _target = null;
					behaviour_mode = 1;
					for _body in $sensor.get_overlapping_bodies():
						var _body_distance: float = position.distance_squared_to(_body.position);
						#поиск цели для атаки, включение режима атаки при нахождении цели
						if _body.code[0] == "Y" and code[1] != _body.code[1] and stamina >= 25:
							if  behaviour_mode == 2 or _body_distance < _distance:
								_distance = _body_distance;
								_target = _body;
								behaviour_mode = 0;
						#поиск цели для воспроизведения, включение режима воспроизведения при нахождении цели
						elif (behaviour_mode == 1 or behaviour_mode == 2) and _body.code[0] == "X" and age >= phases[1] and age < phases[3] and _body.age >= phases[1] and _body.age < phases[3] and stamina >= 25 and _body_distance < _distance:
								_distance = _body_distance;
								_target = _body;
								behaviour_mode = 2;
					if _target == null:
						_distance = 4194304;
						for _area in $sensor.get_overlapping_areas():
							var _area_distance: float = position.distance_squared_to(_area.position);
							if _area.visible and _area.code[0] == "1" and _area.byte == null and _area_distance < _distance:
								_distance = _area_distance;
								_target = _area;
					if _target != null:
						target = _target;
			else:
				if behaviour_mode == 0:
					if not bites[0].visible:
						fire_bleed(target.position);
					target = null;
				elif behaviour_mode == 1 or target == alpha:
					_force += move(1024 * int(code[5]) * delta);
					if (target != alpha and $sensor.get_overlapping_areas().find(target) == -1) or (target == alpha and ((age >= phases[0] and position.distance_squared_to(alpha.position) <= 1048576) or (age < phases[0] and position.distance_squared_to(alpha.position) <= 16384))):
						target = null;
				#поведение Y-байта в режиме воспроизведения
				elif behaviour_mode == 2:
					if not bites[2].visible:
						if target.stamina > 20 and target.timer == 0:
							fire_seed(target.position);
						elif not bites[1].visible:
							fire_feed(target.position);
					target = null;
		linear_velocity = _force;
		if timer != 0:
			timer -= delta;
			if timer < 0:
				if code[0] == "X":
					$sprite.self_modulate = Color8(255, 85, 255);
					var _byte = duplicate();
					get_parent().add_child(_byte);
					_byte.code = "XY"[randi() % 2] + seed_code[0] + code[2] + (code[3] + seed_code[2])[randi() % 2] + (code[4] + seed_code[3])[randi() % 2] + (code[5] + seed_code[4])[randi() % 2];
					if int(code.substr(code.length() - 3, 3)) > int(seed_code.substr(seed_code.length() - 3, 3)):
						_byte.code += str(int(code.substr(code.length() - 3, 3)) + 1).pad_zeros(3);
					else:
						_byte.code += str(int(seed_code.substr(seed_code.length() - 3, 3)) + 1).pad_zeros(3);
					_byte.alpha = self;
					_byte.initialization();
					if (seed_code[0] == "A" and $sensor.get_overlapping_bodies().find(get_parent().player) != -1):
						$birth.play();
				timer = 0;
		if true:
			age += delta;
			stamina -= delta;
		#отлучка от матери при взрослении, байт начинает следовать за вожаком
		if is_instance_valid(alpha) and age >= phases[0] and alpha.code[0] == "X":
			alpha = alpha.alpha;
			target = null;
			behaviour_mode = 1;
		#обновление возраста и энергии
		if age < phases[2]:
			scale = Vector2.ONE * (0.5 + 0.5 * age / phases[2]);
		if age < 80:
			$age.margin_left = (1 - age / 80) * -32;
			$age.margin_right = -$age.margin_left;
		if stamina > 0:
			$stamina.margin_left = stamina / (int(code[4]) * 5) * -32;
			$stamina.margin_right = -$stamina.margin_left;
		#проверка условий смерти
		if age >= int(code[4]) * 10 or stamina <= 0:
			termination();

func move(_distance):
	var _vector = Vector2.ZERO;
	if target.position.y < position.y:
		_vector.y -= _distance;
	if target.position.y > position.y:
		_vector.y += _distance;
	if target.position.x < position.x:
		_vector.x -= _distance;
	if target.position.x > position.x:
		_vector.x += _distance;
	return _vector;

func fire_bleed(_position):
	stamina -= 10;
	bites[0].position = position;
	bites[0].rotation = position.angle_to_point(_position);
	bites[0].initialization();
	if not control:
		timer = 2;
	if is_instance_valid(get_parent().player) and position.distance_squared_to(get_parent().player.position) <= 4194304:
		$blaster.play();

func fire_feed(_position):
	stamina -= 10;
	bites[1].position = position;
	bites[1].rotation = position.angle_to_point(_position);
	bites[1].initialization();
	if not control:
		timer = 2;
	if is_instance_valid(get_parent().player) and position.distance_squared_to(get_parent().player.position) <= 4194304:
		$blaster.play();

func fire_seed(_position):
	stamina -= 10;
	bites[2].position = position;
	bites[2].rotation = position.angle_to_point(_position);
	bites[2].initialization();
	if not control:
		timer = 2;
	if is_instance_valid(get_parent().player) and position.distance_squared_to(get_parent().player.position) <= 4194304:
		$blaster.play();

func feeding():
	if not control and code[0] == "Y" and stamina >= 25:
		var _stamina: float = 20;
		var _target: Byte = null;
		for _body in $sensor.get_overlapping_bodies():
			if _body.stamina <= _stamina:
				_stamina = _body.stamina;
				_target = _body;
		if is_instance_valid(_target) and not bites[1].visible:
			fire_feed(_target.position);

func initialization():
	if code[0] == "Y":
		$sprite.self_modulate = Color8(85, 255, 255);
	elif code[0] == "X":
		$sprite.self_modulate = Color8(255, 85, 255);
	target = alpha;
	age = 0;
	stamina = int(code[4]) * 5;
	$data.text = code[1];
	for _mode in ["0", "1", "2"]:
		if not (_mode == "0" and code[0] == "X"):
			var _bit = get_parent().get_node("bit").duplicate();
			get_parent().add_child(_bit);
			_bit.byte = self;
			if _mode == "0":
				_bit.code = "0" + code[1];
			elif _mode == "1":
				_bit.code = "1";
			else:
				_bit.code = "2" + code.substr(1, 5) + code.substr(code.length() - 3, 3);
			bites.append(_bit);
	get_parent().bytes.append(self);

func generation():
	return int(code.substr(code.length() - 3, 3));

func termination():
	if alpha == null:
		var _leader = get_parent().leaders;
		var _generation: int = 1000;
		var _alpha: Byte = null;
		for _byte in get_parent().bytes:
			if _byte != self and _byte.code[0] == "Y" and _byte.code[1] == code[1] and _byte.generation() < _generation:
				_generation = _byte.generation();
				_alpha = _byte;
		if is_instance_valid(_alpha):
			_alpha.alpha = null;
			if control:
				remove_child(get_parent().camera);
				_alpha.add_child(get_parent().camera);
				_alpha.control = true;
				get_parent().player = _alpha;
			for _byte in get_parent().bytes:
				if _byte != _alpha and _byte.code[1] == code[1] and _byte.age >= phases[0]:
					_byte.alpha = _alpha;
			get_parent().leaders.append(_alpha);
		else:
			get_parent().state.erase(code[1]);
			get_parent().state_update();
		get_parent().leaders.erase(self);
	get_parent().bytes.erase(self);
	for _bit in bites:
		_bit.queue_free();
	queue_free();
