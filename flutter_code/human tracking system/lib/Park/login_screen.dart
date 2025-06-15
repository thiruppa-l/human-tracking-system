import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkdup/parking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _autoLoginEnabled = false;
  bool isAdmin = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAutoLoginStatus();
  }

  Future<void> _checkAutoLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool autoLoginEnabled = prefs.getBool('auto_login_enabled') ?? false;
    setState(() {
      _autoLoginEnabled = autoLoginEnabled;
    });

    if (_autoLoginEnabled) {
      String? email = prefs.getString('email');
      String? password = prefs.getString('password');

      if (email != null && password != null) {
        _emailController.text = email;
        _passwordController.text = password;
        await _login();
      }
    }

    // Add a delay of 1 second before checking user authentication
    Future.delayed(Duration(seconds: 0), () {
      _checkUserAuthentication();
    });
  }

  void _checkUserAuthentication() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // User is already authenticated, navigate to the main page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CarParkingApp()),
      );
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show the loading animation
        setState(() {
          _isLoading = true;
        });

        final UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final User? user = userCredential.user;
        _storeLoginCredentials();

        // Navigate after successful login
        if (isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin_panel');
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CarParkingApp()),
          );
        }
      } catch (e) {
        if (e is FirebaseAuthException) {
          // Show a snackbar with the error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message!),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Hide the loading animation
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _storeLoginCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', _emailController.text.trim());
    prefs.setString('password', _passwordController.text.trim());
    prefs.setBool('auto_login_enabled', _autoLoginEnabled);
  }

  Future<bool> _onWillPop() async {
    // Show the exit confirmation dialog
    bool shouldExit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text('Do you want to exit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    // Close the application if the user pressed "Yes"
    if (shouldExit == true) {
      SystemNavigator.pop();
    }

    // Return false to prevent the default behavior (pop the route)
    return false;
  }

  // Function to send a password reset email
  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // Show success message using SnackBar with green color
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset email sent. Check your email inbox.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Show error message using SnackBar with red color
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message!,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 30.0),
                  Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Wrap Lottie widget inside a ClipRRect for smoother appearance
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Lottie.asset(
                      'assets/your_animation.json',
                      height: 300.0,
                      // You can adjust other Lottie options as needed
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.blue,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters long';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Navigate to the ForgotPasswordScreen
                              _resetPassword();
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.0),
                        _isLoading
                            ? SpinKitFadingCircle(
                          color: Colors.blue, // Set the loading indicator color
                          size: 50.0,
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              primary:
                              Colors.blue, // Set the button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal:
                                32.0, // Increase horizontal padding
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            'Create a new account',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16.0,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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
