CREATE OR REPLACE TABLE dim_weather_thresholds (
    city_id              VARCHAR PRIMARY KEY,
    city_name            VARCHAR NOT NULL,
    country              VARCHAR NOT NULL,
    latitude             DOUBLE  NOT NULL,
    longitude            DOUBLE  NOT NULL,
    timezone             VARCHAR NOT NULL,
    min_apparent_temp_c  DOUBLE  NOT NULL,
    max_apparent_temp_c  DOUBLE  NOT NULL,
    max_daily_rain_mm    DOUBLE  NOT NULL,
    max_wind_speed_kmh   DOUBLE  NOT NULL,
    max_wind_gust_kmh    DOUBLE  NOT NULL,
    CHECK (min_apparent_temp_c < max_apparent_temp_c),
    CHECK (max_wind_speed_kmh <= max_wind_gust_kmh)
);

INSERT INTO dim_weather_thresholds VALUES
    ('BKK', 'Bangkok',       'Thailand',      13.75398,  100.50144, 'Asia/Bangkok',         20.0, 38.0, 10.0, 30.0, 50.0),
    ('DAR', 'Dar es Salaam', 'Tanzania',      -6.7924,    39.2083,  'Africa/Dar_es_Salaam', 20.0, 31.0,  5.0, 30.0, 50.0),
    ('LAX', 'Los Angeles',   'United States', 34.0522,  -118.2437,  'America/Los_Angeles',  15.0, 28.0,  3.0, 30.0, 50.0);