import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _isLoading = true);
    final success = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).login(_usernameController.text, _passwordController.text);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login to PeerLink',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            CustomTextField(
              label: 'Username',
              controller: _usernameController,
              errorText:
                  authProvider.error!.contains('username')
                      ? authProvider.error
                      : null,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: true,
              errorText:
                  authProvider.error!.contains('password')
                      ? authProvider.error
                      : null,
            ),
            SizedBox(height: 24),
            CustomButton(
              text: 'Login',
              onPressed: _login,
              isLoading: _isLoading,
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('First time? Sign up here'),
            ),
          ],
        ),
      ),
    );
  }
}
