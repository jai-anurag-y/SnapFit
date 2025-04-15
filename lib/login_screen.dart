import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  
  // Error message variables for each field
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Reset all error messages
  void _resetErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });
  }

  Future<void> _login() async {
    // Reset previous errors
    _resetErrors();
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        //First check if user exists in Firestore
        // final usersSnapshot = await FirebaseFirestore.instance
        //     .collection('users')
        //     .where('email', isEqualTo: _emailController.text.trim())
        //     .get();

        // if (usersSnapshot.docs.isEmpty) {
        //   setState(() {
        //     _emailError = 'No account found with this email';
        //     _isLoading = false;
        //   });
        //   return;
        // }

        // If user exists in Firestore, try to authenticate with Firebase Auth
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        // No need to navigate - AuthenticationWrapper will handle it
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          
          if (e.code == 'user-not-found') {
            _emailError = 'No account found with this email';
          } else if (e.code == 'wrong-password') {
            _passwordError = 'Incorrect password';
          } else if (e.code == 'invalid-email') {
            _emailError = 'Invalid email format';
          } else if (e.code == 'user-disabled') {
            _emailError = 'This account has been disabled';
          } else if (e.code == 'too-many-requests') {
            _generalError = 'Too many attempts. Try again later';
          } else {
            _generalError = e.message ?? 'Authentication failed';
          }
        });
      } catch (e) {
        print("Unexpected error: $e"); // Log the error
        setState(() {
          _generalError = 'An unexpected error occurred';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo or icon
                  Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'SnappyFit',
                    style: GoogleFonts.raleway(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Email field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.email, color: Colors.white70),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        errorStyle: const TextStyle(height: 0), // Hide the default error
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() => _emailError = 'Please enter your email');
                          return ''; // Return empty string to trigger error state but show our custom error
                        }
                        if (!value.contains('@')) {
                          setState(() => _emailError = 'Please enter a valid email');
                          return '';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  // Custom email error message
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        _emailError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    
                  const SizedBox(height: 16),
                  
                  // Password field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.lock, color: Colors.white70),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        errorStyle: const TextStyle(height: 0), // Hide the default error
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() => _passwordError = 'Please enter your password');
                          return '';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  // Custom password error message
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        _passwordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    
                  const SizedBox(height: 24),
                  
                  // General error message
                  if (_generalError != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300)
                      ),
                      child: Text(
                        _generalError!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                  if (_generalError != null) const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _navigateToSignup,
                    child: const Text(
                      'Don\'t have an account? Sign Up',
                      style: TextStyle(color: Colors.white),
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

// Sign Up Screen
class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _heightError;
  String? _weightError;
  String? _generalError;
  
  String _selectedGender = 'Male';
  List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _resetErrors() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _heightError = null;
      _weightError = null;
      _generalError = null;
    });
  }

  Future<void> _signup() async {
    _resetErrors();
    
    if (_formKey.currentState!.validate()) {
      // Additional validation for password match
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _confirmPasswordError = 'Passwords do not match';
        });
        return;
      }
      
      setState(() {
        _isLoading = true;
      });

      try {
        // First check if email already exists in Firestore
        final usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _emailController.text.trim())
            .get();

        if (usersSnapshot.docs.isNotEmpty) {
          setState(() {
            _emailError = 'Email already in use';
            _isLoading = false;
          });
          return;
        }

        // Create the user in Firebase Auth
        final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        // Store additional user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'gender': _selectedGender,
          'height': double.tryParse(_heightController.text) ?? 0,
          'weight': double.tryParse(_weightController.text) ?? 0,
          'createdAt': FieldValue.serverTimestamp(),
          // Initial fitness settings
          'dailyTargets': {
            'Protein': 150,
            'Carbohydrates': 250,
            'Fat': 70,
          },
        });
        
        // Navigate back to login (AuthenticationWrapper will handle redirection)
        Navigator.pop(context);
        
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          
          if (e.code == 'email-already-in-use') {
            _emailError = 'Email is already in use';
          } else if (e.code == 'weak-password') {
            _passwordError = 'Password is too weak';
          } else if (e.code == 'invalid-email') {
            _emailError = 'Invalid email format';
          } else {
            _generalError = e.message ?? 'Registration failed';
          }
        });
      } catch (e) {
        setState(() {
          _generalError = 'An unexpected error occurred';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.raleway(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Name field
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    errorText: _nameError,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() => _nameError = 'Please enter your name');
                        return '';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() => _emailError = 'Please enter your email');
                        return '';
                      }
                      if (!value.contains('@')) {
                        setState(() => _emailError = 'Please enter a valid email');
                        return '';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password field
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    togglePasswordVisibility: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                    errorText: _passwordError,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() => _passwordError = 'Please enter a password');
                        return '';
                      }
                      if (value.length < 6) {
                        setState(() => _passwordError = 'Password must be at least 6 characters');
                        return '';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confirm Password field
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isConfirmPasswordVisible,
                    togglePasswordVisibility: () {
                      setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                    },
                    errorText: _confirmPasswordError,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() => _confirmPasswordError = 'Please confirm your password');
                        return '';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Gender dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        dropdownColor: Colors.blue.shade700,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue!;
                          });
                        },
                        items: _genderOptions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  value == 'Male' ? Icons.male : 
                                  value == 'Female' ? Icons.female : Icons.person,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 10),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Height and Weight in a row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _heightController,
                          label: 'Height (cm)',
                          icon: Icons.height,
                          keyboardType: TextInputType.number,
                          errorText: _heightError,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final height = double.tryParse(value);
                              if (height == null || height <= 0) {
                                setState(() => _heightError = 'Invalid height');
                                return '';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _weightController,
                          label: 'Weight (kg)',
                          icon: Icons.monitor_weight,
                          keyboardType: TextInputType.number,
                          errorText: _weightError,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final weight = double.tryParse(value);
                              if (weight == null || weight <= 0) {
                                setState(() => _weightError = 'Invalid weight');
                                return '';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // General error message
                  if (_generalError != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300)
                      ),
                      child: Text(
                        _generalError!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                  if (_generalError != null) const SizedBox(height: 16),
                  
                  // Sign Up button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
                            ),
                          )
                        : const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? togglePasswordVisibility,
    String? errorText,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword && !isPasswordVisible,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.white70),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: togglePasswordVisibility,
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              errorStyle: const TextStyle(height: 0),
            ),
            validator: validator,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}