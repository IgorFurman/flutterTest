import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserPanel extends StatefulWidget {
  final String userId;
  final String token;

  const UserPanel({Key? key, required this.userId, required this.token})
      : super(key: key);

  @override
  _UserPanelState createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  Map<String, dynamic>? userData;

  final _titleController = TextEditingController();
  final _steamReviewController = TextEditingController();
  final _metacriticReviewController = TextEditingController();
  final _gogLinkController = TextEditingController();
  final _nintendoLinkController = TextEditingController();
  final _ps4LinkController = TextEditingController();
  final _ps5LinkController = TextEditingController();
  final _psVrLinkController = TextEditingController();
  final _steamVrLinkController = TextEditingController();
  final _vrLinkController = TextEditingController();
  final _deckLinkController = TextEditingController();
  final _oneLinkController = TextEditingController();
  final _seriesLinkController = TextEditingController();

  bool _isGogChecked = false;
  bool _isNintendoChecked = false;
  bool _isPs4Checked = false;
  bool _isPs5Checked = false;
  bool _isPsVrChecked = false;
  bool _isSteamVrChecked = false;
  bool _isVrChecked = false;
  bool _isDeckChecked = false;
  bool _isOneChecked = false;
  bool _isSeriesChecked = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL_USER']}/${widget.userId}?populate=*'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        userData = jsonDecode(response.body);
      });
    } else {
      print('Nie udało się pobrać danych użytkownika');
    }
  }

  Future<void> _addProduct() async {
    final adId = userData!['accountType'] == 'developer'
        ? userData!['ad_developer']['id']
        : userData!['ad_company']['id'];
    final requestBody = jsonEncode(<String, dynamic>{
      'data': {
        if (userData!['accountType'] == 'developer') 'ad_developer': adId,
        if (userData!['accountType'] == 'company') 'ad_company': adId,
        'title': _titleController.text,
        'steamReview': _steamReviewController.text,
        'metacriticReview': _metacriticReviewController.text,
        'gog': {
          'gog': _isGogChecked,
          'gog_link': _isGogChecked ? _gogLinkController.text : null,
        },
        'nintendo': {
          'nintendo': _isNintendoChecked,
          'nintendo_link':
              _isNintendoChecked ? _nintendoLinkController.text : null,
        },
        'ps': {
          'ps4': _isPs4Checked,
          'ps4_link': _isPs4Checked ? _ps4LinkController.text : null,
          'ps5': _isPs5Checked,
          'ps5_link': _isPs5Checked ? _ps5LinkController.text : null,
          'ps_vr': _isPsVrChecked,
          'ps_vr_link': _isPsVrChecked ? _psVrLinkController.text : null,
        },
        'steam': {
          'deck': _isDeckChecked,
          'deck_link': _isDeckChecked ? _deckLinkController.text : null,
          'steam_vr': _isSteamVrChecked,
          'steam_vr_link':
              _isSteamVrChecked ? _steamVrLinkController.text : null,
        },
        'VR': {
          'VR': _isVrChecked,
          'VR_link': _isVrChecked ? _vrLinkController.text : null,
        },
        'xbox': {
          'one': _isOneChecked,
          'one_link': _isOneChecked ? _oneLinkController.text : null,
          'series': _isSeriesChecked,
          'series_link': _isSeriesChecked ? _seriesLinkController.text : null,
        },
      }
    });

    print('Request body: $requestBody');

    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL_PRODUCT']}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: requestBody,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('Produkt został dodany pomyślnie');
    } else {
      print('Nie udało się dodać produktu');
    }
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Dodaj produkt'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Tytuł'),
                  ),
                  TextField(
                    controller: _steamReviewController,
                    decoration:
                        const InputDecoration(hintText: 'Recenzja Steam'),
                  ),
                  TextField(
                    controller: _metacriticReviewController,
                    decoration:
                        const InputDecoration(hintText: 'Recenzja Metacritic'),
                  ),
                  const Text('Wybierz platformy:'),
                  CheckboxListTile(
                    title: const Text('GOG'),
                    value: _isGogChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isGogChecked = value!;
                      });
                    },
                  ),
                  if (_isGogChecked)
                    TextField(
                      controller: _gogLinkController,
                      decoration: const InputDecoration(hintText: 'Link GOG'),
                    ),
                  CheckboxListTile(
                    title: const Text('Nintendo'),
                    value: _isNintendoChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isNintendoChecked = value!;
                      });
                    },
                  ),
                  if (_isNintendoChecked)
                    TextField(
                      controller: _nintendoLinkController,
                      decoration:
                          const InputDecoration(hintText: 'Link Nintendo'),
                    ),
                  CheckboxListTile(
                    title: const Text('PS4'),
                    value: _isPs4Checked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPs4Checked = value!;
                      });
                    },
                  ),
                  if (_isPs4Checked)
                    TextField(
                      controller: _ps4LinkController,
                      decoration: const InputDecoration(hintText: 'Link PS4'),
                    ),
                  CheckboxListTile(
                    title: const Text('PS5'),
                    value: _isPs5Checked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPs5Checked = value!;
                      });
                    },
                  ),
                  if (_isPs5Checked)
                    TextField(
                      controller: _ps5LinkController,
                      decoration: const InputDecoration(hintText: 'Link PS5'),
                    ),
                  CheckboxListTile(
                    title: const Text('PS VR'),
                    value: _isPsVrChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPsVrChecked = value!;
                      });
                    },
                  ),
                  if (_isPsVrChecked)
                    TextField(
                      controller: _psVrLinkController,
                      decoration: const InputDecoration(hintText: 'Link PS VR'),
                    ),
                  CheckboxListTile(
                    title: const Text('Steam VR'),
                    value: _isSteamVrChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isSteamVrChecked = value!;
                      });
                    },
                  ),
                  if (_isSteamVrChecked)
                    TextField(
                      controller: _steamVrLinkController,
                      decoration:
                          const InputDecoration(hintText: 'Link Steam VR'),
                    ),
                  CheckboxListTile(
                    title: const Text('VR'),
                    value: _isVrChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isVrChecked = value!;
                      });
                    },
                  ),
                  if (_isVrChecked)
                    TextField(
                      controller: _vrLinkController,
                      decoration: const InputDecoration(hintText: 'Link VR'),
                    ),
                  CheckboxListTile(
                    title: const Text('Deck'),
                    value: _isDeckChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isDeckChecked = value!;
                      });
                    },
                  ),
                  if (_isDeckChecked)
                    TextField(
                      controller: _deckLinkController,
                      decoration: const InputDecoration(hintText: 'Link Deck'),
                    ),
                  CheckboxListTile(
                    title: const Text('Xbox One'),
                    value: _isOneChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isOneChecked = value!;
                      });
                    },
                  ),
                  if (_isOneChecked)
                    TextField(
                      controller: _oneLinkController,
                      decoration:
                          const InputDecoration(hintText: 'Link Xbox One'),
                    ),
                  CheckboxListTile(
                    title: const Text('Xbox Series'),
                    value: _isSeriesChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isSeriesChecked = value!;
                      });
                    },
                  ),
                  if (_isSeriesChecked)
                    TextField(
                      controller: _seriesLinkController,
                      decoration:
                          const InputDecoration(hintText: 'Link Xbox Series'),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Dodaj'),
                onPressed: () {
                  _addProduct();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Anuluj'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel użytkownika'),
      ),
      body: Stack(
        children: [
          userData == null
              ? const CircularProgressIndicator()
              : ListView(
                  children: <Widget>[
                    ListTile(
                      title: const Text('Nazwa użytkownika'),
                      subtitle: Text(userData!['username']),
                    ),
                    ListTile(
                      title: const Text('Email'),
                      subtitle: Text(userData!['email']),
                    ),
                    ListTile(
                      title: const Text('Typ Konta'),
                      subtitle: Text(userData!['accountType']),
                    ),
                    ListTile(
                      title: const Text('Opis'),
                      subtitle: Text(userData!['description']),
                    ),
                    ListTile(
                      title: const Text('Aktywność'),
                      subtitle: Text(userData!['activity'].toString()),
                    ),
                    if (userData!['accountType'] == 'developer' &&
                        userData!['ad_developer'] != null) ...[
                      ListTile(
                        title: const Text('Nick'),
                        subtitle: Text(userData!['ad_developer']['nick']),
                      ),
                      ListTile(
                        title: const Text('Imię'),
                        subtitle: Text(userData!['ad_developer']['firstName']),
                      ),
                      ListTile(
                        title: const Text('Nazwisko'),
                        subtitle: Text(userData!['ad_developer']['lastName']),
                      ),
                      ListTile(
                        title: const Text('Usługi'),
                        subtitle: Text(userData!['ad_developer']['producer']),
                      ),
                    ] else if (userData!['accountType'] == 'company' &&
                        userData!['ad_company'] != null) ...[
                      ListTile(
                        title: const Text('Nazwa firmy'),
                        subtitle: Text(userData!['ad_company']['companyName']),
                      ),
                      ListTile(
                        title: const Text('Liczba subużytkowników'),
                        subtitle: Text(
                          userData!['ad_company']['subUsers'] != null
                              ? userData!['ad_company']['subUsers'].toString()
                              : '0',
                        ),
                      ),
                    ],
                  ],
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => _showAddProductDialog(context),
                child: const Text('Dodaj produkt'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
