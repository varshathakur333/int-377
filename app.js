async function getWeather() {
  let city = document.getElementById("city").value;
  let res = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=35&longitude=139`);
  document.getElementById("result").innerHTML = "Sample Weather Loaded!";
}