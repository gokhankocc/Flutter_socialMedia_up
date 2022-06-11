// ignore_for_file: prefer_const_constructors, unused_element, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_final_fields, unused_field, avoid_print, avoid_function_literals_in_foreach_calls, unnecessary_null_comparison, deprecated_member_use, prefer_interpolation_to_compose_strings, unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/modeller/gonderi.dart';
import 'package:socialmedia/modeller/kullanici.dart';
import 'package:socialmedia/sayfalar/profiliduzenle.dart';
import 'package:socialmedia/servisler/firestoreServisi.dart';
import 'package:socialmedia/servisler/yetkilendirmeServisi.dart';
import 'package:socialmedia/widgetlar/gonderikarti.dart';

class Profil extends StatefulWidget {
  final String? profilSahibiId;
  const Profil({Key? key, this.profilSahibiId}) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _gonderiSayisi = 0;
  int _takipci = 0;
  int _takipedilen = 0;
  List<Gonderi> _gonderiler = [];
  String gonderiStili = "liste";
  String? _aktifkullaniciid;
  Kullanici? _profilSahibi;
  bool _takipEdildi = false;

  _takipedilenSayisiGetir() async {
    int? takipedilenSayisi =
        await firestoreServisi().takipEdilenler(widget.profilSahibiId);
    print("takip edilen");
    print(takipedilenSayisi);
    print(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipedilen = takipedilenSayisi;
      });
    }
  }

  _takipciSayisiGetir() async {
    int? takipciSayisi =
        await firestoreServisi().takipciSayisi(widget.profilSahibiId);
    print("takpiCi");
    print(takipciSayisi);
    print(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  _gonderileriGetir() async {
    List<Gonderi> gonderiler =
        await firestoreServisi().gonderileriGetir(widget.profilSahibiId);
    if (mounted) {
      if (mounted) {
        setState(() {
          _gonderiler = gonderiler;
          _gonderiSayisi = _gonderiler.length;
        });
      }
    }
  }

  _takipKontrol() async {
    bool takipVarmi = await firestoreServisi().takipkontrol(
        profilSahibiId: widget.profilSahibiId,
        aktifKullaniciId: _aktifkullaniciid);
    setState(() {
      _takipEdildi = takipVarmi;
    });
  }

  @override
  void initState() {
    super.initState();
    _takipciSayisiGetir();
    _takipedilenSayisiGetir();
    _gonderileriGetir();
    _aktifkullaniciid =
        Provider.of<yetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    _takipKontrol();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil",
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.grey[100],
        actions: <Widget>[
          widget.profilSahibiId == _aktifkullaniciid
              ? IconButton(
                  onPressed: _cikisYap,
                  icon: Icon(Icons.exit_to_app, color: Colors.black))
              : SizedBox(
                  height: 0.0,
                )
        ],
        iconTheme: IconThemeData(color: Colors.brown),
      ),
      body: FutureBuilder<Object?>(
          future: firestoreServisi()
              .kullaniciGetir(widget.profilSahibiId), //profil verisi çekme
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            _profilSahibi = snapshot.data;

            return ListView(
              children: <Widget>[
                _profilDetaylari(snapshot.data),
                _gonderileriGoster(snapshot.data),
              ],
            );
          }),
    );
  }

  /*Widget _gonderileriGoster(Kullanici profilData) {
    List<GridTile> fayanslar = [];
    _gonderiler.forEach((gonderi) {
      fayanslar.add(_fayansOlustur(gonderi));
    });

    return GridView.count(
        //GridView : ızgara gösterimi
        crossAxisCount: 3,
        shrinkWrap: true, //sadece ihtiyacın olan alanı kapla dedik
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0, //fayanslar arası boşluk
        childAspectRatio: 1.0, //ızgaraların en boy oranı
        physics:
            NeverScrollableScrollPhysics(), //fridviewin kaydırma özelliğini kapattık çünkü altta listtile var onda zaten kaydırma özelliği var
        children: fayanslar);
  }

  GridTile _fayansOlustur(Gonderi gonderi) {
    return GridTile(
        //fayans ekler
        child: Image.network(
      gonderi.gonderiResmiUrl.toString(),
      fit: BoxFit.cover,
    ));
  }*/

  Widget _gonderileriGoster(Kullanici profilData) {
    if (gonderiStili == "liste") {
      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: _gonderiler.length,
        itemBuilder: (context, index) {
          return GonderiKarti(
            gonderi: _gonderiler[index],
            yayinlayan: profilData,
          );
        },
      );
    } else {
      List<GridTile> fayanslar = [];
      _gonderiler.forEach((gonderi) {
        fayanslar.add(_fayansOlustur(gonderi));
      });

      return GridView.count(
          //GridView : ızgara gösterimi
          crossAxisCount: 3,
          shrinkWrap: true, //sadece ihtiyacın olan alanı kapla dedik
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0, //fayanslar arası boşluk
          childAspectRatio: 1.0, //ızgaraların en boy oranı
          physics:
              NeverScrollableScrollPhysics(), //fridviewin kaydırma özelliğini kapattık çünkü altta listtile var onda zaten kaydırma özelliği var
          children: fayanslar);
    }
  }

  GridTile _fayansOlustur(Gonderi gonderi) {
    return GridTile(
        //fayans ekler
        child: Image.network(
      gonderi.gonderiResmiUrl.toString(),
      fit: BoxFit.cover,
    ));
  }

  Widget _profilDetaylari(Kullanici profilData) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              profilFotoKontrol(profilData),
              Expanded(
                //row içinde row kullandıgımız için yatayda hizalama yapmadı sadece ihtiyacı olan yeri kullandı hizalama yapması için expended widgetini kullandık
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _sosyalSayac(baslik: "Gönderiler", sayi: _gonderiSayisi),
                    //......................................................................................................
                    FutureBuilder<Object?>(
                        future: firestoreServisi().takipciSayisi(
                            widget.profilSahibiId), //profil verisi çekme
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          return _sosyalSayac(
                              baslik: "Takipçi", sayi: _takipci);
                        }),
                    //...................................
                    FutureBuilder<Object?>(
                        future: firestoreServisi().takipEdilenler(
                            widget.profilSahibiId), //profil verisi çekme
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          return _sosyalSayac(
                              baslik: "Takip", sayi: _takipedilen);
                          //baslik: "Takip", sayi: snapshot.data);
                        }),
                    //_sosyalSayac(baslik: "Takip", sayi: _takipedilen),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(profilData.kullaniciAdi.toString(),
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 5,
          ),
          Text(
            profilData.hakkinda.toString(),
          ),
          SizedBox(
            height: 25,
          ),
          widget.profilSahibiId == _aktifkullaniciid
              ? _profiliDuzenleButon()
              : takipButonu(),
        ],
      ),
    );
  }

  CircleAvatar profilFotoKontrol(Kullanici profilData) {
    if (profilData.fotoUrl.toString() != null) {
      //print("profil foto : " + profilData.fotoUrl.toString());
      return CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 50.0,
        //backgroundImage: AssetImage("assets/images/hayalet.png"),
        //backgroundImage: NetworkImage(profilData.fotoUrl.toString()),
        backgroundImage: NetworkImage(profilData.fotoUrl.toString()),
      );
    } else {
      //print("kotaa1");
      return CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 50.0,
        //backgroundImage: AssetImage("assets/images/hayalet.png"),
        //backgroundImage: NetworkImage(profilData.fotoUrl.toString()),
        backgroundImage: AssetImage("assets/images/hayalet.png"),
      );
    }
  }

  Widget takipButonu() {
    return _takipEdildi == true ? _takiptenCikButonu() : _takipEtButonu();
  }

  Widget _takipEtButonu() {
    return Container(
      width: double.infinity,
      child: FlatButton(
        color: Colors.blue,
        onPressed: () {
          firestoreServisi().takipEt(
            profilSahibiId: widget.profilSahibiId,
            aktifKullaniciId: _aktifkullaniciid,
          );
          setState(() {
            _takipEdildi = true;
            _takipci += 1;
          });
        },
        child: Text(
          "Takip Et",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _takiptenCikButonu() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          firestoreServisi().takiptenCik(
              aktifKullaniciId: _aktifkullaniciid,
              profilSahibiId: widget.profilSahibiId);
          setState(() {
            _takipEdildi = false;
            _takipci -= 1;
          });
        },
        child:
            Text("Takipten Çık", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _profiliDuzenleButon() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfiliDuzenle(
                      profil: _profilSahibi,
                    )),
          );
        },
        child: Text("Profili Düzenle"),
      ),
    );
  }

  Widget _sosyalSayac({String? baslik, int? sayi}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, //dikeyde hizala
      crossAxisAlignment: CrossAxisAlignment.center, //yatayda hizala
      children: <Widget>[
        Text(
          sayi.toString(),
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2.0,
        ),
        Text(
          baslik!,
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
      ],
    );
  }

  void _cikisYap() {
    Provider.of<yetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
