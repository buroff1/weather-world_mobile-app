import 'package:flutter/cupertino.dart'; // Import Cupertino design library
import 'package:flutter/material.dart'; // Import Material design library
import 'package:provider/provider.dart'; // Import Provider for state management
import 'package:weather_app/dataset.dart'; // Import dataset module from weather_app
import 'package:weather_app/unit_provider.dart'; // Import UnitProvider for managing units

// Define ExtraWeather which is a StatefulWidget
class ExtraWeather extends StatefulWidget {
  final Weather temp; // Weather data

  // Constructor to initialize temp
  ExtraWeather(this.temp);

  @override
  _ExtraWeatherState createState() => _ExtraWeatherState();
}

// State class for ExtraWeather
class _ExtraWeatherState extends State<ExtraWeather> {
  String windSpeedUnit = 'm/s'; // Default wind speed unit
  String windSpeed = ''; // Wind speed value

  @override
  void initState() {
    super.initState();
    updateWindSpeed(); // Update wind speed on initialization
  }

  @override
  void didUpdateWidget(covariant ExtraWeather oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateWindSpeed(); // Update wind speed when widget updates
  }

  // Method to update wind speed and unit based on selected units
  void updateWindSpeed() {
    final units = Provider.of<UnitProvider>(context, listen: false)
        .units; // Get units from Provider
    Future.delayed(Duration(milliseconds: 500), () {
      // Delay to ensure proper context handling
      if (mounted) {
        setState(() {
          windSpeed = widget.temp.wind.toString(); // Update wind speed value
          windSpeedUnit =
              units == 'metric' ? 'm/s' : 'mph'; // Update wind speed unit
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context)
        .size
        .width; // Get screen width for responsive design

    // Build the widget tree
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Space elements evenly
      children: [
        // Wind Speed
        Container(
          width: width * 0.2, // Set container width
          child: Column(
            children: [
              Icon(
                CupertinoIcons.wind, // Wind icon
                color: Colors.white, // White icon color
              ),
              SizedBox(
                height: width * 0.0125, // Set spacer height
              ),
              Text(
                '$windSpeed $windSpeedUnit', // Display wind speed and unit
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: width * 0.04), // Set text style
              ),
              SizedBox(
                height: width * 0.0125, // Set spacer height
              ),
              Text(
                "Wind", // Label for wind speed
                style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.04), // Set text style
              )
            ],
          ),
        ),
        // Humidity
        Container(
          width: width * 0.2, // Set container width
          child: Column(
            children: [
              Icon(
                CupertinoIcons.drop, // Humidity icon
                color: Colors.white, // White icon color
              ),
              SizedBox(
                height: width * 0.0125, // Set spacer height
              ),
              Text(
                '${widget.temp.humidity} %', // Display humidity value
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: width * 0.04), // Set text style
              ),
              SizedBox(
                height: width * 0.0125, // Set spacer height
              ),
              Text(
                "Humidity", // Label for humidity
                style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.04), // Set text style
              )
            ],
          ),
        ),
        // Rain Chance
        Container(
          width: width * 0.2, // Set container width
          child: Column(
            children: [
              Icon(
                CupertinoIcons.cloud_rain, // Rain icon
                color: Colors.white, // White icon color
              ),
              SizedBox(
                height: width * 0.0125, // Set spacer height
              ),
              Text(
                '${widget.temp.chanceRain} %', // Display rain chance value
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: width * 0.04), // Set text style
              ),
              SizedBox(
                height: width * 0.0125, // Set spacer height
              ),
              Text(
                "Rain", // Label for rain chance
                style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.04), // Set text style
              )
            ],
          ),
        )
      ],
    );
  }
}
