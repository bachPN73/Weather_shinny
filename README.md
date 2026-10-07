# ⛅ Weather App - R Shiny Dashboard

A user-friendly Shiny web application that allows users to view and analyze real-time weather and forecasts by searching locations or clicking directly on an interactive map. The app integrates dynamic charts, weather metric summaries, and real-time data powered by the OpenWeatherMap API and OpenStreetMap Nominatim.

---

## 🚀 Features

---

* 📍 **Interactive Location & Map Selection (Leaflet)**  
  Visualize and click directly on the interactive map to select any location worldwide, or search by city name (e.g., Hanoi, Da Nang, Tokyo) with automatic reverse geocoding.

* 🌡️ **Real-Time Weather Metrics**  
  Quickly monitor key indicators in real-time, including:
  * Temperature & Feels-Like Temperature
  * Humidity & Air Pressure
  * Wind Speed & Visibility
  * Cloudiness / Weather Conditions

* 📊 **Forecast Visualization (Plotly)**  
  Interactive time-series line charts allowing users to dynamically inspect parameters (Temperature, Humidity, Wind Speed, Air Pressure, and Visibility).

* 🔥 **Meteorological Correlation Analysis**  
  Built-in correlation matrix heatmap visualizing the relationships between temperature, humidity, wind, visibility, and atmospheric pressure.

---

## 🖼️ Demo Screenshot

---

![Demo Screenshot](https://github.com/bachPN73/Weather_shinny/blob/main/Weather%20Shinny%20R/Weather_shinny.png)

> *Place your screenshot here by saving it as `screenshot.png` in the root folder.*

---

## 🛠 Technologies Used

---

* [R Shiny](https://shiny.posit.co/) & [shinydashboard](https://rstudio.github.io/shinydashboard/)
* [Leaflet for R](https://rstudio.github.io/leaflet/)
* [Plotly for R](https://plotly.com/r/)
* [OpenWeatherMap API](https://openweathermap.org/)
* [OpenStreetMap Nominatim](https://nominatim.openstreetmap.org/)
* `dplyr`, `httr`, `jsonlite`, `lubridate`

---

## 🧪 How to Run

---

### 📦 Prerequisites

Ensure you have R (>= 4.0.0) and the required packages installed:

```r
install.packages(c("shiny", "shinydashboard", "leaflet", "httr", "jsonlite", "plotly", "dplyr", "lubridate", "bslib"))
```

### 🔑 API Key Setup

1. Get a free API key at [OpenWeatherMap](https://openweathermap.org/api).
2. Open `server.R` (or `miniproject.R`) and insert your API key:
   ```r
   api_key <- "YOUR_OPENWEATHERMAP_API_KEY"
   ```

### 🏃 Running the Application

1. **Clone the repository:**
   ```bash
   git clone https://github.com/<your-username>/<your-repo-name>.git
   cd <your-repo-name>
   ```

2. **Run in RStudio:**
   * Open `ui.R` or `server.R` in RStudio.
   * Click the **Run App** button in the top right.

3. **Or run via R Console / Terminal:**
   ```r
   shiny::runApp()
   ```

---

## 🌐 Live Demo

---

🔗 **Try it now**: [https://backonhome.shinyapps.io/AppWeather/](https://backonhome.shinyapps.io/FPTchongBaoSo3/)
