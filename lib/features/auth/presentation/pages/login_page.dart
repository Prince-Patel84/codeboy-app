import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../../core/constants/api_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _handleController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final handle = _handleController.text.trim();
    if (handle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Codeforces handle')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate handle via our server to avoid CORS issues on Web
      final dio = Dio();
      await dio.get('${ApiConstants.baseUrl}/student/$handle');
      
      // If we reach here, the handle is valid.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cf_handle', handle);

      if (!mounted) return;
      
      // Navigate to home and flush the navigator stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
      );
    } on DioException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Codeforces handle or network error.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving handle: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _handleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.code,
                size: 100,
                color: Colors.deepPurpleAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to CodeBoy',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your personalized competitive programming coach.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 350,
                child: TextField(
                  controller: _handleController,
                  decoration: const InputDecoration(
                    labelText: 'Codeforces Handle',
                    hintText: 'e.g. tourist, Prince_Patel84',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onSubmitted: (_) => _login(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 350,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Start Practicing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
