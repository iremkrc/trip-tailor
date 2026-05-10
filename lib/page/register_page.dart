import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  String? _sex;
  DateTime _selectedDate = DateTime.now();
  bool _acceptedPrivacy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _surnameController,
              decoration: const InputDecoration(labelText: 'Surname'),
            ),
            const SizedBox(height: 10),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Country'),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  showCountryPicker(
                    context: context,
                    onSelect: (Country country) {
                      setState(() {
                        _countryController.text = country.name;
                      });
                    },
                  );
                },
                title: Text(_countryController.text.isEmpty
                    ? 'Select Country'
                    : _countryController.text),
                trailing: const Icon(Icons.arrow_drop_down),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 10),
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                _phoneController.text = number.phoneNumber!;
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DIALOG,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle: const TextStyle(color: Colors.black),
              initialValue: PhoneNumber(isoCode: 'TR'),
              formatInput: true,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              inputDecoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 10),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Birthdate'),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  ).then((pickedDate) {
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _birthdateController.text =
                            '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';
                      });
                    }
                  });
                },
                title: Text(_birthdateController.text.isEmpty
                    ? 'Select Birthdate'
                    : _birthdateController.text),
                trailing: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 10),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Sex'),
              child: DropdownButton<String>(
                value: _sex,
                isExpanded: true,
                underline: Container(),
                hint: const Text('Select Sex'),
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _sex = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text("I accept the Terms and Conditions"),
              value: _acceptedPrivacy,
              onChanged: (bool? value) {
                setState(() {
                  _acceptedPrivacy = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _acceptedPrivacy
                  ? () async {
                      if (_passwordController.text ==
                          _confirmPasswordController.text) {
                        try {
                          final userCredential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          if (userCredential.user != null && mounted) {
                            final userProfile = {
                              'name': _nameController.text,
                              'surname': _surnameController.text,
                              'country': _countryController.text,
                              'city': _cityController.text,
                              'phone': _phoneController.text,
                              'birthdate': _birthdateController.text,
                              'sex': _sex,
                              'closet': [],
                            };
                            final databaseReference =
                                FirebaseDatabase.instance.ref();
                            databaseReference
                                .child('users')
                                .child(userCredential.user!.uid)
                                .set(userProfile);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                          }
                        } on FirebaseAuthException catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text(error.message ?? "Something went wrong"),
                          ));
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(error.toString()),
                          ));
                        }
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Passwords do not match"),
                        ));
                      }
                    }
                  : null,
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
