extends MeshInstance3D

#var varis_noktasi = Vector3((randf() * 110)-55, 1, (randf() * 110)-55)
var varis_noktasi = Vector3(30, 1, 40)
const SPEED = 25
var varildi_mi = false
#                         z  x  w  h
var yasakli_bolge = Rect2(10, 10, 20, 20)

# not: Godot'un Rect2.intersects fonksiyonu yokmuş gibi varsayalım...
func doğru_ve_dörtgen(n1, n2, dörtgen):
	var n3 = Vector2(dörtgen.position.x, dörtgen.position.y)
	var n4 = Vector2(dörtgen.position.x + dörtgen.size.x, dörtgen.position.y)
	var n5 = Vector2(dörtgen.position.x, dörtgen.position.y + dörtgen.size.y)
	var n6 = Vector2(dörtgen.position.x + dörtgen.size.x, dörtgen.position.y + dörtgen.size.y)
	if iki_nokta_kesişimi(n1, n2, n3, n4):
		return true
	if iki_nokta_kesişimi(n1, n2, n5, n6):
		return true
	return false

func iki_nokta_kesişimi(n1, n2, n3, n4):
	# Buradaki çözüm yolu ikişer noktadan geçen iki doğrunun kesiştiğini varsayıp
	# çelişki aramak
	# Bunun için ilk önce ikisinin de doğru denklemlerini buluyoruz (y = mx+n gibi)
	# (y2 - y1)/(x2 - x1) = (y - y2)/(x - x2) formülünü kullanarak yapıyorum (alt satırlarda bayağı değiştirdim)
	# y2 - y1 ve x2 -x1'leri karışıklık olmasın diye vektörel çıkartıp bileşenlerini
	# kullanıyorum ama aynı şey.
	var fark1 = n2 - n1
	var fark2 = n4 - n3
	# x_1'i ve x'i anlatmak çok zor olurdu, sadece iki tane iki noktadan
	# doğru denklemi bulma denklemi yazdım. Kontrol ettim, doğru olmalı
	var y2ler_farki = n4.y - n2.y
	var a = fark2.x*fark1.y*n2.x - fark1.x*fark2.y*n4.x
	var farklar_çarpımıx = fark1.x*fark2.x
	var x_1 = y2ler_farki + a/farklar_çarpımıx
	var x = (x_1 * fark1.x*fark2.x)/(fark2.x*fark1.y- fark1.x*fark2.y)
	
	# Yukarıda da yazdığım gibi burada kesiştiğini varsayarak elde ettiğimiz noktaların
	# eşit olması gerekiyor
	var y1 = (fark1.y*x - fark1.y*n2.x)/fark1.x + n2.y;
	var y2 = (fark2.y*x - fark2.y*n4.x)/fark2.x + n4.y;
	
	if y1 != y2:
		#print("yler aynı değil aga x = " + str(x))
		return false
	
	if x > min(n1.x, n2.x) and x < max(n1.x, n2.x):
		print("kesişiyor, x: " + str(x))
		return true
	#print("kesişmiyor: " + str(x) + " hmm: " + str(max(n1.x, n2.x)))
	return false

func varis_noktasi_ayarla():
	varis_noktasi = Vector3((randf() * 110)-55, 1, (randf() * 110)-55)
	#var ino = get_parent().get_node("isaret")
	#if ino != null:
	#	get_parent().remove_child(ino)
	const isaret_sahne = preload("res://ObjectScenes/isaret.tscn")
	var isaret = isaret_sahne.instantiate()
	isaret.set_name("isaret")
	isaret.position = varis_noktasi + Vector3(0, 15, 0)
	get_parent().call_deferred("add_child", isaret)
	var n1 = Vector2(global_position.z, global_position.x)
	var n2 = Vector2(varis_noktasi.z, varis_noktasi.x)
	if doğru_ve_dörtgen(n1, n2, yasakli_bolge):
		print("HAYIIIIR")

func yasak_ayarla():
	const yasakli_sahne = preload("res://ObjectScenes/yasakli.tscn")
	var yasakli = yasakli_sahne.instantiate()
	yasakli.set_name("yasakli")
	yasakli.position.x = yasakli_bolge.position.y
	yasakli.position.z = yasakli_bolge.position.x
	yasakli.position.y = 0
	yasakli.scale.x = yasakli_bolge.size.y
	yasakli.scale.z = yasakli_bolge.size.x
	yasakli.scale.y = 10
	get_parent().call_deferred("add_child", yasakli)
	print("eklendi")
	

func look_here(vec):
	var fark = vec - global_position
	# Aracın varış noktasına bakması gereken açıyı hesapla
	var aci = atan2(fark.z, fark.x)
	# Açıyı dereceye çevir
	var aci_derece = -rad_to_deg(aci)
	# Aracı açıya göre döndür
	rotation_degrees.y = aci_derece

# Called when the node enters the scene tree for the first time.
func _ready():
	yasak_ayarla()
	varis_noktasi_ayarla()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_here(varis_noktasi)
	if abs(global_position.x - varis_noktasi.x) < 0.2 and abs(global_position.z - varis_noktasi.z) < 0.2:
		varis_noktasi_ayarla()
	if !varildi_mi:
		translate_object_local(Vector3(delta * SPEED, 0, 0))
