import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredUsername = '';
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }

    _form.currentState!.save();

    final email = _enteredEmail.trim();
    final password = _enteredPassword;

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        // Sign up
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        final user = response.user;

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Check your email to verify account',
              ),
            ),
          );
          setState(() => _isAuthenticating = false);
          return;
        }
        print('current user id: ${user.id}');

        // Upload avatar after signup

        final res = await supabase.storage
            .from('avatars')
            .upload(
              '${user.id}/avatar.jpg',
              _selectedImage!,
              fileOptions: const FileOptions(upsert: true),
            );

        final avatarPath = '${user.id}/avatar.jpg';

        // Insert User Profile
        await supabase.from('profiles').insert({
          'id': user.id,
          'username': _enteredUsername,
          'avatar_path': avatarPath,
        });

        print('signup+upload response: $res');
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.secondary,

      body: Padding(
        padding: const EdgeInsets.all(2),

        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin
                        ? "Welcome Back!"
                        : "Create Account",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _isLogin
                        ? "Login to continue chatting"
                        : "Sign up to get started",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Card(
                    margin: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_isLogin)
                                UserImagePicker(
                                  onPickImage:
                                      (pickedImage) {
                                        _selectedImage =
                                            pickedImage;
                                      },
                                ),
                              const SizedBox(height: 12),
                              if (!_isLogin)
                                TextFormField(
                                  decoration:
                                      const InputDecoration(
                                        labelText:
                                            'Username',
                                      ),
                                  enableSuggestions: false,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value
                                                .trim()
                                                .length <
                                            4) {
                                      return 'Please enter a valid Username.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _enteredUsername =
                                        value!;
                                  },
                                ),
                              const SizedBox(height: 20),
                              TextFormField(
                                decoration:
                                    const InputDecoration(
                                      labelText:
                                          'Email Address',
                                    ),
                                keyboardType: TextInputType
                                    .emailAddress,
                                autocorrect: false,
                                textCapitalization:
                                    TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value
                                          .trim()
                                          .isEmpty ||
                                      !value.contains(
                                        '@',
                                      )) {
                                    return 'Please enter a valid email address.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredEmail = value!;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                decoration:
                                    const InputDecoration(
                                      labelText: 'Password',
                                    ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length <
                                          6) {
                                    return 'Password must be at least 6 character long.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _enteredPassword =
                                      newValue!;
                                },
                              ),
                              const SizedBox(height: 16),
                              if (_isAuthenticating)
                                const CircularProgressIndicator(),
                              if (!_isAuthenticating)
                                ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                  ),
                                  child: Text(
                                    _isLogin
                                        ? 'Login'
                                        : 'Signup',
                                  ),
                                ),
                              if (!_isAuthenticating)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(
                                    _isLogin
                                        ? 'Create an account'
                                        : 'I already have an account.',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
