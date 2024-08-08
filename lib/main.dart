import 'package:flutter/material.dart'; // Import Flutter material package for UI components
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv to handle environment variables
import 'package:provider/provider.dart'; // Import Provider for state management
import 'package:weather_app/homePage.dart'; // Import HomePage widget
import 'package:weather_app/unit_provider.dart'; // Import UnitProvider for managing units of measurement
import 'package:sizer/sizer.dart'; // Import Sizer package for responsive design

// Main function to run the app
Future<void> main() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UnitProvider()),
        // Provide UnitProvider to manage unit state
      ],
      child: MyApp(), // The root widget of the application
    ),
  );
}

// Define MyApp which is a StatelessWidget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Wrap MaterialApp with Sizer for responsive design
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Weather', // Set the title of the app
          theme: ThemeData(
            textTheme: Theme.of(context)
                .textTheme
                .apply(bodyColor: Colors.white, displayColor: Colors.blue),
            // Apply white color to body text and blue to display text
            colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: Colors.blue), // Set secondary color to blue
          ),
          debugShowCheckedModeBanner: false, // Disable debug banner
          home: HomePage(), // Set HomePage as the initial screen
        );
      },
    );
  }
}
