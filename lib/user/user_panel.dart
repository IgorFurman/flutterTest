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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL_USER']}/${widget.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userData = jsonDecode(response.body);
      });
    } else {
      print('Nie udało się pobrać danych użytkownika');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel użytkownika'),
      ),
      body: userData == null
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
                    title: const Text('Company Name'),
                    subtitle: Text(userData!['ad_company']['companyName']),
                  ),
                  ListTile(
                    title: const Text('Sub Users'),
                    subtitle:
                        Text(userData!['ad_company']['subUsers'].toString()),
                  ),
                ],
              ],
            ),
    );
  }
}
