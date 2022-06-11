// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/modeller/kullanici.dart';
import 'package:socialmedia/servisler/firestoreServisi.dart';
import 'package:socialmedia/servisler/storagesevisi.dart';
import 'package:socialmedia/servisler/yetkilendirmeServisi.dart';

class ProfiliDuzenle extends StatefulWidget {
  final Kullanici? profil;
  const ProfiliDuzenle({Key? key, required this.profil}) : super(key: key);

  @override
  State<ProfiliDuzenle> createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  var _formKey = GlobalKey<FormState>();
  String? _kullaniciAdi;
  String? _hakkinda;
  File? _secilmisFoto;
  bool _yukleniyor = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "profili düzenle",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: Colors.black,
            )),
        actions: <Widget>[
          IconButton(
              onPressed: _kaydet,
              icon: Icon(
                Icons.check,
                color: Colors.black,
              )),
        ],
      ),
      body: ListView(
        children: <Widget>[
          _yukleniyor == false
              ? SizedBox(
                  height: 0.0,
                )
              : LinearProgressIndicator(),
          _profilFoto(),
          _kullaniciBilgileri(),
        ],
      ),
    );
  }

  _profilFoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: Center(
        //circleavatarı center içine aldık çünkü fotograf bozuk bir şekilde çıkıyordu onu düzeltmiş olduk
        child: InkWell(
          onTap: _galeridenSec,
          child: _fotoUrlKontrol(),
        ),
      ),
    );
  }

  CircleAvatar _fotoUrlKontrol() {
    if (_secilmisFoto == null) {
      return CircleAvatar(
        backgroundColor: Colors.green,
        backgroundImage: NetworkImage(widget.profil!.fotoUrl),
        radius: 55.0,
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.green,
        backgroundImage: FileImage(_secilmisFoto!),
        radius: 55.0,
      );
    }
  }

  _galeridenSec() async {
    var image = await ImagePicker().getImage(
      source: ImageSource.gallery,
      //source ile fotografı hangi kaynaktan getirecegimizi söyleriz
      maxWidth: 800, //yuknenecek fotonun max eni
      maxHeight: 600, //yuknenecek fotonun max yuksekigi
      imageQuality: 80, //dosya boyutunu azaltmak için resim kalitesini düşürür.
    );
    setState(() {
      _secilmisFoto = File(image!.path);
      //yuklenen resmin yolu sadece stringdi file yapıcısına göndererek bir dosya objesi oluşturururz
    });
  }

  _kaydet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _yukleniyor = true;
      });

      _formKey.currentState!.save();

      String? profilFotoUrl;
      if (_secilmisFoto == null) {
        profilFotoUrl = widget.profil!.fotoUrl;
      } else {
        profilFotoUrl = await StorageServisi().profilResmiYukle(_secilmisFoto!);
      }

      String? aktifkulllaniciid =
          Provider.of<yetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      firestoreServisi().kullaniciGuncelle(
          kullaniciId: aktifkulllaniciid,
          hakkinda: _hakkinda,
          kullaniciAdi: _kullaniciAdi,
          fotoUrl: profilFotoUrl);
    }
    setState(() {
      _yukleniyor = false;
    });
    Navigator.pop(context);
  }

  _kullaniciBilgileri() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
              initialValue: widget.profil!.kullaniciAdi,
              //initialValue: text alanlarına başlangiç degerleri verir.
              decoration: InputDecoration(labelText: "Kullanıcı Adı"),
              validator: (girilenDeger) {
                return girilenDeger!.trim().length <= 3
                    ? "Kullanıcı adı en az 4 karakter olmalı"
                    : null;
              },
              onSaved: (girilenDeger) {
                _kullaniciAdi = girilenDeger;
              },
            ),
            TextFormField(
              initialValue: widget.profil!.hakkinda,
              //initialValue: text alanlarına başlangiç degerleri verir.
              decoration: InputDecoration(labelText: "Hakkında"),
              validator: (girilenDeger) {
                return girilenDeger!.trim().length > 100
                    ? "100 Karakterden fazla olmamalı"
                    : null;
              },
              onSaved: (girilenDeger) {
                _hakkinda = girilenDeger;
              },
            ),
          ],
        ),
      ),
    );
  }
}
