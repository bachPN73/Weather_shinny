# Import libraries
library(tidyverse)
library(shiny)
library(shinydashboard)
library(httr)
library(jsonlite)
library(leaflet)
library(bslib)
library(plotly)
library(lubridate)
library(rsconnect)

api_key = "73e286c7fe9690535d5dfc860f2cc643"

ui <- dashboardPage(
  dashboardHeader(title = "Weather"),
  
  dashboardSidebar(
    sidebarMenu(
      textInput("city_name", "Enter location:",
                placeholder = "e.g., Hanoi, Da Nang, Tokyo", value = ""),
      menuItem("Weather", tabName = "weather", icon = icon("cloud")),
      menuItem("Forecast", tabName = "forecast", icon = icon("cloud-sun")),
      menuItem("Plot Information", tabName = "menu4", icon = icon("bars"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Tab Weather
      tabItem(tabName = "weather",
              h1("CURRENT WEATHER"),
              br(),
              fluidRow(
                box(width = 12, title = tagList(icon(""), "INFORMATION"),
                    status = "primary", solidHeader = TRUE,
                    fluidRow(
                      box(width = 2, title = tagList(icon("thermometer-half"), "Feels Like"),
                          h4(textOutput("feels_like")),
                          background = "yellow"),
                      box(width = 2, title = tagList(icon("tint"), "Humidity"),
                          h4(textOutput("humidity")),
                          background = "aqua"),
                      box(width = 2, title = tagList(icon("globe"), "Status"),
                          h4(textOutput("clouds")),
                          background = "light-blue"),
                      box(width = 2, title = tagList(icon("wind"), "Wind"),
                          h4(textOutput("wind")),
                          background = "teal"),
                      box(width = 2, title = tagList(icon("tachometer-alt"), "Air Pressure"),
                          h4(textOutput("air_pressure")),
                          background = "light-blue"),
                      box(width = 2, title = tagList(icon("eye"), "Visibility"),
                          h4(textOutput("visibility")),
                          background = "green")
                    )
                )
              ),
              fluidRow(
                box(width = 8, title = tagList(icon("map"), "MAP"),
                    status = "primary", solidHeader = TRUE,
                    leafletOutput("map", height = 400)),
                box(width = 4, title = tagList(icon("location-dot"), "Location"),
                    status = "primary", solidHeader = TRUE,
                    h4(icon("map-marker-alt"), " LOCATION:"),
                    h2(textOutput("location_name_weather")),
                    h4(icon("temperature-high"), " TEMPERATURE:"),
                    h3(textOutput("temperature")),
                    h4(icon("map"), " ADDRESS:"),
                    h4(textOutput("full_address"))),
                box(width = 4, title = tagList(icon("clock"), "Date"),
                    status = "primary", solidHeader = TRUE,
                    h4(textOutput("date_time")))
              ),
              fluidRow(
                box(width = 12, title = "Weather Forecast",
                    status = "primary", solidHeader = TRUE, align = "center",
                    tableOutput("forecast_table"))
              )
      ),
      
      # Tab Forecast
      tabItem(tabName = "forecast",
              fluidRow(
                box(width = 3, title = "Select Parameter",
                    status = "primary", solidHeader = TRUE,
                    selectInput("forecast_param", "Choose parameter:",
                                choices = c("Temperature" = "main.temp",
                                            "Humidity" = "main.humidity",
                                            "Wind Speed" = "wind.speed",
                                            "Air Pressure" = "main.pressure",
                                            "Vision" = "visibility"),
                                selected = "main.temp"),
                    h4("Address:"),
                    h3(textOutput("location_name_forecast"))),
                box(width = 9, title = "Forecast Plot",
                    status = "primary", solidHeader = TRUE,
                    plotlyOutput("line_plot", height = 500)),
                box(width = 12, title = "Plot",
                    status = "primary", solidHeader = TRUE,
                    plotlyOutput("correlation_plot"))
              )
      ),
      
      # Tab Menu4
      tabItem(tabName = "menu4",
              fluidRow(
                box(width = 6, title = tagList(icon("thermometer-half"), "TEMP"),
                    h4(plotlyOutput("nhietdo", height = 500)),
                    status = "danger", solidHeader = TRUE
                ),
                box(width = 6, title = tagList(icon("tint"), "Humidity"),
                    h4(plotlyOutput("doam", height = 500)),
                    status = "primary", solidHeader = TRUE
                ),
                box(width = 6, title = tagList(icon("wind"), "WIND"),
                    h4(plotlyOutput("gio", height = 500)),
                    status = "success", solidHeader = TRUE
                ),
                box(width = 6, title = tagList(icon("tachometer-alt"), "Air Pressure"),
                    h4(plotlyOutput("apsuat", height = 500)),
                    status = "info", solidHeader = TRUE
              )
      )
    )
  )
)
)
server <- function(input, output, session) {
  weather_info <- reactiveVal(NULL)
  place_detail <- reactiveVal(NULL)
  
  # Khởi tạo bản đồ mặc định
  output$map <- renderLeaflet({
    leaflet() %>% addTiles()
  })
  
  # Load mặc định Hà Nội khi mở app
  observe({
    default_lat <- 21.0285
    default_lon <- 105.8542
    
    url_weather <- paste0("https://api.openweathermap.org/data/2.5/weather?lat=",
                          default_lat, "&lon=", default_lon,
                          "&appid=", api_key, "&units=metric")
    res_weather <- GET(url_weather)
    data_weather <- fromJSON(rawToChar(res_weather$content))
    weather_info(data_weather)
    
    url_geo <- paste0("https://nominatim.openstreetmap.org/reverse?format=json&lat=",
                      default_lat, "&lon=", default_lon, "&zoom=18&addressdetails=1")
    res_geo <- GET(url_geo, add_headers(`User-Agent` = "R"))
    data_geo <- fromJSON(rawToChar(res_geo$content))
    place_detail(data_geo$display_name)
    
    leafletProxy("map") %>%
      clearMarkers() %>%
      setView(lng = default_lon, lat = default_lat, zoom = 10) %>%
      addMarkers(lng = default_lon, lat = default_lat, popup = data_weather$name)
  })
  
  # Nhấn vào bản đồ để lấy thời tiết
  observeEvent(input$map_click, {
    lat <- input$map_click$lat
    lon <- input$map_click$lng
    
    url_weather <- paste0("https://api.openweathermap.org/data/2.5/weather?lat=",
                          lat, "&lon=", lon, "&appid=", api_key, "&units=metric")
    res_weather <- GET(url_weather)
    data_weather <- fromJSON(rawToChar(res_weather$content))
    weather_info(data_weather)
    
    url_geo <- paste0("https://nominatim.openstreetmap.org/reverse?format=json&lat=",
                      lat, "&lon=", lon, "&zoom=18&addressdetails=1")
    res_geo <- GET(url_geo, add_headers(`User-Agent` = "R"))
    data_geo <- fromJSON(rawToChar(res_geo$content))
    place_detail(data_geo$display_name)
    
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(lng = lon, lat = lat, popup = data_weather$name)
  })
  
  # Tìm kiếm theo city_name
  observeEvent(input$city_name, {
    req(input$city_name)
    city <- input$city_name
    city_encoded <- URLencode(city, reserved = TRUE)
    
    url_weather <- paste0("https://api.openweathermap.org/data/2.5/weather?q=",
                          city_encoded, "&appid=", api_key, "&units=metric")
    res_weather <- GET(url_weather)
    data_weather <- fromJSON(rawToChar(res_weather$content))
    
    if (!is.null(data_weather$cod) && data_weather$cod == "404") {
      showNotification("Không tìm thấy thành phố!", type = "error")
      return()
    }
    
    weather_info(data_weather)
    
    lat <- data_weather$coord$lat
    lon <- data_weather$coord$lon
    
    url_geo <- paste0("https://nominatim.openstreetmap.org/reverse?format=json&lat=",
                      lat, "&lon=", lon, "&zoom=18&addressdetails=1")
    res_geo <- GET(url_geo, add_headers(`User-Agent` = "R"))
    data_geo <- fromJSON(rawToChar(res_geo$content))
    place_detail(data_geo$display_name)
    
    leafletProxy("map") %>%
      clearMarkers() %>%
      setView(lng = lon, lat = lat, zoom = 13) %>%
      addMarkers(lng = lon, lat = lat, popup = data_weather$name)
  })
  
  # Hiển thị thông tin thời tiết
  output$location_name_weather <- renderText({ req(weather_info()); weather_info()$name })
  output$location_name_forecast <- renderText({ req(weather_info()); weather_info()$name })
  output$temperature <- renderText({ req(weather_info()); paste0(round(weather_info()$main$temp, 1), " °C") })
  
  autoInvalidate <- reactiveTimer(1000, session)
  output$date_time <- renderText({
    autoInvalidate()
    req(weather_info())
    offset <- weather_info()$timezone
    utc_time <- as.POSIXct(Sys.time(), tz = "UTC")
    local_time <- utc_time + offset
    format(local_time, "Date: %d-%m-%Y - Time: %H:%M:%S")
  })
  
  output$full_address <- renderText({ if (!is.null(place_detail())) place_detail() else "Load..." })
  output$feels_like <- renderText({ req(weather_info()); paste0(weather_info()$main$feels_like, " °C") })
  output$humidity <- renderText({ req(weather_info()); paste0(weather_info()$main$humidity, " %") })
  output$clouds <- renderText({ req(weather_info()); weather_info()$weather$description })
  output$wind <- renderText({ req(weather_info()); paste0(weather_info()$wind$speed, " m/s") })
  output$air_pressure <- renderText({ req(weather_info()); paste0(weather_info()$main$pressure, " hPa") })
  output$visibility <- renderText({ req(weather_info()); paste0(weather_info()$visibility / 1000, " km") })
  
  # Forecast table
  forecast_data <- reactive({
    req(weather_info())
    lat <- weather_info()$coord$lat
    lon <- weather_info()$coord$lon
    
    url <- paste0("https://api.openweathermap.org/data/2.5/forecast?",
                  "lat=", lat, "&lon=", lon,
                  "&appid=", api_key, "&units=metric")
    res <- GET(url)
    data <- content(res, as = "parsed", type = "application/json")
    
    if (is.null(data$list)) return(data.frame())
    
    forecast_12h <- data$list[sapply(data$list, function(x) grepl("12:00:00", x$dt_txt))]
    
    data.frame(
      Date = as.POSIXct(sapply(forecast_12h, function(x) x$dt_txt), tz = "UTC"),
      Day = weekdays(as.POSIXct(sapply(forecast_12h, function(x) x$dt_txt), tz = "UTC")),
      Temperature = paste0(round(sapply(forecast_12h, function(x) x$main$temp)), "°C"),
      Description = sapply(forecast_12h, function(x) x$weather[[1]]$description),
      Humidity = paste0(sapply(forecast_12h, function(x) x$main$humidity), "%"),
      Wind = paste0(sapply(forecast_12h, function(x) x$wind$speed), " m/s"),
      Pressure = paste0(sapply(forecast_12h, function(x) x$main$pressure), " hPa")
    )
  })
  
  output$forecast_table <- renderTable({
    df <- forecast_data()
    df$Date <- format(as.POSIXct(df$Date, origin = "1970-01-01", tz = "Asia/Ho_Chi_Minh"), "%Y-%m-%d")
    df
  }, bordered = TRUE, striped = TRUE, hover = TRUE, align = 'c', width = "100%")
  
  # Data cho các biểu đồ
  weather_data <- reactive({
    req(weather_info())
    lat <- weather_info()$coord$lat
    lon <- weather_info()$coord$lon
    
    url <- paste0("https://api.openweathermap.org/data/2.5/forecast?lat=",
                  lat, "&lon=", lon, "&appid=", api_key, "&units=metric")
    res <- GET(url)
    data <- content(res, as = "text", encoding = "UTF-8") %>% fromJSON(flatten = TRUE)
    
    if (is.null(data$list)) return(data.frame())
    data$list %>% select(dt_txt, main.temp, main.humidity, wind.speed, visibility, main.pressure)
  })
  
  # Các biểu đồ Plotly
  output$line_plot <- renderPlotly({
    df <- weather_data()
    req(nrow(df) > 0)
    param <- input$forecast_param
    plot_ly(df, x = ~as.POSIXct(dt_txt), y = df[[param]],
            type = 'scatter', mode = 'lines+markers',
            line = list(color = 'blue'), marker = list(color = 'red', size = 6))
  })
  
  output$nhietdo <- renderPlotly({
    df <- weather_data()
    req(nrow(df) > 0)
    plot_ly(df, x = ~as.POSIXct(dt_txt), y = ~main.temp,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = 'orange'))
  })
  
  output$doam <- renderPlotly({
    df <- weather_data()
    req(nrow(df) > 0)
    plot_ly(df, x = ~as.POSIXct(dt_txt), y = ~main.humidity,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = 'blue'))
  })
  
  output$gio <- renderPlotly({
    df <- weather_data()
    req(nrow(df) > 0)
    plot_ly(df, x = ~as.POSIXct(dt_txt), y = ~wind.speed,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = 'green'))
  })
  
  output$apsuat <- renderPlotly({
    df <- weather_data()
    req(nrow(df) > 0)
    plot_ly(df, x = ~as.POSIXct(dt_txt), y = ~main.pressure,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = 'purple'))
  })
  
  output$correlation_plot <- renderPlotly({
    df <- weather_data()
    req(nrow(df) > 1)
    corr_data <- df %>% select(main.temp, main.humidity, wind.speed, visibility, main.pressure)
    colnames(corr_data) <- c("Temp", "Humidity", "Wind", "Visibility", "Pressure")
    corr_matrix <- round(cor(corr_data, use = "complete.obs"), 2)
    corr_matrix[is.na(corr_matrix)] <- 0
    corr_long <- as.data.frame(as.table(corr_matrix))
    names(corr_long) <- c("Variable1", "Variable2", "Correlation")
    plot_ly(x = corr_long$Variable1, y = corr_long$Variable2, z = corr_long$Correlation,
            type = "heatmap", colors = c("blue", "white", "red"),
            zmin = -1, zmax = 1)
  })
}

shinyApp(ui = ui, server = server)
