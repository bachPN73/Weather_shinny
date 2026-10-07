# Import library
library(tidyverse)
library(shiny)
library(shinydashboard)
library(httr)
library(jsonlite)
library(leaflet)
library(bslib)
library(plotly)
library(rsconnect)

# ui.R
shinyUI(dashboardPage(
  dashboardHeader(title = "Weather"),
  
  dashboardSidebar(
    sidebarMenu(
      textInput("city_name", "Enter location:", placeholder = "e.g., Hanoi, Da Nang, Tokyo", value = ""),
      menuItem("Weather", tabName = "weather", icon = icon("cloud")),
      menuItem("Forecast", tabName = "forecast", icon = icon("cloud-sun")),
      menuItem("Plot", tabName = "menu4", icon = icon("bars"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "weather",
              h1("CURRENT WEATHER"),
              br(),
              fluidRow(
                box(width = 12, title = tagList(icon(""), "INFORMATION"),
                    status = "primary", solidHeader = TRUE,
                    fluidRow(
                      box(width = 2, title = tagList(icon("thermometer-half"), "Feels Like"),
                          h4(textOutput("feels_like")),
                          background = "yellow"
                      ),
                      box(width = 2, title = tagList(icon("tint"), "Humidity"),
                          h4(textOutput("humidity")),
                          background = "aqua"
                      ),
                      box(width = 2, title = tagList(icon("globe"), "Status"),
                          h4(textOutput("clouds")),
                          background = "light-blue"
                      ),
                      box(width = 2, title = tagList(icon("wind"), "Wind"),
                          h4(textOutput("wind")),
                          background = "teal"
                      ),
                      box(width = 2, title = tagList(icon("tachometer-alt"), "Air Pressure"),
                          h4(textOutput("air_pressure")),
                          background = "light-blue"
                      ),
                      box(width = 2, title = tagList(icon("eye"), "Visibility"),
                          h4(textOutput("visibility")),
                          background = "green"
                      )
                    )
                )
              ),
              fluidRow(
                box(width = 8, title = tagList(icon("map"), "MAP"),
                    status = "primary", solidHeader = TRUE,
                    leafletOutput("map", height = 400)
                ),
                box(width = 4, title = tagList(icon("location-dot"), "Location"),
                    status = "primary", solidHeader = TRUE,
                    h4(icon("map-marker-alt"), " LOCATION:"),
                    h2(textOutput("location_name_weather")),
                    
                    h4(icon("temperature-high"), " TEMPERATURE:"),
                    h3(textOutput("temperature")),
                    
                    h4(icon("map"), " ADDRESS:"),
                    h4(textOutput("full_address"))
                ),
                box(width = 4, title = tagList(icon("clock"), "Date"),
                    status = "primary", solidHeader = TRUE,
                    h4(textOutput("date_time"))
                )
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
                                            "Vision" = "visibility"
                                ),
                                selected = "main.temp"),
                    h4("Address:"),
                    h3(textOutput("location_name_forecast"))
                ),
                box(width = 9, title = "Forecast Plot",
                    status = "primary", solidHeader = TRUE,
                    plotlyOutput("line_plot", height = 500)
                    ),
                box(width = 12, title = "Plot",
                    status = "primary", solidHeader = TRUE,
                    plotlyOutput("correlation_plot")
              )
      )
    ),
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
            ))
  )
)
)
)

rsconnect::setAccountInfo(name='backonhome',
                          token='0AF8278FF35D0AD92058F70971F2AEE2',
                          secret='biDXuBI1b7jYASrVg6uVMoavkmZLvvZNsudZbEAh')

