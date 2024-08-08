import 'package:flutter/material.dart'; // Import Flutter material package for UI components
import 'package:flutter_glow/flutter_glow.dart'; // Import Flutter Glow package for UI effects
import 'package:weather_app/dataset.dart'; // Import dataset module from weather_app
import 'package:weather_app/extraWeather.dart'; // Import ExtraWeather widget
import 'package:weather_app/homePage.dart'; // Import HomePage widget

// Define DetailPage which is a StatelessWidget
class DetailPage extends StatelessWidget {
  final Weather? tomorrowTemp; // Weather data for tomorrow
  final List<Weather?> sevenDay; // Weather data for 7 days

  // Constructor to initialize tomorrowTemp and sevenDay
  DetailPage(this.tomorrowTemp, this.sevenDay);

  @override
  Widget build(BuildContext context) {
    // Build the widget tree
    return Scaffold(
      backgroundColor: Color(0xff363b64), // Set background color
      body: Column(
        children: [
          TomorrowWeather(tomorrowTemp),
          SevenDays(sevenDay)
        ], // Display tomorrow's weather and 7-day forecast
      ),
    );
  }
}

// Define TomorrowWeather which is a StatelessWidget
class TomorrowWeather extends StatelessWidget {
  final Weather? tomorrowTemp; // Weather data for tomorrow

  // Constructor to initialize tomorrowTemp
  TomorrowWeather(this.tomorrowTemp);

  // Method to navigate with slide transition
  void navigateWithSlideTransition(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0); // Start from left to right
          const end = Offset.zero; // End at original position
          const curve = Curves.ease; // Set transition curve

          var tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve)); // Define tween for transition
          var offsetAnimation =
              animation.drive(tween); // Create offset animation

          return SlideTransition(
            position: offsetAnimation, // Apply offset animation
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context)
        .size
        .width; // Get screen width for responsive design

    // Build the widget tree
    return GlowContainer(
      color: Color(0xff1F8CD8), // Set container color
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(width * 0.15), // Set bottom-left radius
        bottomRight: Radius.circular(width * 0.15), // Set bottom-right radius
      ),
      child: Column(
        children: [
          // Header with back button and title
          Padding(
            padding: EdgeInsets.only(
              top: width * 0.135, // Set top padding
              right: width * 0.075, // Set right padding
              left: width * 0.075, // Set left padding
              bottom: width * 0.025, // Set bottom padding
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context); // Pop if possible
                    } else {
                      navigateWithSlideTransition(
                          context, HomePage()); // Navigate to HomePage
                    }
                  },
                  child: Icon(
                    Icons.arrow_back_ios, // Back arrow icon
                    color: Colors.white, // White icon color
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center, // Center align
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today, // Calendar icon
                          color: Colors.white, // White icon color
                        ),
                        Text(
                          " Weekly Forecast",
                          style: TextStyle(
                            fontSize: width * 0.0625, // Set font size
                            fontWeight: FontWeight.bold, // Bold font
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 32), // Adjust width as needed
              ],
            ),
          ),
          // Weather data for tomorrow
          Padding(
            padding: EdgeInsets.all(width * 0.0099), // Set padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Space between children
              children: [
                Container(
                  width: width / 2.4, // Set container width
                  height: width / 2.3, // Set container height
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Weather.findIcon(
                          tomorrowTemp?.name ?? '')), // Set weather icon
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Start align
                  mainAxisSize: MainAxisSize.min, // Minimize main axis size
                  children: [
                    Text(
                      "Tomorrow",
                      style: TextStyle(
                          fontSize: width * 0.075,
                          height: 0.1), // Set font size and height
                    ),
                    Container(
                      padding: EdgeInsets.only(right: width * 0.023),
                      height: width * 0.28, // Set container height
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        // Align at end
                        children: [
                          Text(
                            tomorrowTemp?.max?.toString() ?? '--',
                            // Display max temperature
                            style: TextStyle(
                              fontSize: width * 0.25, // Set font size
                              fontWeight: FontWeight.bold, // Bold font
                            ),
                          ),
                          Text(
                            "/" +
                                (tomorrowTemp?.min?.toString() ?? '--') +
                                "\u00B0", // Display min temperature
                            style: TextStyle(
                              color: Colors.black54.withOpacity(0.3),
                              // Set text color with opacity
                              fontSize: width * 0.08,
                              // Set font size
                              fontWeight: FontWeight.bold, // Bold font
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: width * 0.025, // Set spacer height
                    ),
                    Text(
                      " " + (tomorrowTemp?.name ?? 'Unknown'),
                      // Display weather name
                      style:
                          TextStyle(fontSize: width * 0.0475), // Set font size
                    )
                  ],
                )
              ],
            ),
          ),
          // Extra weather data
          Padding(
            padding: EdgeInsets.only(
              bottom: width * 0.025, // Set bottom padding
              right: width * 0.075, // Set right padding
              left: width * 0.075, // Set left padding
            ),
            child: Column(
              children: [
                Divider(color: Colors.white), // White divider
                SizedBox(height: width * 0.025), // Set spacer height
                ExtraWeather(
                  tomorrowTemp ??
                      Weather(
                        location: 'Unknown',
                        current: 0,
                        name: 'Unknown',
                        day: 'Unknown',
                        time: 'Unknown',
                        max: 0,
                        min: 0,
                      ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Define SevenDays which is a StatelessWidget
class SevenDays extends StatelessWidget {
  final List<Weather?> sevenDay; // Weather data for 7 days

  // Constructor to initialize sevenDay
  SevenDays(this.sevenDay);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context)
        .size
        .width; // Get screen width for responsive design

    // Build the widget tree
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(top: width * 0.035),
        itemCount: sevenDay.length, // Set item count to length of sevenDay
        itemBuilder: (BuildContext context, int index) {
          final weather = sevenDay[index]; // Get weather data at index
          return Padding(
            padding: EdgeInsets.only(
              left: width * 0.05, // Set left padding
              right: width * 0.05, // Set right padding
              bottom: width * 0.0625, // Set bottom padding
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // Center align
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Space between children
              children: [
                Container(
                  width: width * 0.15, // Set container width
                  child: Padding(
                    padding: EdgeInsets.only(left: width * 0.02),
                    child: Text(
                      weather?.day ?? 'Unknown', // Display day
                      style: TextStyle(fontSize: width * 0.05), // Set font size
                    ),
                  ),
                ),
                Container(
                  width: width * 0.34, // Set container width
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // Center align
                    mainAxisAlignment: MainAxisAlignment.start,
                    // Start align
                    children: [
                      Image(
                        image: AssetImage(weather?.image ?? 'assets/rainy.png'),
                        // Set weather icon
                        width: width * 0.1, // Set icon width
                      ),
                      SizedBox(width: width * 0.0375), // Set spacer width
                      Text(
                        weather?.name ?? 'Unknown', // Display weather name
                        style:
                            TextStyle(fontSize: width * 0.05), // Set font size
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: width * 0.025),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // Center align
                    mainAxisAlignment: MainAxisAlignment.end,
                    // End align
                    children: [
                      Text(
                        "+" + (weather?.max?.toString() ?? '--') + "\u00B0",
                        // Display max temperature
                        style:
                            TextStyle(fontSize: width * 0.05), // Set font size
                      ),
                      SizedBox(width: width * 0.0125), // Set spacer width
                      Text(
                        "+" + (weather?.min?.toString() ?? '--') + "\u00B0",
                        // Display min temperature
                        style: TextStyle(
                          fontSize: width * 0.05, // Set font size
                          color: Colors.white60, // Set text color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
