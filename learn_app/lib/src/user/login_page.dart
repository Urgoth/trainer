import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:learn_app/src/home_page.dart';
import 'package:learn_app_backend/pocketbase.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Login Page',
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late String email;
  late String password;

  final _loginFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email:'),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final validator = Validator(
                    validators: [
                      const EmailValidator(),
                      const RequiredValidator(),
                    ],
                  );
                  return validator.validate(label: 'Email', value: value);
                },
                onSaved: (newValue) {
                  email = newValue!;
                },
              ),
            ),
            const Text('Password:'),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  final validator = Validator(
                    validators: [
                      const MinLengthValidator(length: 8),
                      const RequiredValidator(),
                    ],
                  );
                  return validator.validate(label: 'Password', value: value);
                },
                onSaved: (newValue) {
                  password = newValue!;
                },
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Theme.of(context).colorScheme.primary),
                  foregroundColor: MaterialStateColor.resolveWith(
                      (states) => Theme.of(context).colorScheme.onPrimary),
                ),
                onPressed: () async {
                  DataBaseHandler.logout();
                  if (_loginFormKey.currentState!.validate()) {
                    _loginFormKey.currentState!.save();

                    await DataBaseHandler.login(email, password).then((value) {
                      if (value.$1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      } else {
                        _showSnackBarTop(context, value.$2);
                      }
                    });
                  }
                },
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showSnackBarTop(BuildContext context, String message) {
    SnackBar snackBar = SnackBar(
      content: Text(message, style: const TextStyle(fontSize: 20)),
      backgroundColor: Colors.indigo,
      dismissDirection: DismissDirection.up,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 10,
          right: 10),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
