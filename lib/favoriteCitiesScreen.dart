import 'package:flutter/material.dart'; // Import Flutter material package for UI components
import 'package:weather_app/database_helper.dart'; // Import DatabaseHelper for database operations
import 'package:weather_app/dataset.dart'; // Import dataset module from weather_app

// Define FavoriteCitiesScreen which is a StatefulWidget
class FavoriteCitiesScreen extends StatefulWidget {
  final String units; // Units for temperature
  final Weather? currentTemp; // Current temperature
  final List<Weather> todayWeather; // Weather data for today
  final Weather? tomorrowTemp; // Weather data for tomorrow
  final List<Weather> sevenDay; // Weather data for 7 days
  final Function(String)
      onCitySelected; // Callback function when a city is selected

// Constructor to initialize the parameters
  FavoriteCitiesScreen({
    required this.units, // Required parameter to specify the units (metric or imperial)
    required this.currentTemp, // Required parameter to pass the current temperature data
    required this.todayWeather, // Required parameter to pass today's weather data
    required this.tomorrowTemp, // Required parameter to pass tomorrow's temperature data
    required this.sevenDay, // Required parameter to pass seven days' weather data
    required this.onCitySelected, // Required parameter to pass the callback function when a city is selected
  });

  @override
  _FavoriteCitiesScreenState createState() =>
      _FavoriteCitiesScreenState(); // Create state for FavoriteCitiesScreen
}

// State class for FavoriteCitiesScreen
class _FavoriteCitiesScreenState extends State<FavoriteCitiesScreen> {
  List<String> favoriteCities = []; // List of favorite cities
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    loadFavoriteCities(); // Load favorite cities on initialization
  }

  // Method to load favorite cities from the database
  Future<void> loadFavoriteCities() async {
    final cities = await DatabaseHelper()
        .getFavoriteCities(); // Get favorite cities from the database
    setState(() {
      favoriteCities = cities; // Update favorite cities list
      isLoading = false; // Update loading state
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context)
        .size
        .width; // Get screen width for responsive design

    // Build the widget tree
    return Scaffold(
      backgroundColor: Color(0xff363b64), // Dark background
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff1F8CD8), // Blue app bar
        title: Text(
          "Favorite Cities",
          style: TextStyle(
              fontSize: width * 0.0625,
              fontWeight: FontWeight.bold,
              color: Colors.white), // White bold text
        ),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while loading
          : favoriteCities.isEmpty
              ? Center(
                  child: Text(
                    "No favorite cities added",
                    // Show message if no favorite cities are added
                    style:
                        TextStyle(color: Colors.white, fontSize: width * 0.045),
                  ),
                )
              : ReorderableListView(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  // Add vertical padding
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final String item = favoriteCities
                          .removeAt(oldIndex); // Remove city from old position
                      favoriteCities.insert(
                          newIndex, item); // Insert city at new position
                    });
                  },
                  children: favoriteCities.map((city) {
                    return FavoriteCityCard(
                      key: ValueKey(city),
                      city: city,
                      units: widget.units,
                      onDismissed: () async {
                        await DatabaseHelper()
                            .deleteCity(city); // Delete city from database
                        setState(() {
                          favoriteCities.remove(city); // Remove city from list
                        });
                      },
                      onCitySelected: widget.onCitySelected,
                    );
                  }).toList(),
                ),
    );
  }
}

// Define FavoriteCityCard which is a StatefulWidget
class FavoriteCityCard extends StatefulWidget {
  final String city; // City name
  final String units; // Units for temperature
  final VoidCallback onDismissed; // Callback function when a city is dismissed
  final Function(String)
      onCitySelected; // Callback function when a city is selected

  // Constructor to initialize the parameters
  FavoriteCityCard({
    required Key key,
    required this.city,
    required this.units,
    required this.onDismissed,
    required this.onCitySelected,
  }) : super(key: key);

  @override
  _FavoriteCityCardState createState() =>
      _FavoriteCityCardState(); // Create state for FavoriteCityCard
}

// State class for FavoriteCityCard
class _FavoriteCityCardState extends State<FavoriteCityCard> {
  late Future<Weather> _weatherFuture; // Future to hold weather data

  @override
  void initState() {
    super.initState();
    _weatherFuture =
        fetchWeather(widget.city); // Fetch weather data on initialization
  }

  // Method to fetch weather data
  Future<Weather> fetchWeather(String city) async {
    final data = await fetchData(city, widget.units); // Fetch weather data
    Weather weather = data![0] as Weather; // Cast to Weather
    return Weather(
      current: weather.current,
      name: weather.name,
      day: weather.day,
      wind: weather.wind,
      humidity: weather.humidity,
      chanceRain: weather.chanceRain,
      location: weather.location,
      max: weather.max,
      min: weather.min,
      time: weather.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context)
        .size
        .width; // Get screen width for responsive design

    // Build the widget tree
    return FutureBuilder<Weather>(
      future: _weatherFuture, // Future to wait for weather data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child:
                  CircularProgressIndicator()); // Show loading indicator while waiting
        }
        if (snapshot.hasError) {
          return Center(
              child: Text(
                  'Error: ${snapshot.error}')); // Show error message if there is an error
        }
        final weather = snapshot.data!;
        return GestureDetector(
          onTap: () {
            widget.onCitySelected(
                widget.city); // Use the provided onCitySelected callback
          },
          child: Dismissible(
            key: ValueKey(widget.city),
            direction: DismissDirection.endToStart,
            // Swipe to dismiss from end to start
            onDismissed: (direction) {
              widget.onDismissed(); // Call the provided onDismissed callback
            },
            background: Container(
              color: Colors.red,
              // Red background for dismiss action
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              // Set padding
              child:
                  Icon(Icons.delete, color: Colors.white), // White delete icon
            ),
            child: Card(
              color: Color(0xff1F8CD8),
              // Blue card background
              margin: EdgeInsets.symmetric(
                  vertical: width * 0.02, horizontal: width * 0.04),
              // Set margins
              child: Padding(
                padding: EdgeInsets.all(width * 0.04), // Set padding
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Start align
                        children: [
                          Text(
                            widget.city, // Display city name
                            style: TextStyle(
                              fontSize: width * 0.06, // Set font size
                              fontWeight: FontWeight.bold, // Bold font
                              color: Colors.white, // White text
                            ),
                          ),
                          SizedBox(height: width * 0.02), // Spacer
                          Text(
                            weather.name, // Display weather name
                            style: TextStyle(
                              fontSize: width * 0.04, // Set font size
                              color: Colors.white, // White text
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Max: ${weather.max}°',
                                // Display max temperature
                                style: TextStyle(
                                    fontSize: width * 0.04, // Set font size
                                    color: Colors.white), // White text
                              ),
                              SizedBox(width: width * 0.025), // Spacer
                              Text(
                                'Min: ${weather.min}°',
                                // Display min temperature
                                style: TextStyle(
                                    fontSize: width * 0.04, // Set font size
                                    color: Colors.white), // White text
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Wind: ${weather.wind} ${widget.units == 'metric' ? 'm/s' : 'mph'}',
                                // Display wind speed
                                style: TextStyle(
                                    fontSize: width * 0.04, // Set font size
                                    color: Colors.white), // White text
                              ),
                              SizedBox(width: width * 0.025), // Spacer
                              Text(
                                'Humidity: ${weather.humidity}%',
                                // Display humidity
                                style: TextStyle(
                                    fontSize: width * 0.04, // Set font size
                                    color: Colors.white), // White text
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Start align
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              left: width * 0.0375, bottom: width * 0.025),
                          // Set margins
                          child: Text(
                            '${weather.current}°',
                            // Display current temperature
                            style: TextStyle(
                              fontSize: width * 0.0875, // Set font size
                              fontWeight: FontWeight.bold, // Bold font
                              color: Colors.white, // White text
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              right: width * 0.0125, bottom: width * 0.025),
                          // Set margins
                          child: Image.asset(
                            weather.image, // Display weather icon
                            width: width * 0.175, // Set width
                            height: width * 0.15, // Set height
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
