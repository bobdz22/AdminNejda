import 'package:administration_emergency/Data/Services/Auth_Services.dart';
import 'package:administration_emergency/Presentation/Pages/HomePage.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
 
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isRememberme = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String message = '';
  AuthServices authServices = AuthServices();
  List<List<String>> types = [["Assets/Images/75af91bb4cc6fedbd3eb4f254336089c (1).png","الشرطة","الجزائرية","police"],["Assets/Images/images (2) 1.png","الحماية المدنية","الجزائرية","ambulance"],["Assets/Images/images 1.png","الدرك","الجزائرية","gendarmerie"]];
  List<Color> color = [Color(0xff0D3082),Color(0xffFF7C7C),Color(0xff899E8A)];
  int i = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }


  Future<void> _loadSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
 
    bool? rememberedState = prefs.getBool('remember_me');
    String? savedEmail = prefs.getString('saved_email');

    if (rememberedState == true && savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        isRememberme = true;
      });
    }
  }

  
  Future<void> _handleRememberMe(bool? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isRememberme = value ?? false;
    });

    if (isRememberme) {
      // Save email and remember me state
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', _emailController.text);
    } else {
      // Remove saved credentials
      await prefs.remove('remember_me');
      await prefs.remove('saved_email');
    }
  }

  // Handle login process
  Future<void> _handleLogin() async {
  
    setState(() {
      _isLoading = true;
    });

     
      message = await authServices.login(_emailController.text, _passwordController.text);

     Future.delayed(Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });

      if (message == 'success') {
      
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Homepage(color: color[i], Type: types[i][3],)),
          (route) => false,
        );
      } else {
        setState(() {
        _isLoading = false;
      });
     
          _passwordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
              duration: Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        
      }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
 DropdownButton<int>(
              value: i,
              items: List.generate(types.length, (i) {
                return DropdownMenuItem<int>(
                  value: i,
                  child: Row(
                    children: [
                      Image.asset(types[i][0], width: 40, height: 40), // Image
                      SizedBox(width: 10),
                      Text(types[i][1], style: TextStyle(fontSize: 18)), // Name
                    ],
                  ),
                );
              }),
              onChanged: (int? newIndex) {
                setState(() {
                  i = newIndex!;
                });
              },
            ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: color[i],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(types[i][0], width: 60,),
                        Text(types[i][1], style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),),
                        Text(types[i][2], style: TextStyle(color: Colors.white, fontSize: 13),),
                      ],
                    ),
                  ), 
                  SizedBox(height: 120),        
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:70),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible 
                              ? Icons.visibility 
                              : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isRememberme, 
                          onChanged: _handleRememberMe
                        ),
                        Text("Enregistrer logs", style: TextStyle(fontSize: 18),)
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: (){
                      _handleLogin();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 70),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: color[i],
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: _isLoading 
                          ? Center(child: CircularProgressIndicator(color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Connecter", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                Icon(Icons.arrow_back_rounded, color: Colors.white)
                              ],
                            ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
               
                SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height ,
              child: AnotherCarousel(
                images: [
                  AssetImage("Assets/Images/636be49740699250cf29fdfd153dc136.png"),
                  AssetImage("Assets/Images/2025-03-0610_47_38.079301-HIMAYA.webp"),
                  AssetImage("Assets/Images/gendarmerie_nationale_bis_463431075.webp"),
                ],
              autoplay: true,
              animationCurve: Curves.fastOutSlowIn,
              animationDuration: Duration(milliseconds: 800),
              showIndicator: false, 
              ),
            ),
             WindowTitleBarBox(
            child: Row(
              children: [
                Expanded(child: MoveWindow()),
               
                Row(
                  children: [
                    MinimizeWindowButton(colors: WindowButtonColors(
                      iconNormal: Colors.grey[800],
                     
                    )),
                    MaximizeWindowButton(colors: WindowButtonColors(
                      iconNormal: Colors.grey[800],
                    
                    )),
                    CloseWindowButton(colors: WindowButtonColors(
                      iconNormal: Colors.grey[800],
                      mouseOver: Colors.red,
                      mouseDown: Colors.red.shade800,
                    )),
                  ],
                ),
              ],
            ),
          ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}