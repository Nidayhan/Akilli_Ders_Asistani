import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

// Uygulamanın başlangıç sınıfı
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akıllı Ders Asistanı',

      // Uygulamanın genel tasarım ayarları
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FB),
          foregroundColor: Color(0xFF172033),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF172033),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE7EAF2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDC2626)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.8),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFEAECF2)),
          ),
        ),
      ),

      home: const LoginPage(),
    );
  }
}

// Giriş ekranı
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Form doğrulaması için anahtar
  final _formKey = GlobalKey<FormState>();

  // Şifrenin görünür olup olmadığını tutar
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await DatabaseHelper.instance.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta veya şifre hatalı.')),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userId: user['id'] as int,
            email: user['email'] as String,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş sırasında hata oluştu: $e')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEEF1FF), Color(0xFFF5F7FB), Colors.white],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),

                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFEAECF2)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10172033),
                        blurRadius: 28,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Uygulama simgesi
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF0FF),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 38,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Uygulama adı
                        const Text(
                          'Akıllı Ders Asistanı',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172033),
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Öğrenmeyi kolaylaştıran yapay zekâ destekli asistanın.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF697386),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // E-posta başlığı
                        const Text(
                          'E-posta adresi',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 9),

                        // E-posta alanı
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'ornek@email.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'E-posta adresinizi girin.';
                            }

                            final emailPattern = RegExp(
                              r'^[^@]+@[^@]+\.[^@]+$',
                            );

                            if (!emailPattern.hasMatch(value.trim())) {
                              return 'Geçerli bir e-posta adresi girin.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 22),

                        // Şifre başlığı
                        const Text(
                          'Şifre',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 9),

                        // Şifre alanı
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,

                          decoration: InputDecoration(
                            hintText: 'Şifrenizi girin',
                            prefixIcon: const Icon(Icons.lock_outline),

                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),

                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifrenizi girin.';
                            }

                            if (value.length < 8) {
                              return 'Şifre en az 8 karakter olmalıdır.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        // Giriş yap butonu
                        SizedBox(
                          height: 54,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _login,

                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Giriş Yap',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text('Hesabın yok mu? Kayıt Ol'),
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          'Daha verimli öğren, hedeflerine ulaş.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9298A8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseHelper.instance.registerUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().contains('UNIQUE constraint failed')
          ? 'Bu e-posta adresi zaten kayıtlı.'
          : 'Kayıt sırasında bir hata oluştu: $e';

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFEAECF2)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10172033),
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.person_add_alt_1,
                        size: 65,
                        color: Color(0xFF4F46E5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Yeni Hesap Oluştur',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-posta adresi',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'E-posta adresinizi girin.';
                          }

                          final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

                          if (!pattern.hasMatch(value.trim())) {
                            return 'Geçerli bir e-posta girin.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre oluşturun.';
                          }

                          if (value.length < 8) {
                            return 'Şifre en az 8 karakter olmalıdır.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Şifre Tekrar',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifrenizi tekrar girin.';
                          }

                          if (value != _passwordController.text) {
                            return 'Şifreler eşleşmiyor.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _register,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Kayıt Ol',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final int userId;
  final String email;

  const HomePage({super.key, required this.userId, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Akıllı Ders Asistanı',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7068F0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.waving_hand_rounded,
                        color: Color(0xFFFFD166),
                        size: 28,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Merhaba!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Bugün öğrenmeye hazır mısın?',
                        style: TextStyle(
                          color: Color(0xFFE7E6FF),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Çalışma Alanım',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Derslerim',
                  subtitle: 'Derslerini görüntüle ve yönet',
                  color: const Color(0xFF2563EB),
                ),
                _buildMenuCard(
                  icon: Icons.smart_toy_rounded,
                  title: 'Yapay Zekâ Asistanı',
                  subtitle: 'Sorularını yapay zekâya sor',
                  color: const Color(0xFF6D5CE8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(userId: userId),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.note_alt_rounded,
                  title: 'Ders Notlarım',
                  subtitle: 'Notlarını özetle ve test oluştur',
                  color: const Color(0xFF0F9B8E),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotesPage(userId: userId),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Çalışma İstatistiklerim',
                  subtitle: 'Test sonuçlarını ve gelişimini incele',
                  color: const Color(0xFFEA8A20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatisticsPage(userId: userId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    VoidCallback? onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF202A3B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF697386),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: onTap == null
                    ? const Color(0xFFB4BBC8)
                    : const Color(0xFF667085),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatPage extends StatefulWidget {
  final int userId;

  const ChatPage({super.key, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Mesajları tutacağımız liste
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Mesaj yazma alanını kontrol eder
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final history = await DatabaseHelper.instance.getChatHistory(widget.userId);

    if (!mounted) return;

    setState(() {
      _messages.addAll(
        history.map((item) {
          return ChatMessage(
            text: item['message'] as String,
            isUser: item['sender'] == 'user',
          );
        }),
      );
    });
  }

  // Mesaj gönderme fonksiyonu

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();

    if (message.isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _messages.add(ChatMessage(isUser: true, text: message));

      _isLoading = true;
    });

    _controller.clear();

    await DatabaseHelper.instance.saveChat(
      userId: widget.userId,
      message: message,
      sender: 'user',
    );

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5678/webhook/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final reply = data['reply'] ?? 'Yanıt alınamadı.';

        // Yapay zekâ yanıtını veritabanına kaydet
        await DatabaseHelper.instance.saveChat(
          userId: widget.userId,
          message: reply.toString(),
          sender: 'assistant',
        );

        if (!mounted) return;

        // Yanıtı ekranda göster
        setState(() {
          _messages.add(ChatMessage(isUser: false, text: reply.toString()));
        });
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(isUser: false, text: 'Bir hata oluştu: $e'));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yapay Zekâ Asistanı')),
      body: Column(
        children: [
          // Mesajların gösterildiği alan
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFEEF0FF),
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Icon(
                              Icons.smart_toy_rounded,
                              size: 42,
                              color: Color(0xFF5B50D6),
                            ),
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Merhaba! 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172033),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Derslerinle ilgili sorularını sorabilirsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF697386)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final message = _messages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.82,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: message.isUser
                                  ? const Color(0xFF4F46E5)
                                  : Colors.white,
                              border: message.isUser
                                  ? null
                                  : Border.all(color: const Color(0xFFEAECF2)),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                  message.isUser ? 20 : 8,
                                ),
                                topRight: Radius.circular(
                                  message.isUser ? 8 : 20,
                                ),
                                bottomLeft: const Radius.circular(20),
                                bottomRight: const Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: message.isUser
                                    ? Colors.white
                                    : const Color(0xFF273247),
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Mesaj yazma ve gönderme alanı
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Sorunu buraya yaz...',
                        prefixIcon: const Icon(Icons.edit_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: FilledButton(
                      onPressed: _sendMessage,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Icon(Icons.send_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotesPage extends StatefulWidget {
  final int userId;

  const NotesPage({super.key, required this.userId});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;
  String? _summary;
  List<dynamic> _questions = [];
  bool _isQuizLoading = false;

  final Map<int, String> _selectedAnswers = {};
  bool _isQuizSubmitted = false;
  int? _score;
  String? _recommendation;
  bool _isRecommendationLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ders Notlarım')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Notlarını çalışmaya dönüştür',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Notlarını gir, senin için özet ve pratik sorular hazırlayalım.',
                    style: TextStyle(color: Color(0xFF697386), height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _notesController,
                    minLines: 6,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Ders notlarını buraya yaz...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _summarizeNotes,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.summarize_rounded),
                      label: Text(
                        _isLoading
                            ? 'Özet hazırlanıyor...'
                            : 'Notlarımı Özetle',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _isQuizLoading ? null : _generateQuiz,
                      icon: _isQuizLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.quiz_outlined),
                      label: Text(
                        _isQuizLoading
                            ? 'Test hazırlanıyor...'
                            : 'Test Oluştur',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_summary != null || _questions.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_summary != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(_summary!),
                            ),
                          ),

                        if (_questions.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Oluşturulan Test Soruları',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ...List.generate(_questions.length, (index) {
                            final question = _questions[index];
                            final options = Map<String, dynamic>.from(
                              question['options'],
                            );

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${index + 1}. ${question['question']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    RadioGroup<String>(
                                      groupValue: _selectedAnswers[index],
                                      onChanged: (value) {
                                        if (_isQuizSubmitted) return;
                                        setState(() {
                                          _selectedAnswers[index] = value!;
                                        });
                                      },
                                      child: Column(
                                        children: options.entries.map((entry) {
                                          return RadioListTile<String>(
                                            title: Text(
                                              '${entry.key}) ${entry.value}',
                                            ),
                                            value: entry.key,
                                            enabled: !_isQuizSubmitted,
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 16),

                          if (!_isQuizSubmitted)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _submitQuiz,
                                child: const Text('Testi Bitir'),
                              ),
                            ),

                          if (_score != null)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Test Sonucun: $_score / 100',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                          if (_isRecommendationLoading)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            ),

                          if (_recommendation != null)
                            Card(
                              color: Colors.blue.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Yapay Zekâ Çalışma Önerileri',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(_recommendation!),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _summarizeNotes() async {
    final notes = _notesController.text.trim();

    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce ders notlarını gir.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _summary = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5678/webhook/summarize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notes': notes}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _summary = data['summary'] ?? 'Özet alınamadı.';
        });
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _summary = 'Bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitQuiz() async {
    if (_selectedAnswers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm soruları cevapla.')),
      );
      return;
    }

    int correctCount = 0;
    List<Map<String, dynamic>> wrongQuestions = [];

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final selectedAnswer = _selectedAnswers[i];
      final correctAnswer = question['correctAnswer'];

      if (selectedAnswer == correctAnswer) {
        correctCount++;
      } else {
        wrongQuestions.add({
          'question': question['question'],
          'selectedAnswer': selectedAnswer,
          'correctAnswer': correctAnswer,
        });
      }
    }

    final calculatedScore = (correctCount * 100 / _questions.length).round();

    try {
      await DatabaseHelper.instance.saveTestResult(
        userId: widget.userId,
        score: calculatedScore,
        totalQuestions: _questions.length,
        correctAnswers: correctCount,
        wrongAnswers: _questions.length - correctCount,
      );
    } catch (e) {
      debugPrint('Test sonucu kaydedilemedi: $e');
    }

    setState(() {
      _score = calculatedScore;
      _isQuizSubmitted = true;
      _isRecommendationLoading = true;
      _recommendation = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5678/webhook/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'score': calculatedScore,
          'correctCount': correctCount,
          'wrongCount': _questions.length - correctCount,
          'wrongQuestions': wrongQuestions,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _recommendation = data['recommendation'] ?? 'Öneri alınamadı.';
        });
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _recommendation = 'Öneri alınırken hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isRecommendationLoading = false;
      });
    }
  }

  Future<void> _generateQuiz() async {
    final notes = _notesController.text.trim();

    if (notes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Önce ders notlarını gir.')));
      return;
    }

    setState(() {
      _isQuizLoading = true;
      _questions = [];
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5678/webhook/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notes': notes}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          _questions = data['questions'] ?? [];
        });

        if (_questions.isEmpty) {
          throw Exception('Soru oluşturulamadı.');
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isQuizLoading = false;
        });
      }
    }
  }
}
  class StatisticsPage extends StatefulWidget {
    final int userId;

    const StatisticsPage({super.key, required this.userId});

    @override
    State<StatisticsPage> createState() => _StatisticsPageState();
  }


  class _StatisticsPageState extends State<StatisticsPage> {
    late Future<List<Map<String, dynamic>>> _resultsFuture;

    @override
    void initState() {
      super.initState();
      _resultsFuture =
          DatabaseHelper.instance.getTestResults(widget.userId);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Çalışma İstatistiklerim'),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _resultsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('İstatistikler yüklenirken hata oluştu.'),
              );
            }

            final results = snapshot.data ?? [];

            if (results.isEmpty) {
              return const Center(
                child: Text(
                  'Henüz tamamlanmış bir testin bulunmuyor.',
                  textAlign: TextAlign.center,
                ),
              );
            }

            final totalQuestions = results.fold<int>(
              0,
              (sum, item) => sum + (item['total_questions'] as int),
            );

            final totalCorrect = results.fold<int>(
              0,
              (sum, item) => sum + (item['correct_answers'] as int),
            );

            final totalWrong = results.fold<int>(
              0,
              (sum, item) => sum + (item['wrong_answers'] as int),
            );

            final averageScore = results.fold<int>(
                  0,
                  (sum, item) => sum + (item['score'] as int),
                ) /
                results.length;

            final successRate = totalQuestions == 0
                ? 0.0
                : (totalCorrect / totalQuestions) * 100;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _statCard(
                  'Tamamlanan Test',
                  '${results.length}',
                  Icons.assignment_turned_in_rounded,
                ),
                _statCard(
                  'Ortalama Puan',
                  averageScore.toStringAsFixed(1),
                  Icons.bar_chart_rounded,
                ),
                _statCard(
                  'Genel Başarı Oranı',
                  '%${successRate.toStringAsFixed(1)}',
                  Icons.trending_up_rounded,
                ),
                _statCard(
                  'Doğru Cevap',
                  '$totalCorrect',
                  Icons.check_circle_outline,
                ),
                _statCard(
                  'Yanlış Cevap',
                  '$totalWrong',
                  Icons.cancel_outlined,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Son Test Sonuçlarım',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...results.map((result) {
                  final date = DateTime.parse(
                    result['created_at'] as String,
                  ).toLocal();

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.quiz_outlined),
                      title: Text(
                        'Puan: ${result['score']}',
                      ),
                      subtitle: Text(
                        '${result['correct_answers']} doğru / '
                        '${result['wrong_answers']} yanlış',
                      ),
                      trailing: Text(
                        '${date.day}.${date.month}.${date.year}',
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      );
    }

    Widget _statCard(String title, String value, IconData icon) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(icon, size: 28),
          title: Text(title),
          trailing: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }


