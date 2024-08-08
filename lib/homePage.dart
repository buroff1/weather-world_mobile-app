import 'package:flutter/cupertino.dart'; // Import Cupertino design components
import 'package:flutter/material.dart'; // Import Material design components
import 'package:provider/provider.dart'; // Import provider package for state management
import 'package:weather_app/dataset.dart'; // Import dataset module
import 'package:weather_app/detailPage.dart'; // Import detail page module
import 'package:weather_app/extraWeather.dart'; // Import extra weather widget
import 'package:flutter_glow/flutter_glow.dart'; // Import glow effect package
import 'package:geolocator/geolocator.dart'; // Import geolocator package for location services
import 'package:geocoding/geocoding.dart'; // Import geocoding package for reverse geocoding
import 'package:permission_handler/permission_handler.dart'; // Import permission handler package
import 'package:weather_app/unit_provider.dart'; // Import unit provider for unit conversions
import 'package:weather_app/database_helper.dart'; // Import database helper
import 'package:weather_app/favoriteCitiesScreen.dart'; // Import favorite cities screen
import 'package:sizer/sizer.dart'; // Import sizer package for responsive UI

Weather? currentTemp; // Variable to store current temperature data
Weather? tomorrowTemp; // Variable to store tomorrow's temperature data
List<Weather> todayWeather = []; // List to store today's weather data
List<Weather> sevenDay = []; // List to store seven days' weather data
String city = ""; // Variable to store city name
bool isFavorite = false; // Global favorite state

Future<String> getCityNameFromCoordinates(Position position) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude, position.longitude); // Get placemarks from coordinates
  Placemark place = placemarks[0]; // Get first placemark
  return place.locality ?? "Unknown"; // Return locality or "Unknown"
}

void checkIfFavorite() async {
  final db = DatabaseHelper();
  List<String> favoriteCities =
      await db.getFavoriteCities(); // Get favorite cities from database
  isFavorite = favoriteCities.contains(city); // Update isFavorite state
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController; // Controller for PageView
  int _currentPage = 1; // Current page index

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: _currentPage); // Initialize PageController
    determinePosition().then((position) {
      // Determine the user's position
      getCityNameFromCoordinates(position).then((cityName) {
        // Get city name from coordinates
        if (mounted) {
          setState(() {
            city = cityName; // Set city name
            checkIfFavorite(); // Check if the city is a favorite
          });
          getData(); // Fetch weather data
        }
      });
    }).catchError((error) {
      if (mounted) {
        showPermissionDeniedDialog(); // Show dialog if permission is denied
        setState(() {
          city = "Venice"; // Default city
          checkIfFavorite(); // Check if the default city is a favorite
        });
        getData(); // Fetch weather data for default city
      }
    });
  }

  Future<void> getData() async {
    final units = Provider.of<UnitProvider>(context, listen: false)
        .units; // Get units from provider
    fetchData(city, units).then((value) {
      // Fetch data from API
      if (mounted) {
        try {
          if (value != null && value.isNotEmpty) {
            setState(() {
              currentTemp = value[0] as Weather?; // Set current temperature
              todayWeather =
                  value[1] as List<Weather>? ?? []; // Set today's weather
              tomorrowTemp = value[2] as Weather?; // Set tomorrow's temperature
              sevenDay =
                  value[3] as List<Weather>? ?? []; // Set seven days' weather
            });
          } else {
            setState(() {
              currentTemp = null; // No data
              todayWeather = []; // No data
              tomorrowTemp = null; // No data
              sevenDay = []; // No data
            });
          }
        } catch (e) {
          setState(() {
            currentTemp = null; // Handle error
            todayWeather = []; // Handle error
            tomorrowTemp = null; // Handle error
            sevenDay = []; // Handle error
          });
          print('Error fetching data: $e'); // Print error
        }
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          currentTemp = null; // Handle error
          todayWeather = []; // Handle error
          tomorrowTemp = null; // Handle error
          sevenDay = []; // Handle error
        });
        print('Error fetching data: $error'); // Print error
      }
    });
  }

  void onCitySelected(String cityName) {
    if (mounted) {
      setState(() {
        city = cityName; // Update city name
        _currentPage = 1; // Set to main page
      });
      getData(); // Fetch new data
      _pageController.animateToPage(1, // Animate to main page
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    }
  }

  Future<void> openFavoriteCitiesScreen() async {
    final selectedCity = await Navigator.push(
      // Navigate to favorite cities screen
      context,
      MaterialPageRoute(
        builder: (context) => FavoriteCitiesScreen(
          units: Provider.of<UnitProvider>(context, listen: false).units,
          // Pass units
          currentTemp: currentTemp,
          // Pass current temperature
          todayWeather: todayWeather,
          // Pass today's weather
          tomorrowTemp: tomorrowTemp,
          // Pass tomorrow's temperature
          sevenDay: sevenDay,
          // Pass seven days' weather
          onCitySelected: onCitySelected, // Callback for city selection
        ),
      ),
    );

    if (selectedCity != null && selectedCity is String) {
      onCitySelected(selectedCity); // Update city if selected
    }
  }

  @override
  Widget build(BuildContext context) {
    final units =
        Provider.of<UnitProvider>(context).units; // Get units from provider

    return Scaffold(
      backgroundColor: Color(0xff363b64), // Set background color
      body: PageView(
        controller: _pageController, // Set controller
        onPageChanged: (index) {
          setState(() {
            _currentPage = index; // Update current page
          });
        },
        children: [
          FavoriteCitiesScreen(
            units: units,
            // Pass units
            currentTemp: currentTemp,
            // Pass current temperature
            todayWeather: todayWeather,
            // Pass today's weather
            tomorrowTemp: tomorrowTemp,
            // Pass tomorrow's temperature
            sevenDay: sevenDay,
            // Pass seven days' weather
            onCitySelected: onCitySelected, // Callback for city selection
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                CurrentWeather(getData, units),
                TodayWeather()
              ], // Show current and today's weather
            ),
          ),
          DetailPage(tomorrowTemp, sevenDay),
          // Add DetailPage as the third page
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose controller
    super.dispose();
  }

  void showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xff1F8CD8),
        // Dialog background color
        title: Text("Location Permission"),
        // Dialog title
        content: Text(
            "Location permission is denied. Please enable it in the app settings."),
        // Dialog content
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              openAppSettings(); // Open app settings
            },
            style: TextButton.styleFrom(backgroundColor: Color(0xff363B64)),
            // Button style
            child: Text("Open Settings",
                style: TextStyle(color: Colors.white)), // Button text
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            style: TextButton.styleFrom(backgroundColor: Color(0xff363B64)),
            // Button style
            child: Text("Cancel",
                style: TextStyle(color: Colors.white)), // Button text
          ),
        ],
      ),
    );
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator
        .isLocationServiceEnabled(); // Check if location services are enabled
    if (!serviceEnabled) {
      return Future.error(
          'Location services are disabled.'); // Return error if disabled
    }

    permission =
        await Geolocator.checkPermission(); // Check location permission
    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission(); // Request permission if denied
      if (permission == LocationPermission.denied) {
        return Future.error(
            'Location permissions are denied'); // Return error if still denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.'); // Return error if permanently denied
    }

    return await Geolocator.getCurrentPosition(); // Get current position
  }
}

class CurrentWeather extends StatefulWidget {
  final Function() updateData; // Callback function to update data
  final String units; // Units of measurement

  CurrentWeather(this.updateData, this.units); // Constructor

  @override
  State<CurrentWeather> createState() => _CurrentWeatherState(); // Create state
}

class _CurrentWeatherState extends State<CurrentWeather> {
  bool searchBar = false; // Search bar visibility
  bool updating = false; // Update state
  var focusNode = FocusNode(); // Focus node for text field
  String previousCity = city; // Store the previous valid city name

  @override
  void initState() {
    super.initState();
    checkIfFavorite(); // Check if the current city is a favorite
  }

  // Method to toggle favorite status
  void toggleFavorite() async {
    final db = DatabaseHelper();
    if (isFavorite) {
      await db.deleteCity(city); // Remove city from favorites
    } else {
      await db.insertCity(city); // Add city to favorites
    }
    setState(() {
      isFavorite = !isFavorite; // Toggle isFavorite state
    });
  }

  void showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xff1F8CD8),
        // Dialog background color
        title: Text("Location Permission"),
        // Dialog title
        content: Text(
            "Location permission is denied. Please enable it in the app settings."),
        // Dialog content
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              openAppSettings(); // Open app settings
            },
            style: TextButton.styleFrom(backgroundColor: Color(0xff363B64)),
            // Button style
            child: Text("Open Settings",
                style: TextStyle(color: Colors.white)), // Button text
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            style: TextButton.styleFrom(backgroundColor: Color(0xff363B64)),
            // Button style
            child: Text("Cancel",
                style: TextStyle(color: Colors.white)), // Button text
          ),
        ],
      ),
    );
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator
        .isLocationServiceEnabled(); // Check if location services are enabled
    if (!serviceEnabled) {
      return Future.error(
          'Location services are disabled.'); // Return error if disabled
    }

    permission =
        await Geolocator.checkPermission(); // Check location permission
    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission(); // Request permission if denied
      if (permission == LocationPermission.denied) {
        showPermissionDeniedDialog(); // Show permission denied dialog
        return Future.error(
            'Location permissions are denied'); // Return error if still denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showPermissionDeniedDialog(); // Show permission denied dialog
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.'); // Return error if permanently denied
    }

    return await Geolocator.getCurrentPosition(); // Get current position
  }

  // Method to show city not found dialog
  void showCityNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xff1F8CD8),
        // Dialog background color
        title: Text("City Not Found"),
        // Dialog title
        content: Text(
            "The city you entered could not be found. Please check the spelling and try again."),
        // Dialog content
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Revert to the previous city name
              setState(() {
                city = previousCity; // Set city to previous city
              });
            },
            style: TextButton.styleFrom(backgroundColor: Color(0xff363B64)),
            // Button style
            child: Text("OK",
                style: TextStyle(color: Colors.white)), // Button text
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final units =
        Provider.of<UnitProvider>(context).units; // Get units from provider

    return GestureDetector(
      onTap: () {
        if (searchBar)
          setState(() => searchBar = false); // Hide search bar on tap
      },
      child: GlowContainer(
        height: 71.0.h,
        // Adjusted for smaller screens
        padding: EdgeInsets.only(top: 6.2.h, left: 5.0.w, right: 5.0.w),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0.w),
            bottomRight: Radius.circular(10.0.w)),
        // Set border radius
        color: Color(0xff1F8CD8),
        // Set background color
        child: Column(
          children: [
            Container(
              child: searchBar
                  ? TextField(
                      focusNode: focusNode, // Set focus node
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.5.w)),
                          // Set border radius
                          fillColor: Color(0xff030317),
                          // Set fill color
                          filled: true,
                          // Enable fill color
                          hintText: "Enter a city Name"), // Set hint text
                      textInputAction:
                          TextInputAction.search, // Set input action
                      onSubmitted: (value) async {
                        String capitalizeEachWord(String input) {
                          return input
                              .split(' ')
                              .map((word) => word.trim().isNotEmpty
                                  ? '${word.trim()[0].toUpperCase()}${word.trim().substring(1).toLowerCase()}'
                                  : '')
                              .join(' '); // Capitalize each word
                        }

                        String newCity = capitalizeEachWord(
                            value.trim()); // Capitalize city name
                        updating = true; // Set updating state
                        setState(() {});
                        try {
                          final value =
                              await fetchData(newCity, units); // Fetch data
                          if (value != null && value.isNotEmpty) {
                            setState(() {
                              previousCity = newCity; // Store the previous city
                              city = newCity; // Set new city
                              currentTemp = value[0]
                                  as Weather?; // Set current temperature
                              todayWeather = value[1] as List<Weather>? ??
                                  []; // Set today's weather
                              tomorrowTemp = value[2]
                                  as Weather?; // Set tomorrow's temperature
                              sevenDay = value[3] as List<Weather>? ??
                                  []; // Set seven days' weather
                              searchBar = false; // Hide search bar
                            });
                            checkIfFavorite(); // Check if favorite
                            widget.updateData(); // Update data
                          } else {
                            // City not found, show dialog and revert to previous city
                            showCityNotFoundDialog(); // Show city not found dialog
                          }
                        } catch (error) {
                          print('Error fetching data: $error'); // Print error
                          showCityNotFoundDialog(); // Show city not found dialog
                        } finally {
                          updating = false; // Set updating state
                          setState(() {});
                        }
                      })
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // Align children
                      children: [
                        GestureDetector(
                          onTap: toggleFavorite, // Toggle favorite status
                          child: Icon(
                            isFavorite
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart, // Set icon
                            color: isFavorite ? Colors.red : Colors.white,
                            // Set color
                            size: 6.0.w, // Adjust icon size
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Position position =
                                    await determinePosition(); // Determine position
                                String cityName = await getCityNameFromCoordinates(
                                    position); // Get city name from coordinates
                                setState(() {
                                  city = cityName; // Set city name
                                });
                                widget.updateData(); // Update data
                                checkIfFavorite(); // Check if favorite
                              },
                              child: Icon(CupertinoIcons.location_fill,
                                  color: Colors.white,
                                  size: 5.5.w), // Adjust icon size
                            ),
                            Text(
                              " " + city, // Display city name
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 6.2.w), // Adjust font size
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            searchBar = true; // Show search bar
                            setState(() {});
                            focusNode.requestFocus(); // Request focus
                          },
                          child: Icon(CupertinoIcons.search,
                              color: Colors.white,
                              size: 6.0.w), // Adjust icon size
                        ),
                      ],
                    ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 0.625.h),
              // Increase padding for more height
              decoration: BoxDecoration(
                color: Colors.transparent, // Make background transparent
                borderRadius: BorderRadius.circular(7.5.w), // Set border radius
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Minimize main axis size
                children: [
                  Text(
                    'C°', // Celsius label
                    style: TextStyle(
                      fontSize: 5.0.w, // Increase font size for larger labels
                      fontWeight: FontWeight.bold,
                      color: widget.units == 'metric'
                          ? Colors.white
                          : Color(0xff030317), // Set color based on units
                    ),
                  ),
                  SizedBox(width: 2.5.w), // Add spacing
                  Transform.scale(
                    scale: 1.1,
                    // Scale the switch for a better visual appearance
                    child: Switch(
                      value: widget.units == 'imperial',
                      // Set switch value
                      onChanged: (value) {
                        Provider.of<UnitProvider>(context, listen: false)
                            .toggleUnits(); // Toggle units
                        widget.updateData(); // Update data
                      },
                      inactiveThumbColor: Colors.white,
                      // Set inactive thumb color
                      inactiveTrackColor: Colors.white.withOpacity(0.5),
                      // Set inactive track color
                      activeColor: Colors.white,
                      // Set active color
                      activeTrackColor: Colors.white.withOpacity(0.5),
                      // Set active track color
                      materialTapTargetSize: MaterialTapTargetSize
                          .shrinkWrap, // Set tap target size
                    ),
                  ),
                  SizedBox(width: 2.5.w), // Add spacing
                  Text(
                    'F°', // Fahrenheit label
                    style: TextStyle(
                      fontSize: 5.0.w, // Increase font size for larger labels
                      fontWeight: FontWeight.bold,
                      color: widget.units == 'imperial'
                          ? Colors.white
                          : Color(0xff030317), // Set color based on units
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: Stack(
                  children: [
                    Positioned(
                      top: -0.5.h, // Adjust position
                      left: 0,
                      right: 0,
                      child: Image(
                        image: AssetImage(
                            currentTemp?.image ?? 'assets/rainy.png'),
                        // Set image
                        fit: BoxFit.contain,
                        // Fit image
                        height: 28.0.h, // Adjust image height
                      ),
                    ),
                    Positioned(
                      bottom: 5.0.h, // Adjust this value to move text lower
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          '${currentTemp?.current?.toString()}°' ?? '--',
                          // Display current temperature
                          style: TextStyle(
                            fontSize: 16.0.w, // Set font size
                            fontWeight: FontWeight.bold, // Set font weight
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          // Minimize main axis size
                          children: [
                            SizedBox(height: 10.0.h),
                            // Add space above the other texts
                            Text(
                              currentTemp?.name ?? 'Unknown',
                              // Display city name
                              style:
                                  TextStyle(fontSize: 6.0.w), // Set font size
                            ),
                            Text(
                              currentTemp?.day ?? 'Unknown', // Display day
                              style:
                                  TextStyle(fontSize: 4.0.w), // Set font size
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: Colors.white), // Add divider
            Padding(
              padding: EdgeInsets.only(
                  bottom: 1.75.h, right: 7.5.w, left: 7.5.w), // Set padding
              child: Column(
                children: [
                  SizedBox(height: 1.0.h), // Add spacing
                  ExtraWeather(currentTemp ?? // Display extra weather details
                      Weather(
                        location: 'Unknown',
                        // Set default values
                        current: 0,
                        name: 'Unknown',
                        day: 'Unknown',
                        time: 'Unknown',
                        max: 0,
                        min: 0,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Define TodayWeather as a StatelessWidget
class TodayWeather extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width; // Get screen width

    return Padding(
      padding: EdgeInsets.only(
          left: width * 0.075, right: width * 0.075, top: width * 0.025),
      // Set padding
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align children
            children: [
              Text(
                "Today", // Display "Today" label
                style: TextStyle(
                    fontSize: width * 0.0625,
                    fontWeight: FontWeight.bold), // Set font size and weight
              ),
              Image.asset(
                'assets/logo.png', // Set logo image
                height: width * 0.125, // Set height
                width: width * 0.25, // Set width
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return DetailPage(
                        tomorrowTemp, sevenDay); // Navigate to DetailPage
                  }));
                },
                child: Row(
                  children: [
                    Text(
                      "Week", // Display "Week" label
                      style: TextStyle(
                        fontSize: width * 0.045, // Set font size
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_outlined, // Set icon
                      size: width * 0.0375, // Set icon size
                      color: Colors.white, // Set color
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: width * 0.0375, // Add spacing
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: width * 0.075, // Set margin
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Align children
              children: [
                WeatherWidget(todayWeather.length > 0 ? todayWeather[0] : null),
                // Display weather widget
                WeatherWidget(todayWeather.length > 1 ? todayWeather[1] : null),
                // Display weather widget
                WeatherWidget(todayWeather.length > 2 ? todayWeather[2] : null),
                // Display weather widget
                WeatherWidget(todayWeather.length > 3 ? todayWeather[3] : null),
                // Display weather widget
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Define WeatherWidget as a StatelessWidget
class WeatherWidget extends StatelessWidget {
  final Weather? weather; // Weather data

  WeatherWidget(this.weather); // Constructor

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width; // Get screen width

    // Determine background color based on the time of day
    Color getBackgroundColor(String time) {
      int hour = int.parse(time.split(':')[0]); // Parse hour
      if (hour >= 21 || hour < 6) {
        return Color.fromRGBO(44, 62, 80, 0.7); // Night color
      } else if (hour >= 6 && hour < 12) {
        return Color.fromRGBO(52, 198, 255, 0.7); // Morning color
      } else {
        return Color.fromRGBO(230, 144, 0, 0.7); // Day color
      }
    }

    return Container(
      padding: EdgeInsets.all(width * 0.03), // Set padding
      decoration: BoxDecoration(
        color: getBackgroundColor(weather?.time ?? '00:00'),
        // Set background color
        border: Border.all(width: 1, color: Colors.white),
        // Set border
        borderRadius:
            BorderRadius.circular(width * 0.0875), // Set border radius
      ),
      child: Column(
        children: [
          Text(
            (weather?.current?.toString() ?? '--') + '\u00B0',
            // Display current temperature
            style: TextStyle(fontSize: width * 0.05), // Set font size
          ),
          SizedBox(
            height: width * 0.0125, // Add spacing
          ),
          Image(
            image: AssetImage(weather?.image ?? 'assets/rainy.png'),
            // Set image
            width: width * 0.125,
            // Set width
            height: width * 0.125, // Set height
          ),
          SizedBox(
            height: width * 0.0125, // Add spacing
          ),
          Text(
            weather?.time ?? '--', // Display time
            style: TextStyle(
                fontSize: width * 0.04,
                color: Colors.white), // Set font size and color
          )
        ],
      ),
    );
  }
}
