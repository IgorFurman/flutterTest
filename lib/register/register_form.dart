import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _accountTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nickController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _producerController = TextEditingController();
  final _companyNameController = TextEditingController();

  Future<void> _register() async {
    final userResponse = await http.post(
      Uri.parse(dotenv.env['API_URL_REG']!),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${dotenv.env['BEARER_TOKEN']}',
      },
      body: jsonEncode(<String, dynamic>{
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'accountType': _accountTypeController.text,
        'description': _descriptionController.text,
      }),
    );

    if (userResponse.statusCode == 200) {
      final user = jsonDecode(userResponse.body);
      print('userId: $user');
      if (_accountTypeController.text == 'developer') {
        print('Sending with userId: $user');
        final developerResponse = await http.post(
          Uri.parse(dotenv.env['API_URL_DEV']!),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${dotenv.env['BEARER_TOKEN']}',
          },
          body: jsonEncode(<String, dynamic>{
            'data': {
              'nick': _nickController.text,
              'firstName': _firstNameController.text,
              'lastName': _lastNameController.text,
              'producer': _producerController.text,
              'user': user['user']['id'],
            },
          }),
        );

        print('status ${developerResponse.statusCode}');
        print('odpowiedź ${developerResponse.body}');
        print('użytkownik nr ${user['user']['id']}');
      } else if (_accountTypeController.text == 'company') {
        final companyResponse = await http.post(
          Uri.parse(dotenv.env['API_URL_COMP']!),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${dotenv.env['BEARER_TOKEN']}',
          },
          body: jsonEncode(<String, dynamic>{
            'data': {
              'companyName': _companyNameController.text,
              'user': user['user']['id'],
            },
          }),
        );

        print('status ${companyResponse.statusCode}');
        print('odpowiedź ${companyResponse.body}');
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sukces'),
            content: const Text('Rejestracja zakończona sukcesem'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      print('status ${userResponse.statusCode}');
      print('odpowiedź ${userResponse.body}');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Błąd'),
            content: const Text('Rejestracja nie powiodła się'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _accountTypeController.dispose();
    _descriptionController.dispose();
    _nickController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _producerController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
      
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nazwa użytkownika'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Proszę wprowadzić nazwę użytkownika';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Proszę wprowadzić adres email';
                }

                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                RegExp regex = RegExp(pattern);
                if (!regex.hasMatch(value))
                  return 'Wprowadź prawidłowy adres email';
                else
                  return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Hasło'),
              obscureText: true, 
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Proszę wprowadzić hasło';
                }
                String pattern =
                    r'^(?=.*[0-9]+.*)(?=.*[a-zA-Z]+.*)[0-9a-zA-Z]{8,}$';

                RegExp regex = RegExp(pattern);
                if (!regex.hasMatch(value))
                  return 'Hasło musi zawierać przynajmniej 8 znaków, w tym przynajmniej jedną dużą literę, jedną małą literę i jedną cyfrę';
                else
                  return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Twój opis'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Proszę wprowadzić opis';
                }
                return null;
              },
            ),
            ListTile(
              title: const Text('Typ konta:'),
              trailing: DropdownButton<String>(
                value: _accountTypeController.text.isEmpty
                    ? null
                    : _accountTypeController.text,
                items: <String>['developer', 'company'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'developer' ? 'Developer' : 'Firma'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _accountTypeController.text = newValue!;
                  });
                },
              ),
            ),
            if (_accountTypeController.text == 'developer') ...[
              TextFormField(
                controller: _nickController,
                decoration: const InputDecoration(labelText: 'Nick'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić nick';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Imię'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić imię';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nazwisko'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić nazwisko';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _producerController,
                decoration:
                    const InputDecoration(labelText: 'Oferowane usługi?'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić oferowane usługi';
                  }
                  return null;
                },
              ),
            ] else if (_accountTypeController.text == 'company') ...[
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Nazwa firmy'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić nazwę firmy';
                  }
                  return null;
                },
              ),
            ],
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  _register();
                }
              },
              child: const Text('Zarejestruj się'),
            ),
          ],
        ),
      ),
    );
  }
}
