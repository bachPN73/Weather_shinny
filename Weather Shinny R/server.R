library(tidyverse)
library(shiny)
library(shinydashboard)
library(httr)
library(jsonlite)
library(leaflet)
library(bslib)
library(plotly)
library(lubridate)

api_key = "73e286c7fe9690535d5dfc860f2cc643"

shinyServer(function(input, output, session) {
  weather_info <- reactiveVal(NULL)
  place_detail <- reactiveVal(NULL)
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles()
  })
  
  observe({
    default_lat <- 21.0285
    default_lon <- 105.8542
    
    url_weather <- paste0("https://api.openweathermap.org/data/2.5/weather?lat=",
                          default_lat, "&lon=", default_lon,
                          "&appid=", api_key, "&units=metric")
    res_weather <- GET(url_weather)
    data_weather <- fromJSON(rawToChar(res_weather$content))
    weather_info(data_weather)
    t
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
  
  observeEvent(input$map_click, {
    lat <- input$map_click$lat
    lon <- input$map_click$lng
    t
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
    
    # Cập nhật bản đồ
    leafletProxy("map") %>%
      clearMarkers() %>%
      setView(lng = lon, lat = lat, zoom = 13) %>%
      addMarkers(lng = lon, lat = lat, popup = data_weather$name)
  })
  
  
  output$location_name_weather <- renderText({
    req(weather_info())
    weather_info()$name
  })
  
  output$location_name_forecast <- renderText({
    req(weather_info())
    weather_info()$name
  })
  
  output$temperature <- renderText({
    req(weather_info())
    paste0(round(weather_info()$main$temp, 1), " °C")
  })
  
  autoInvalidate <- reactiveTimer(1000, session)
  
  output$date_time <- renderText({
    autoInvalidate()
    req(weather_info())
    
    offset <- weather_info()$timezone  
    utc_time <- as.POSIXct(Sys.time(), tz = "UTC")  
    local_time <- utc_time + offset                 
    
    format(local_time, "Date: %d-%m-%Y - Time: %H:%M:%S")
  })
  
  output$full_address <- renderText({
    if (!is.null(place_detail())) place_detail() else "LoadLoad..."
  })
  
  output$feels_like <- renderText({
    req(weather_info())
    paste0(weather_info()$main$feels_like, " °C")
  })
  
  output$humidity <- renderText({
    req(weather_info())
    paste0(weather_info()$main$humidity, " %")
  })
  
  output$clouds <- renderText({
    req(weather_info())
    weather_info()$weather$description
  })
  
  output$wind <- renderText({
    req(weather_info())
    paste0(weather_info()$wind$speed, " m/s")
  })
  
  output$air_pressure <- renderText({
    req(weather_info())
    paste0(weather_info()$main$pressure, " hPa")
  })
  
  output$visibility <- renderText({
    req(weather_info())
    paste0(weather_info()$visibility / 1000, " km")
  })
  
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
    
    df <- data.frame(
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
  
  
  weather_data <- reactive({
    req(weather_info())
    
    lat <- weather_info()$coord$lat
    lon <- weather_info()$coord$lon
    
    url <- paste0("https://api.openweathermap.org/data/2.5/forecast?lat=",
                  lat, "&lon=", lon, "&appid=", api_key, "&units=metric")
    res <- GET(url)
    data <- content(res, as = "text", encoding = "UTF-8") %>% fromJSON(flatten = TRUE)
    
    if (is.null(data$list)) return(data.frame())
    
    df <- data$list %>% select(dt_txt, main.temp, main.humidity,
                               wind.speed, visibility, main.pressure)
  })
  
  output$line_plot <- renderPlotly({
    df <- weather_data()
    req(nrow(df) > 0)
    
    param <- input$forecast_param
    
    plot_ly(df, x = ~as.POSIXct(dt_txt), y = df[[param]],
            type = 'scatter', mode = 'lines+markers',
            text = ~dt_txt, hoverinfo = 'text+y',
            line = list(color = 'blue'),
            marker = list(color = 'red', size = 6)) %>%
      layout(title = "Forecast 5day/3h",
             xaxis = list(title = "Time"),
             yaxis = list(title = param))
  })
  
  output$nhietdo <- renderPlotly({
    df <- weather_data()
    req(nrow(df) > 0)
    plot_ly(df, x = ~as.POSIXct(dt_txt), y = ~main.temp,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = 'orange')) %>%
      layout(xaxis = list(title = "Time"), yaxis = list(title = "°C"))
  })
  
  output$doam <- renderPlotly({
    df <- weather_data()
    req(nrow(df) > 0)
    plot_ly(df, x = ~as.POSIXct(dt_txt), y = ~main.humidity,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = 'blue')) %>%
      layout(xaxis = list(title = "TimeTime"), yaxis = list(title = "%"))
  })
  
  output$gio <- renderPlotly({
    df <- weather_data()
    req(nrow(df) > 0)
    plot_ly(df, x = ~as.POSIXct(dt_txt), y = ~wind.speed,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = 'green')) %>%
      layout(xaxis = list(title = "Time"), yaxis = list(title = "m/s"))
  })
  
  output$apsuat <- renderPlotly({
    df <- weather_data()
    req(nrow(df) > 0)
    plot_ly(df, x = ~as.POSIXct(dt_txt), y = ~main.pressure,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = 'purple')) %>%
      layout(xaxis = list(title = "Time"), yaxis = list(title = "hPa"))
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
    
    plot_ly(
      x = corr_long$Variable1,
      y = corr_long$Variable2,
      z = corr_long$Correlation,
      type = "heatmap",
      colors = c("blue", "white", "red"),
      zmin = -1,
      zmax = 1
    ) %>%
      layout(
        title = "",
        xaxis = list(title = ""),
        yaxis = list(title = ""),
        coloraxis = list(
          colorbar = list(
            tickvals = c(-1, -0.5, 0, 0.5, 1),
            ticktext = c("-1", "-0.5", "0", "0.5", "1")
          )
        )
      )
  })
})