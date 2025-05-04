import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:med_reminder_app/core/styling/theme_data.dart';
import 'package:med_reminder_app/core/widgets/Primary_Outlined_Button_Widget.dart';
import 'package:med_reminder_app/core/widgets/custom_text_field.dart';
import 'package:med_reminder_app/core/widgets/primary_button_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: AppThemes.lightTheme,
          home: child,
        );
      },
      child: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isPassword = true;
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PrimaryButtonWidget(buttonText: "login", onPressed: () {}),
            const SizedBox(height: 20),
            PrimaryOutlinedButtonWidget(buttonText: "login", onPressed: () {}),
            const SizedBox(height: 20),
            CustomTextField(hintText: "Email"),
            const SizedBox(height: 20),
            CustomTextField(
              hintText: "Password",
              isPassword: isPassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isPassword = !isPassword;
                  });
                },
                icon: Icon(
                  isPassword
                      ? Icons.remove_red_eye_outlined
                      : Icons.visibility_off,
                ),
                color: Color(0xFF6A707C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
