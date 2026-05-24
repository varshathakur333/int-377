async function getWeather() {
  const city = document.getElementById("city").value;
  const apiKey = "0f3be8c13fac004ddea273173f4ab9d4";
  const res = await fetch(
    `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`
  );
  const data = await res.json();
  document.getElementById("result").innerHTML = `
    🌡️ Temp: ${data.main.temp}°C | 
    💧 Humidity: ${data.main.humidity}% | 
    🌤️ ${data.weather[0].description}
  `;
}