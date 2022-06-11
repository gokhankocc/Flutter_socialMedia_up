// ignore_for_file: implementation_imports, unnecessary_import, prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_interpolation_to_compose_strings, prefer_final_fields, unused_field, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/modeller/gonderi.dart';
import 'package:socialmedia/modeller/kullanici.dart';
import 'package:socialmedia/sayfalar/yorumlar.dart';
import 'package:socialmedia/servisler/firestoreServisi.dart';
import 'package:socialmedia/servisler/yetkilendirmeServisi.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;
  const GonderiKarti(
      {Key? key, required this.gonderi, required this.yayinlayan})
      : super(key: key);

  @override
  State<GonderiKarti> createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begenisayisi = 0;
  bool _begendin = false;
  String? _aktifKullaniciId;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _begenisayisi = widget.gonderi.begeniSayisi!;
    _aktifKullaniciId =
        Provider.of<yetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    begenivarmi();
  }

  begenivarmi() async {
    bool begeniVermi = await firestoreServisi()
        .begeniVarmi(widget.gonderi, _aktifKullaniciId!);
    if (begeniVermi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _begendin = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          _gonderiBasligi(),
          _gonderiResmi(),
          _gonderiAlt(),
        ],
      ),
    );
  }

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.blue,
          backgroundImage: NetworkImage(widget.yayinlayan.fotoUrl),
        ),
      ),
      title: Text(
        widget.yayinlayan.kullaniciAdi,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
      contentPadding: EdgeInsets.all(
          0.0), //list tile ın kendi paddingini devre dışı bıraktık
    );
  }

  Widget _gonderiResmi() {
    return GestureDetector(
      onDoubleTap: _begenidegistir,
      child: Image.network(
        widget.gonderi.gonderiResmiUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, //texti başa sabitlemek için kullandık
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start, //başa sabitledik
          children: <Widget>[
            IconButton(
                onPressed: () {
                  _begenidegistir();
                },
                icon: !_begendin
                    ? Icon(
                        Icons.favorite_border,
                        size: 35.0,
                      )
                    : Icon(
                        Icons.favorite,
                        size: 35.0,
                        color: Colors.red,
                      )),
            IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Yorumlar(
                              gonderi: widget.gonderi,
                            )),
                    (route) => true,
                  );
                },
                icon: Icon(
                  Icons.comment,
                  size: 35.0,
                ))
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "$_begenisayisi Beğeni",
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        widget.gonderi.aciklama!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RichText(
                  text: TextSpan(
                    text: widget.yayinlayan.kullaniciAdi + " ",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                        text: widget.gonderi.aciklama,
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      )
                    ],
                  ),
                ),
                //RichText : birden çok yazı sitili kullanmak için
              )
            : SizedBox(
                width: 0.0,
              ),
      ],
    );
  }

  void _begenidegistir() {
    if (_begendin) {
      // kullanıcı gönderiyi begenmiş durumda bu nedenle gönderideki begeniyi kaldıracak kodları çalıştırmamamız gerekecek
      setState(() {
        _begendin = false;
        _begenisayisi -= 1;
      });
      firestoreServisi()
          .gonderiBegenikaldir(widget.gonderi, _aktifKullaniciId!);
    } else {
      //kullanıcı gönderiyi begenmemiş durumda bu nedenle begeniyi aktifleştirecek kodları yazmamız lazım.
      setState(() {
        _begendin = true;
        _begenisayisi += 1;
      });
      firestoreServisi().gonderiBegen(widget.gonderi, _aktifKullaniciId!);
    }
  }
}
