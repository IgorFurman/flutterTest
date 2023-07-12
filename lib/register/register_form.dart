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
   final response = await http.post(
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
        if (_accountTypeController.text == 'developer') ...{
          'nick': _nickController.text,
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'producer': _producerController.text,
        } else if (_accountTypeController.text == 'company') ...{
          'companyName': _companyNameController.text,
        },
      }),
    );

    print('status ${response.statusCode}');
    print('odpowiedź ${response.body}');

    if (response.statusCode == 200) {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // Common fields
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
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Hasło'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Proszę wprowadzić hasło';
                }
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
                    child: Text(value == 'developer'
                        ? 'Developer'
                        : 'Firma'), 
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
                decoration: const InputDecoration(labelText: 'Oferowane usługi?'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić producenta';
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
