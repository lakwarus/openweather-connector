import ballerina/http;
import ballerina/encoding;

final string OPENWEATHER_API_URL="https://api.openweathermap.org";
final string CURRENT_WEATHER_ENDPOINT = "/data/2.5/weather";

public type Client client object {

    string apiKey;
    http:Client openWeatherClient;

    public function __init(OpenWeatherConfiguration opweatherConfig) {    
        self.openWeatherClient = new(OPENWEATHER_API_URL);
        self.apiKey = opweatherConfig.apiKey;
    }

    public remote function getWeather(string city) returns @tainted WeatherData|error {

        WeatherData cityWeather = {}; 
        string encodedCity = check encoding:encodeUriComponent(city, "UTF-8");
        string param = string `${CURRENT_WEATHER_ENDPOINT}?q=${encodedCity}&appid=${self.apiKey}&units=metric`;

        var res = self.openWeatherClient->get(param);
        if (res is error) {
            error e = error("Error occurred conecting OpenWeather API");
            return e;

        } else {
            var result = res.getJsonPayload();
            if (result is error) {
                error e = error("Error occurred extracting payload");
                return e;

            }else { 
                json code = check result.cod;
                if (code == "404"){
                    error e = error("City is not found");
                    return e;

                } else {
                    var weatherArrJson = <json[]> check result.weather;
                    var weatherMain = check weatherArrJson[0].main;
                    var weatherDescription = check weatherArrJson[0].description;
                    var weatherTemperature = check result.main.temp;
                    var weatherTemperatureMin = check result.main.temp_min;
                    var weatherTemperatureMax = check result.main.temp_max;
                    var weatherPressure = check result.main.pressure;
                    var weatherHumidity = check result.main.humidity;
                    var weatherVisibility = check result.visibility;
                    var weatherWindSpeed = check result.wind.speed;
                    var weatherSunrise = check result.sys.sunrise;
                    var weatherSunset= check result.sys.sunset;

                    cityWeather.main = weatherMain.toString();
                    cityWeather.description = weatherDescription.toString();
                    cityWeather.temperature = weatherTemperature.toString();
                    cityWeather.temperature_min = weatherTemperatureMin.toString();
                    cityWeather.temperature_max = weatherTemperatureMax.toString();
                    cityWeather.pressure = weatherPressure.toString();
                    cityWeather.humidity = weatherHumidity.toString();
                    cityWeather.visibility = weatherVisibility.toString();
                    cityWeather.wind_speed = weatherWindSpeed.toString();
                    cityWeather.sunrise = weatherSunrise.toString();
                    cityWeather.sunset = weatherSunset.toString();
                }
            }
        }

        return cityWeather;
    }
};

public type OpenWeatherConfiguration record {
    string apiKey;
};

public type WeatherData record {
    string main = "";
    string description = "";
    string temperature = "";
    string temperature_min = "";
    string temperature_max = "";
    string pressure = "";
    string humidity = "";
    string visibility = "";
    string wind_speed = "";
    string sunrise = "";
    string sunset = "";
};

