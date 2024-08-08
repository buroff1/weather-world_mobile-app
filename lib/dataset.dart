import 'dart:convert'; // Import the dart:convert library for JSON encoding and decoding
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart'
    as http; // Import the http package for making HTTP requests
import 'package:intl/intl.dart'; // Import the intl package for date formatting

// Define the Weather class with various properties
class Weather {
  final int current; // Current temperature
  final String name; // Weather condition name (e.g., Rain, Clouds)
  final String day; // Day of the week
  final int wind; // Wind speed
  final int humidity; // Humidity percentage
  final int chanceRain; // Chance of rain percentage
  final String image; // Icon image for weather condition
  final String location; // Location name
  final int max; // Maximum temperature
  final int min; // Minimum temperature
  final String time; // Time of the weather data

  // Constructor with named parameters
  Weather({
    this.current = 0, // Initialize current temperature with default value 0
    this.name =
        '', // Initialize weather condition name with default empty string
    this.day = '', // Initialize day with default empty string
    this.wind = 0, // Initialize wind speed with default value 0
    this.humidity = 0, // Initialize humidity percentage with default value 0
    this.chanceRain =
        0, // Initialize chance of rain percentage with default value 0
    this.location = '', // Initialize location name with default empty string
    this.max = 0, // Initialize maximum temperature with default value 0
    this.min = 0, // Initialize minimum temperature with default value 0
    this.time = '', // Initialize time with default empty string
  }) : image =
            findIcon(name); // Initialize the image based on weather condition

  // Static method to find the appropriate icon based on weather condition
  static String findIcon(String name) {
    switch (name) {
      case "Clouds":
        return "assets/clouds.png"; // Return clouds icon
      case "Rain":
        return "assets/rainy.png"; // Return rain icon
      case "Drizzle":
        return "assets/drizzle.png"; // Return drizzle icon
      case "Thunderstorm":
        return "assets/thunder.png"; // Return thunderstorm icon
      case "Snow":
        return "assets/snow.png"; // Return snow icon
      default:
        return "assets/sunny.png"; // Return sunny icon by default
    }
  }
}

// OpenWeatherMap API key
String appId = dotenv.env['OPENWEATHERMAP_APP_ID'] ?? 'default_key';

// Function to fetch weather data for a given city and units (metric or imperial)
Future<List?> fetchData(String city, String units) async {
  // URLs for climate, hourly, and current weather data
  var urlClimate =
      "https://pro.openweathermap.org/data/2.5/forecast/climate?q=$city&units=$units&appid=$appId";
  var urlHourly =
      "https://pro.openweathermap.org/data/2.5/forecast/hourly?q=$city&units=$units&appid=$appId";
  var urlCurrent =
      "https://pro.openweathermap.org/data/2.5/weather?q=$city&units=$units&appid=$appId";

  // Make HTTP GET requests to fetch the data
  var responseClimate = await http.get(Uri.parse(urlClimate));
  var responseHourly = await http.get(Uri.parse(urlHourly));
  var responseCurrent = await http.get(Uri.parse(urlCurrent));

  // Get the current date and time
  DateTime date = DateTime.now();

  // Check if the responses are successful (status code 200)
  if (responseClimate.statusCode == 200 && responseHourly.statusCode == 200) {
    // Decode the JSON data from the responses
    var resClimate = json.decode(responseClimate.body);
    var resHourly = json.decode(responseHourly.body);
    var todayData = json.decode(responseCurrent.body);

    // Get the rain value from the climate data
    var rainValue = resClimate['list'][0]['rain'] != null
        ? resClimate['list'][0]['rain']
        : 0;

    // Create a Weather object for the current temperature
    Weather currentTemp = Weather(
      current: todayData['main']['temp'].round(),
      // Current temperature
      name: todayData["weather"][0]["main"].toString(),
      // Weather condition name
      day: DateFormat("EEEE dd MMMM").format(date),
      // Formatted current day
      wind: todayData["wind"]["speed"]?.round() ?? 0,
      // Wind speed
      humidity: todayData["main"]["humidity"]?.round() ?? 0,
      // Humidity percentage
      chanceRain: rainValue.round(),
      // Chance of rain
      location: todayData["name"],
      // Location name
      max: todayData['main']['temp_max'].round(),
      // Maximum temperature
      min: todayData['main']['temp_min'].round(), // Minimum temperature
    );

    // Create a list of Weather objects for the hourly forecast
    List<Weather> todayWeather = [];
    for (var i = 0; i < 4; i++) {
      // Iterate over the first 4 hourly forecasts
      var hourlyData = resHourly['list'][i];
      DateTime hourlyDate = DateTime.fromMillisecondsSinceEpoch(
          hourlyData['dt'] * 1000); // Convert timestamp to DateTime

      todayWeather.add(
        Weather(
          current: hourlyData['main']['temp'].round(), // Hourly temperature
          time: DateFormat("HH:00").format(hourlyDate), // Formatted time
          name: hourlyData["weather"][0]["main"]
              .toString(), // Weather condition name
        ),
      );
    }

    // Get the weather data for tomorrow from the climate data
    var tomorrowData = resClimate['list'][1];
    Weather tomorrowTemp = Weather(
      max: tomorrowData['temp']['max'].round(),
      // Maximum temperature
      min: tomorrowData['temp']['min'].round(),
      // Minimum temperature
      name: tomorrowData["weather"][0]["main"].toString(),
      // Weather condition name
      wind: tomorrowData["speed"]?.round() ?? 0,
      // Wind speed
      humidity: tomorrowData["humidity"]?.round() ?? 0,
      // Humidity percentage
      chanceRain: tomorrowData["rain"]?.round() ?? 0, // Chance of rain
    );

    // Create a list of Weather objects for the seven-day forecast
    List<Weather> sevenDay = [];
    for (var i = 0; i < 7; i++) {
      // Iterate over the first 7 days
      var dayData = resClimate['list'][i];
      String day = DateFormat("EEEE")
          .format(DateTime.fromMillisecondsSinceEpoch(
              dayData['dt'] * 1000)) // Convert timestamp to formatted day
          .substring(0, 3); // Get the first 3 letters of the day
      sevenDay.add(
        Weather(
          max: dayData['temp']['max'].round(),
          // Maximum temperature
          min: dayData['temp']['min'].round(),
          // Minimum temperature
          name: dayData["weather"][0]["main"].toString(),
          // Weather condition name
          day: day, // Day of the week
        ),
      );
    }

    // Return the current temperature, hourly forecast, tomorrow's weather, and seven-day forecast
    return [currentTemp, todayWeather, tomorrowTemp, sevenDay];
  }
  // Throw an exception if the city is not found
  throw Exception('City not found');
}
